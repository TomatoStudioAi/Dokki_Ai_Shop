import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramRepository {
  final http.Client _client;

  TelegramRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Проверяет токен и возвращает данные о боте (id, username и т.д.)
  Future<Map<String, dynamic>> validateToken(String token) async {
    final url = Uri.parse('https://api.telegram.org/bot$token/getMe');

    try {
      final response = await _client.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        // Возвращаем объект 'result', в котором лежит username
        return data['result'] as Map<String, dynamic>;
      } else {
        throw Exception(data['description'] ?? 'Неверный токен');
      }
    } catch (e) {
      throw Exception('Ошибка связи с Telegram: $e');
    }
  }

  /// Поиск ID группы через getUpdates
  Future<String?> getChatId(String token) async {
    final url = Uri.parse('https://api.telegram.org/bot$token/getUpdates');
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List updates = data['result'] ?? [];
        for (var update in updates.reversed) {
          if (update.containsKey('my_chat_member')) {
            return update['my_chat_member']['chat']['id'].toString();
          }
          if (update.containsKey('message')) {
            return update['message']['chat']['id'].toString();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Отправка сообщения
  Future<bool> sendMessage(String token, String chatId, String text) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$token/sendMessage');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'chat_id': chatId, 'text': text}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
