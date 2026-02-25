import 'package:flutter/material.dart';
import '../../../../domain/entities/recording.dart';

class SceneCard extends StatelessWidget {
  final BackgroundType type;
  final bool isSelected;
  final VoidCallback onTap;

  const SceneCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Icon(_getIcon(), size: 48, color: Colors.white),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BackgroundType.house:
        return Colors.teal[300]!;
      case BackgroundType.car:
        return Colors.blueGrey[400]!;
      case BackgroundType.park:
        return Colors.green[400]!;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }

  String _getLabel() {
    switch (type) {
      case BackgroundType.house:
        return 'HOUSE';
      case BackgroundType.car:
        return 'CAR';
      case BackgroundType.park:
        return 'PARK';
    }
  }
}
