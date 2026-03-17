import 'business.dart';

abstract class BusinessRepository {
  /// Подключает нового бота и возвращает созданную модель Business
  Future<Business> connectBot({
    required String botId,
    required String botToken,
  });

  Future<List<Business>> getConnectedBots();
  Future<Business?> getBusinessById(String id);
}
