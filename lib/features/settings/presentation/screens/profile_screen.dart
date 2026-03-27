import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/supabase/supabase_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String currentEmail;

  const ProfileScreen({super.key, required this.currentEmail});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late AppStrings _s;

  void _notify(String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accent,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_s.profChangePass,
            style: const TextStyle(
                fontFamily: 'Inter', color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                  labelText: _s.profNewPass,
                  labelStyle: const TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                  labelText: _s.profRepeatPass,
                  labelStyle: const TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(_s.profCancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              // 1. Валидация совпадения
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                _notify(_s.profPassMismatch, isError: true);
                return;
              }
              // 2. Валидация длины
              if (newPasswordController.text.length < 6) {
                _notify(_s.profPassLength, isError: true);
                return;
              }

              try {
                // 3. Запрос в Supabase
                await ref.read(supabaseClientProvider).auth.updateUser(
                      UserAttributes(password: newPasswordController.text),
                    );

                // Защита: проверяем, что диалог еще открыт
                if (!c.mounted) return;
                Navigator.pop(c);
                _notify(_s.profPassSuccess);
              } catch (e) {
                _notify(_s.authError, isError: true);
              }
            },
            child: Text(_s.profSave,
                style: const TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    _s = s;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          s.profTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, color: AppColors.surface, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.currentEmail,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Смена пароля
          ListTile(
            tileColor: AppColors.surface,
            leading: const Icon(Icons.lock_outline, color: AppColors.accent),
            title: Text(
              s.profChangePass,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(color: AppColors.border, height: 1),
          // Выход из аккаунта
          ListTile(
            tileColor: AppColors.surface,
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              s.profLogout,
              style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () async {
              if (kDebugMode) debugPrint('=== DEBUG: Signing out ===');

              // 1. Вызываем логаут
              await ref.read(authRepositoryProvider).signOut();

              if (kDebugMode) debugPrint('=== DEBUG: Sign out SUCCESS ===');

              // 2. Явный редирект на экран входа с проверкой mounted
              if (context.mounted) {
                if (kDebugMode) debugPrint('→ Manual redirect to /auth');
                context.go('/auth');
              }
            },
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }
}
