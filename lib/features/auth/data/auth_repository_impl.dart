import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';
import '../domain/secure_storage_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final SecureStorageRepository _secureStorage;

  AuthRepositoryImpl(this._supabase, this._secureStorage);

  @override
  Future<void> signUp({required String email, required String password}) async {
    final response =
        await _supabase.auth.signUp(email: email, password: password);
    final user = response.user;

    if (user == null) {
      throw Exception('Ошибка регистрации: пользователь не создан');
    }

    await _secureStorage.saveBusinessId(user.id);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final response = await _supabase.auth
        .signInWithPassword(email: email, password: password);
    final user = response.user;

    if (user == null) {
      throw Exception('Ошибка входа: пользователь не найден');
    }

    await _secureStorage.saveBusinessId(user.id);
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.deleteBusinessId();
    await _supabase.auth.signOut();
  }

  @override
  Stream<bool> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map(
      (event) => event.session != null,
    );
  }
}
