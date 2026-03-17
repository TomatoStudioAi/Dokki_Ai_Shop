import 'business.dart';

abstract class BusinessRepository {
  /// Получить список всех подключенных ботов пользователя
  Future<List<Business>> getConnectedBots();

  /// Подключить нового бота
  Future<Business> connectBot({
    required String botId,
    required String botToken,
  });

  /// Обновить данные существующего бота
  Future<Business> updateBusiness(String id, Map<String, dynamic> data);
}
