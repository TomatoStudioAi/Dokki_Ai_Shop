import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(botConfigRepositoryProvider(widget.business));
      // Используем botBusinessId для сохранения в удаленную базу, с фолбэком на локальный id
      final businessId = widget.business.botBusinessId ?? widget.business.id;

      await repo.updateSystemPrompt(
        businessId,
        _systemPromptController.text.trim(),
      );
      await repo.updateWelcomeMessage(
        businessId,
        _welcomeMessageController.text.trim(),
      );

      // Обновляем данные в кэше
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

  @override
  Widget build(BuildContext context) {
    // Инициализация контроллеров при первой загрузке данных
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
      appBar: AppBar(
        title: const Text('Настройки ИИ'),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Системный промпт',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _systemPromptController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Инструкции для ИИ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Приветствие',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _welcomeMessageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Текст первого сообщения...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveConfig,
                  child:
                      Text(_isSaving ? 'Сохранение...' : 'Сохранить изменения'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
