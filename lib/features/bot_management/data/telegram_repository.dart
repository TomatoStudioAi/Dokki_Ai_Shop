import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramRepository {
  Future<Map<String, dynamic>> validateToken(String token) async {
    final url = Uri.parse('https://api.telegram.org/bot$token/getMe');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['ok'] == true) {
        // Возвращаем объект 'result', который содержит id, first_name и username бота
        return data['result'] as Map<String, dynamic>;
      } else {
        // Telegram вернул ошибку (например, 401 Unauthorized)
        throw Exception(data['description'] ?? 'Неверный токен бота');
      }
    } catch (e) {
      // Ошибки сети или парсинга
      throw Exception('Ошибка проверки токена: $e');
    }
  }
}
