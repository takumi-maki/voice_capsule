import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
import 'child_avatar.dart';

class TimelineHeader extends ConsumerWidget {
  const TimelineHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childProfileProvider);
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
          child != null
              ? ChildAvatar(child: child, size: 40)
              : const Icon(Icons.account_circle, size: 40),
        ],
      ),
    );
  }
}
