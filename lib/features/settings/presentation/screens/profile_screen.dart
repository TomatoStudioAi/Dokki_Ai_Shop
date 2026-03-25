import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String currentEmail;

  const ProfileScreen({super.key, required this.currentEmail});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _notify(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accent,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Сменить пароль',
            style:
                TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Текущий пароль',
                  labelStyle: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Новый пароль',
                  labelStyle: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Повторите новый пароль',
                  labelStyle: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                _notify('Пароли не совпадают', isError: true);
                return;
              }
              if (newPasswordController.text.length < 6) {
                _notify('Пароль должен быть минимум 6 символов', isError: true);
                return;
              }

              // TODO: Supabase.auth.updateUser(password: newPasswordController.text)

              Navigator.pop(c);
              _notify('Пароль успешно изменён');
            },
            child: const Text('Сохранить',
                style: TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
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
          ListTile(
            tileColor: AppColors.surface,
            leading: const Icon(Icons.lock_outline, color: AppColors.accent),
            title: const Text(
              'Сменить пароль',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            tileColor: AppColors.surface,
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }
}
