import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/bot.dart';

class BotRepository {
  final SupabaseClient _supabase;

  // Конструктор теперь принимает клиент Supabase
  BotRepository(this._supabase);

  Future<List<Bot>> getBots() async {
    final response =
        await _supabase.from('bot_catalog').select().eq('is_active', true);

    // Кастим результат в список мап и парсим через Bot.fromJson
    return (response as List<dynamic>)
        .map((json) => Bot.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
