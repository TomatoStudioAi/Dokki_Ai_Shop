import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

/// Провайдер для доступа к SharedPreferences.
/// Должен быть переопределен в main.dart через overrideWithValue.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// Провайдер для управления текущим языком приложения (Enum)
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

/// Нотификатор, обеспечивающий синхронную загрузку и сохранение языка
class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _key = 'app_language';
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs) : super(AppLanguage.en) {
    _loadLanguage();
  }

  /// Синхронная загрузка из уже инициализированного экземпляра SharedPreferences
  void _loadLanguage() {
    final savedLanguage = _prefs.getString(_key);

    if (savedLanguage != null) {
      try {
        state = AppLanguage.values.firstWhere(
          (e) => e.toString() == savedLanguage,
          orElse: () => AppLanguage.en,
        );
      } catch (_) {
        // В случае ошибки парсинга остается язык по умолчанию
      }
    }
  }

  /// Смена языка с немедленным сохранением в память устройства
  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;

    state = language;

    try {
      await _prefs.setString(_key, language.toString());
    } catch (_) {
      // Ошибки записи не критичны для работы приложения
    }
  }
}

/// Провайдер строк локализации — главный источник текстов для UI.
/// Автоматически пересоздается при изменении languageProvider.
final stringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(languageProvider);

  // Обновляем статический контекст для моделей, работающих вне Riverpod
  AppStrings.currentLanguage = language;

  return AppStrings(language);
});
