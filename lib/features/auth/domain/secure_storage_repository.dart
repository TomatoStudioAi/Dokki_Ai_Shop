abstract class SecureStorageRepository {
  Future<void> saveBusinessId(String businessId);
  Future<String?> getBusinessId();
  Future<void> deleteBusinessId();
}
