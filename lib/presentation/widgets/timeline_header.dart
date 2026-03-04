import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/user_profile_provider.dart';
import '../screens/onboarding/user_profile_setup_screen.dart';

class TimelineHeader extends ConsumerWidget {
  const TimelineHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voice Timeline',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'VOICECAPSULE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserProfileSetupScreen(isEditing: true),
              ),
            ),
            child: _UserAvatar(user: user, theme: theme),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final dynamic user;
  final ThemeData theme;

  const _UserAvatar({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Icon(
        Icons.account_circle,
        size: 40,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      );
    }

    if (user.photoPath != null) {
      return CircleAvatar(
        key: ValueKey(user.photoPath),
        radius: 20,
        backgroundImage: FileImage(File(user.photoPath as String)),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      child: Text(
        user.initials as String,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
