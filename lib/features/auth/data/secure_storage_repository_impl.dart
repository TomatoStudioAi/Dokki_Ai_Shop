import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/secure_storage_repository.dart';

class SecureStorageRepositoryImpl implements SecureStorageRepository {
  final FlutterSecureStorage _secureStorage;
  static const _businessIdKey = 'business_id';

  SecureStorageRepositoryImpl(this._secureStorage);

  @override
  Future<void> saveBusinessId(String businessId) async {
    await _secureStorage.write(key: _businessIdKey, value: businessId);
  }

  @override
  Future<String?> getBusinessId() async {
    return await _secureStorage.read(key: _businessIdKey);
  }

  @override
  Future<void> deleteBusinessId() async {
    await _secureStorage.delete(key: _businessIdKey);
  }
}
