import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/business.dart';
import '../domain/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final SupabaseClient _supabase;

  BusinessRepositoryImpl(this._supabase);

  @override
  Future<Business> connectBot({
    required String botId,
    required String botToken,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Пользователь не авторизован');

    // .select().single() возвращает Map с данными созданной записи
    final response = await _supabase
        .from('businesses')
        .insert({
          'user_id': userId,
          'bot_id': botId,
          'bot_token': botToken,
          'status': 'pending',
        })
        .select()
        .single();

    return Business.fromJson(response);
  }

  @override
  Future<List<Business>> getConnectedBots() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Пользователь не авторизован');

    final response =
        await _supabase.from('businesses').select().eq('user_id', userId);

    return (response as List).map((json) => Business.fromJson(json)).toList();
  }

  @override
  Future<Business?> getBusinessById(String id) async {
    final response =
        await _supabase.from('businesses').select().eq('id', id).maybeSingle();

    return response != null ? Business.fromJson(response) : null;
  }
}
