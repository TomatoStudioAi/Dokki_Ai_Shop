import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Исправлено: путь до папки providers на два уровня выше
import '../../providers/catalog_providers.dart';
import '../widgets/bot_card.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsAsync = ref.watch(botsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог ИИ-ботов'),
        centerTitle: false,
      ),
      body: botsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Ошибка загрузки: $err'),
        ),
        data: (bots) {
          if (bots.isEmpty) {
            return const Center(
              child: Text('Нет доступных ботов'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: bots.length,
            itemBuilder: (context, index) {
              final bot = bots[index];

              return BotCard(
                bot: bot,
                onConnect: () =>
                    context.push('/connect-bot/${bot.id}/${bot.name}'),
              );
            },
          );
        },
      ),
    );
  }
}
