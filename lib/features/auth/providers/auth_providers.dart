import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../domain/secure_storage_repository.dart';
import '../data/secure_storage_repository_impl.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageRepositoryProvider =
    Provider<SecureStorageRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SecureStorageRepositoryImpl(secureStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final secureStorage = ref.watch(secureStorageRepositoryProvider);
  return AuthRepositoryImpl(supabase, secureStorage);
});

final authStateProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
