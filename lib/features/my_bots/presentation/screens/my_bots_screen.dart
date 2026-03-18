import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../bot_management/providers/bot_management_providers.dart';

class MyBotsScreen extends ConsumerWidget {
  const MyBotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.smart_toy_outlined, color: Colors.white),
                  ),
                  title: Text(
                    'Бот: ${business.botId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Статус: ${business.status}',
                    style: TextStyle(
                      color: business.status == 'active'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => context.push(
                      '/bot-management/${business.id}',
                      extra: business,
                    ),
                    child: const Text('Управление'),
                  ),
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
