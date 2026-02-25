import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/child_profile_provider.dart';
import '../../../../domain/entities/recording.dart';
import '../../../widgets/child_avatar.dart';

class ScenePreview extends ConsumerWidget {
  final BackgroundType selectedType;

  const ScenePreview({super.key, required this.selectedType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childProfileProvider);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getIcon(),
              size: 80,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          if (child != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: ChildAvatar(child: child, size: 48),
            ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'PREVIEW MODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (selectedType) {
      case BackgroundType.house:
        return Colors.teal[300]!;
      case BackgroundType.car:
        return Colors.blueGrey[400]!;
      case BackgroundType.park:
        return Colors.green[400]!;
    }
  }

  IconData _getIcon() {
    switch (selectedType) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }
}
