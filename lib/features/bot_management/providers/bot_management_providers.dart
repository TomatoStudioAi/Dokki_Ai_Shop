import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/business.dart';
import '../domain/business_repository.dart';
import '../data/business_repository_impl.dart';
import '../data/telegram_repository.dart';

/// Провайдер для работы с базой данных (бизнес-логика подключений)
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BusinessRepositoryImpl(supabase);
});

/// Провайдер для валидации токенов напрямую через Telegram API
final telegramRepositoryProvider = Provider<TelegramRepository>((ref) {
  return TelegramRepository();
});

/// Провайдер списка всех подключенных ботов текущего пользователя.
/// Использует FutureProvider для автоматической обработки асинхронных данных.
final connectedBotsProvider = FutureProvider<List<Business>>((ref) async {
  return ref.watch(businessRepositoryProvider).getConnectedBots();
});
