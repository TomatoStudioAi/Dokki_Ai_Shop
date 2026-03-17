import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/business.dart';

class BotManagementScreen extends ConsumerWidget {
  final Business business;

  const BotManagementScreen({
    super.key,
    required this.business,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(business.status);
    final dateString = business.createdAt.toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление ботом'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка основной информации
            Card(
              child: ListTile(
                title: Text(
                  business.botId.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Подключен: $dateString'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    business.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Секция управления
            const Text(
              'Доступные действия',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скоро')),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Настройки'),
              ),
            ),

            const Spacer(),

            // Инфо-блок для ожидающих деплоя
            if (business.status == 'pending')
              Card(
                color: Colors.amber.withValues(alpha: 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Бот в очереди на деплой. Это может занять несколько минут.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
