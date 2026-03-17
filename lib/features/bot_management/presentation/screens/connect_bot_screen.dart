import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  // Временно замени это:
  final _tokenController = TextEditingController(
      text: '8667371693:AAG7XOyBunNHLNuhscvwOy5WaxGhOdMOQUE');
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите токен')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Валидация токена через Telegram API
      final botInfo =
          await ref.read(telegramRepositoryProvider).validateToken(token);

      // 2. Сохранение в Supabase и получение объекта Business
      final result = await ref.read(businessRepositoryProvider).connectBot(
            botId: widget.botId,
            botToken: token,
          );

      // 3. Переход на экран управления ботом
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Бот @${botInfo['username']} успешно подключён!'),
            backgroundColor: Colors.green,
          ),
        );

        // Заменяем текущий экран на экран управления, передавая данные
        context.pushReplacement(
          '/bot-management/${result.id}',
          extra: result,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Ошибка: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подключение ${widget.botName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Инструкция:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '1. Откройте @BotFather в Telegram.\n'
                  '2. Создайте нового бота (/newbot) или выберите существующего (/mybots).\n'
                  '3. Скопируйте API Token и вставьте его в поле ниже.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Bot API Token',
                hintText: '123456789:ABCDefGhIJKlmNoP...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              enabled: !_isLoading,
              autocorrect: false,
              enableInteractiveSelection: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Проверить и подключить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
