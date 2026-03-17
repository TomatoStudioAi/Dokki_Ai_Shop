import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/business.dart';
import '../domain/business_repository.dart';
import '../data/business_repository_impl.dart';
import '../data/telegram_repository.dart';
import '../data/appointments_repository.dart';
import '../data/bot_config_repository.dart';

// 1. Провайдер Telegram API
final telegramRepositoryProvider = Provider<TelegramRepository>((ref) {
  return TelegramRepository();
});

// 2. Провайдер управления ботами
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(ref.watch(supabaseClientProvider));
});

// 3. Провайдер списка подключенных ботов (НУЖЕН ДЛЯ КАТАЛОГА)
final connectedBotsProvider = FutureProvider<List<Business>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getConnectedBots();
});

// 4. Провайдер репозитория записей (TomatoAdmin)
final appointmentsRepositoryProvider =
    Provider.family<AppointmentsRepository, Business>((ref, business) {
  final client = SupabaseClient(
    business.botSupabaseUrl!,
    business.botSupabaseAnonKey!,
  );
  return AppointmentsRepository(client);
});

// 5. Провайдер списка записей
final appointmentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Business>(
        (ref, business) async {
  return ref.watch(appointmentsRepositoryProvider(business)).getAppointments();
});

// 6. Провайдер репозитория конфигурации бота
final botConfigRepositoryProvider =
    Provider.family<BotConfigRepository, Business>((ref, business) {
  final client = SupabaseClient(
    business.botSupabaseUrl!,
    business.botSupabaseAnonKey!,
  );
  return BotConfigRepository(client);
});

// 7. Провайдер конфигурации
final botConfigProvider =
    FutureProvider.family<Map<String, dynamic>?, Business>(
        (ref, business) async {
  final businessId = business.botBusinessId ?? business.id;
  return ref.watch(botConfigRepositoryProvider(business)).getConfig(businessId);
});
