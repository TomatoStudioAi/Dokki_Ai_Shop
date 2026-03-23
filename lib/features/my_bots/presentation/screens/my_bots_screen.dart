import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../bot_management/providers/bot_management_providers.dart';
// Импорт теперь будет работать после перемещения файла
import '../widgets/business_card.dart';

class MyBotsScreen extends ConsumerWidget {
  const MyBotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Сохранена оригинальная переменная
    final connectedBotsAsync = ref.watch(connectedBotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои боты'),
      ),
      body: connectedBotsAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return const Center(
              child: Text(
                'У вас пока нет активных ботов',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];

              // Заменено: старый Card/ListTile заменен на BusinessCard
              // Вся логика навигации и передачи данных сохранена
              return BusinessCard(
                business: business,
                onManage: () => context.push(
                  '/bot-management/${business.id}',
                  extra: business,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}
