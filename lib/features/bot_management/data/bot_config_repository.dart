import 'package:supabase_flutter/supabase_flutter.dart';

class BotConfigRepository {
  final SupabaseClient _client;

  BotConfigRepository(this._client);

  Future<Map<String, dynamic>?> getConfig(String businessId) async {
    return await _client
        .from('bot_config')
        .select()
        .eq('business_id', businessId)
        .maybeSingle();
  }

  Future<void> updateSystemPrompt(String businessId, String prompt) async {
    await _client
        .from('bot_config')
        .update({'system_prompt': prompt}).eq('business_id', businessId);
  }

  Future<void> updateWelcomeMessage(String businessId, String message) async {
    await _client
        .from('bot_config')
        .update({'welcome_message': message}).eq('business_id', businessId);
  }
}
