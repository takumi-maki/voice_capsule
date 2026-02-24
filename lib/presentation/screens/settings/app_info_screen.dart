import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('アプリ情報')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.mic, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'VoiceCapsule',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'バージョン 1.0.0',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ビルド番号: 1',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildInfoCard(
            context,
            title: 'ライセンス情報',
            onTap: () => _showLicenses(context),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: '開発者情報',
            subtitle: '© 2024 VoiceCapsule',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'VoiceCapsule',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.mic,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
