import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'Русский';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter'),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildListTile(
            icon: FontAwesomeIcons.user,
            title: 'Аккаунт',
            subtitle: user?.email ?? 'Войти',
            onTap: () {
              if (user == null) {
                context.push('/auth');
              } else {
                context.push('/profile', extra: user.email);
              }
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildListTile(
            icon: FontAwesomeIcons.globe,
            title: 'Язык',
            subtitle: _selectedLanguage,
            onTap: () async {
              final result = await context.push<String>('/language');
              if (result != null) {
                setState(() => _selectedLanguage = result);
              }
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildListTile(
            icon: FontAwesomeIcons.bell,
            title: 'Уведомления',
            subtitle: 'Настройки уведомлений',
            onTap: () => context.push('/notifications'),
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildListTile(
            icon: FontAwesomeIcons.circleInfo,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: _showAboutDialog,
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required dynamic icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      tileColor: AppColors.surface,
      leading: SizedBox(
        width: 24,
        child: Center(
          child: FaIcon(icon, size: 20, color: iconColor ?? AppColors.accent),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter'),
            )
          : null,
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Версия 1.0.0',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconBtn(FontAwesomeIcons.telegram, 'Telegram'),
                _iconBtn(FontAwesomeIcons.instagram, 'Instagram'),
                _iconBtn(FontAwesomeIcons.tiktok, 'TikTok'),
                _iconBtn(FontAwesomeIcons.youtube, 'YouTube'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'))
        ],
      ),
    );
  }

  Widget _iconBtn(dynamic icon, String name) => IconButton(
        icon: FaIcon(icon, color: AppColors.accent, size: 24),
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Открыть $name')));
        },
      );
}
