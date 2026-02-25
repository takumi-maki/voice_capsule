import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

class CategoryIcon extends StatelessWidget {
  final BackgroundType category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(_getIcon(), color: Colors.white, size: size * 0.5),
    );
  }

  IconData _getIcon() {
    switch (category) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }
}
