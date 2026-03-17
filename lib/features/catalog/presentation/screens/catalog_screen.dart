import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../../bot_management/providers/bot_management_providers.dart';
import '../../../bot_management/domain/business.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsAsync = ref.watch(botsProvider);
    final connectedBotsAsync = ref.watch(connectedBotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokki AI Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(connectedBotsProvider);
          ref.invalidate(botsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 1. Секция "Мои боты"
            connectedBotsAsync.when(
              data: (connectedBots) {
                if (connectedBots.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Мои боты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...connectedBots
                        .map((bot) => _buildBusinessTile(context, bot)),
                    const Divider(height: 32, indent: 16, endIndent: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 2. Секция "Каталог"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Каталог решений',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            botsAsync.when(
              data: (bots) {
                if (bots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Каталог пуст.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bots.length,
                  itemBuilder: (context, index) {
                    final bot = bots[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(bot.name),
                        subtitle: Text(bot.description),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.push('/connect-bot/${bot.id}/${bot.name}');
                          },
                          child: const Text('Подключить'),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Ошибка загрузки каталога:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessTile(BuildContext context, Business bot) {
    final statusColor = bot.status == 'active' ? Colors.green : Colors.orange;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        // Исправлена иконка на существующую
        child: Icon(Icons.smart_toy_outlined, color: statusColor),
      ),
      title: Text(bot.botId.toUpperCase()),
      subtitle: Text('Статус: ${bot.status}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/bot-management/${bot.id}', extra: bot);
      },
    );
  }
}
