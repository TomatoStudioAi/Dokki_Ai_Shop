import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../core/env/env.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../catalog/providers/catalog_providers.dart';
import '../../providers/bot_management_providers.dart';

class ConnectBotScreen extends ConsumerStatefulWidget {
  final String botId;
  final String botName;

  const ConnectBotScreen({
    super.key,
    required this.botId,
    required this.botName,
  });

  @override
  ConsumerState<ConnectBotScreen> createState() => _ConnectBotScreenState();
}

class _ConnectBotScreenState extends ConsumerState<ConnectBotScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _botTokenController = TextEditingController();
  final _railwayTokenController = TextEditingController();
  final _workspaceIdController = TextEditingController();

  bool _isLoading = false;
  late AppStrings _s;

  @override
  void dispose() {
    _pageController.dispose();
    _botTokenController.dispose();
    _railwayTokenController.dispose();
    _workspaceIdController.dispose();
    super.dispose();
  }

  // Внутренний хелпер для глубокой очистки токенов
  String _sanitize(String value) {
    return value.trim().replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
  }

  Future<void> _validateTelegramAndProceed() async {
    final token = _sanitize(_botTokenController.text);

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_s.connErrorNoToken)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(telegramRepositoryProvider).validateToken(token);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_s.authError}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _connect() async {
    final botToken = _sanitize(_botTokenController.text);
    final railwayToken = _railwayTokenController.text.trim();
    final workspaceId = _workspaceIdController.text.trim();

    if (railwayToken.isEmpty || workspaceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_s.connErrorNoRailway)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Создать запись в Supabase
      final result = await ref.read(businessRepositoryProvider).connectBot(
            botId: widget.botId,
            botToken: botToken,
            railwayToken: railwayToken,
            railwayWorkspaceId: workspaceId,
          );

      // 2. Получить данные бота из каталога
      final bot = await ref.read(botByIdProvider(widget.botId).future);

      if (bot == null) {
        throw Exception('Данные бота не найдены');
      }

      final githubRepo = bot.githubRepo;
      if (githubRepo == null || githubRepo.isEmpty) {
        throw Exception('GitHub репозиторий не настроен для этого бота');
      }

      debugPrint('🔵 Bot loaded: ${bot.name}');
      debugPrint('🔵 GitHub repo: $githubRepo');

      // 3. Отправить на deploy-service
      final deployResponse = await http.post(
        Uri.parse('${Env.deployServiceUrl}/deploy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'businessId': result.id,
          'botId': widget.botId,
          'botToken': botToken,
          'githubRepo': githubRepo,
          'railwayToken': railwayToken,
          'railwayWorkspaceId': workspaceId,
        }),
      );

      // 4. Проверить статус ответа
      if (deployResponse.statusCode != 200 &&
          deployResponse.statusCode != 202) {
        throw Exception('Deploy failed: ${deployResponse.body}');
      }

      // 5. Получить railwayUrl из ответа (ИСПРАВЛЕНО: добавлен ключ 'url')
      final deployData = jsonDecode(deployResponse.body);
      final railwayUrl = deployData['railwayUrl'] ??
          deployData['railway_url'] ??
          deployData['url'];

      debugPrint('🔵 Extracted railwayUrl: $railwayUrl');

      if (railwayUrl == null || railwayUrl.isEmpty) {
        throw Exception('Railway URL not received');
      }

      // 6. Сохранить railwayUrl в Supabase
      await ref
          .read(businessRepositoryProvider)
          .updateRailwayUrl(result.id, railwayUrl);

      // 7. Обновить локальный объект
      final updatedResult = result.copyWith(railwayUrl: railwayUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_s.connSuccessDeploy),
            backgroundColor: AppColors.success,
          ),
        );

        // 8. Переход на экран настройки бота
        context.pushReplacement(
          '/bot-setup/${result.id}',
          extra: updatedResult,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_s.authError}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);
    _s = s;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_currentStep == 0 ? s.connStep1Title : s.connStep2Title),
        centerTitle: false,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep = 0);
                },
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTelegramStep(s),
          _buildRailwayStep(s),
        ],
      ),
    );
  }

  Widget _buildTelegramStep(AppStrings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.connTelegramInstrTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(
              s.connTelegramInstrBody,
              style: const TextStyle(
                  height: 1.6, color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            s.connTokenLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _botTokenController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration:
                _buildInputDecoration('Bot API Token', Icons.vpn_key_rounded),
            enabled: !_isLoading,
            autocorrect: false,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateTelegramAndProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: AppColors.surface, strokeWidth: 2),
                    )
                  : Text(
                      s.connBtnContinue,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailwayStep(AppStrings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.connRailwayInstrTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(
              s.connRailwayInstrBody,
              style: const TextStyle(
                  height: 1.6, color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            s.connRailwayTokenLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _railwayTokenController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: _buildInputDecoration(
                'Railway Token', Icons.cloud_queue_rounded),
            enabled: !_isLoading,
            autocorrect: false,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
          ),
          const SizedBox(height: 24),
          Text(
            s.connWorkspaceLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _workspaceIdController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration:
                _buildInputDecoration('Workspace ID', Icons.grid_view_rounded),
            enabled: !_isLoading,
            autocorrect: false,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _connect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: AppColors.surface, strokeWidth: 2),
                    )
                  : Text(
                      s.connBtnDeploy,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
