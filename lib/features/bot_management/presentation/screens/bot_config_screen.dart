import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart'; // Импорт темы
import '../../domain/business.dart';
import '../../providers/bot_management_providers.dart';

class BotConfigScreen extends ConsumerStatefulWidget {
  final Business business;

  const BotConfigScreen({
    super.key,
    required this.business,
  });

  @override
  ConsumerState<BotConfigScreen> createState() => _BotConfigScreenState();
}

class _BotConfigScreenState extends ConsumerState<BotConfigScreen> {
  final _systemPromptController = TextEditingController();
  final _welcomeMessageController = TextEditingController();

  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _systemPromptController.dispose();
    _welcomeMessageController.dispose();
    super.dispose();
  }

  // ЛОГИКА ОСТАВЛЕНА БЕЗ ИЗМЕНЕНИЙ
  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(botConfigRepositoryProvider(widget.business));
      final businessId = widget.business.botBusinessId ?? widget.business.id;

      await repo.updateSystemPrompt(
        businessId,
        _systemPromptController.text.trim(),
      );
      await repo.updateWelcomeMessage(
        businessId,
        _welcomeMessageController.text.trim(),
      );

      ref.invalidate(botConfigProvider(widget.business));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Настройки сохранены'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Хелпер для InputDecoration (как в ConnectBotScreen)
  InputDecoration _buildInputDecoration(String hint) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Инициализация контроллеров оставлена без изменений
    ref.listen<AsyncValue<Map<String, dynamic>?>>(
      botConfigProvider(widget.business),
      (previous, next) {
        if (next is AsyncData && !_isInitialized) {
          final data = next.value;
          if (data != null) {
            _systemPromptController.text = data['system_prompt'] ?? '';
            _welcomeMessageController.text = data['welcome_message'] ?? '';
          }
          _isInitialized = true;
        }
      },
    );

    final configAsync = ref.watch(botConfigProvider(widget.business));

    return Scaffold(
      backgroundColor: AppColors.background, // Тёмный фон
      appBar: AppBar(
        title: const Text('Настройки ИИ'),
        centerTitle: false,
      ),
      body: configAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(
            child: Text('Ошибка: $err',
                style: const TextStyle(color: Colors.white))),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'СИСТЕМНЫЙ ПРОМПТ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _systemPromptController,
                maxLines: 10,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, height: 1.4),
                decoration: _buildInputDecoration(
                    'Инструкции для ИИ: как он должен общаться, какие услуги предлагать...'),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 32),
              const Text(
                'ПРИВЕТСТВИЕ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _welcomeMessageController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _buildInputDecoration(
                    'Текст, который бот напишет первым...'),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 48),

              // Акцентная кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'СОХРАНИТЬ ИЗМЕНЕНИЯ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
