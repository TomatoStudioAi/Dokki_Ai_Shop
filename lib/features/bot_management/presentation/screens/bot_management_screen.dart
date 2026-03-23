import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart'; // Импорт темы
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
      backgroundColor: AppColors.background, // Тёмный фон
      appBar: AppBar(
        title: const Text('Управление ботом'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка статуса бота (переписана на Container)
            _buildStatusCard(isActivated),
            const SizedBox(height: 32),

            // Основные действия
            const Text(
              'ДЕЙСТВИЯ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Кнопка записей
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentsScreen(business: business),
                  ),
                ),
                icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                label: const Text('ЗАПИСИ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка Настройки
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BotConfigScreen(business: business),
                  ),
                ),
                icon: const Icon(Icons.settings_suggest_rounded, size: 20),
                label: const Text('НАСТРОЙКИ ПРОМПТА'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Кнопка активации (появится, если группа еще не привязана)
            if (!isActivated)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Логика Stage 2.2 (Активация группы)
                  },
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text(
                    'АКТИВИРОВАТЬ ГРУППУ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isActivated) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isActivated ? Colors.green : Colors.orange)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActivated
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: isActivated ? Colors.green : Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActivated ? 'Бот активен' : 'Требуется настройка',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActivated
                      ? 'Бот готов к приему заказов'
                      : 'Привяжите Telegram группу',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
