import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding/child_profile_setup_screen.dart';
import 'onboarding/user_profile_setup_screen.dart';
import 'settings/app_info_screen.dart';
import 'settings/privacy_policy_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.face,
            title: '自分のプロフィール編集',
            onTap: () => _navigateToUserProfileEdit(context),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.person,
            title: '子供のプロフィール編集',
            onTap: () => _navigateToProfileEdit(context),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            title: '通知設定',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.info,
            title: 'アプリ情報',
            onTap: () => _navigateToAppInfo(context),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip,
            title: 'プライバシーポリシー',
            onTap: () => _navigateToPrivacyPolicy(context),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _navigateToUserProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserProfileSetupScreen(isEditing: true),
      ),
    );
  }

  void _navigateToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildProfileSetupScreen(isEditing: true),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('この機能は準備中です')));
  }

  void _navigateToAppInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppInfoScreen()),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }
}
