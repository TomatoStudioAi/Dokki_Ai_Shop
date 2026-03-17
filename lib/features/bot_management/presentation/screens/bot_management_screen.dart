import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/business.dart';
import 'appointments_screen.dart';
import 'bot_config_screen.dart';

class BotManagementScreen extends ConsumerWidget {
  final Business business;

  const BotManagementScreen({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActivated = business.telegramGroupId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление ботом'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка статуса бота
            _buildStatusCard(isActivated),
            const SizedBox(height: 24),

            // Основные действия
            const Text(
              'Действия',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Кнопка записей
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentsScreen(business: business),
                  ),
                ),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Записи'),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка Настройки
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BotConfigScreen(business: business),
                  ),
                ),
                icon: const Icon(Icons.settings),
                label: const Text('Настройки'),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка активации (появится, если группа еще не привязана)
            if (!isActivated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Логика Stage 2.2 (Активация группы)
                  },
                  icon: const Icon(Icons.group_add),
                  label: const Text('Активировать группу'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isActivated) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isActivated ? Icons.check_circle : Icons.error_outline,
              color: isActivated ? Colors.green : Colors.orange,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActivated ? 'Бот активен' : 'Требуется настройка',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    isActivated
                        ? 'Бот готов к приему заказов в группе'
                        : 'Добавьте бота в группу Telegram для получения уведомлений',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
