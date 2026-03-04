import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/child.dart';

class ChildAvatar extends StatelessWidget {
  final Child child;
  final double size;

  const ChildAvatar({super.key, required this.child, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (child.photoPath != null && File(child.photoPath!).existsSync()) {
      return CircleAvatar(
        key: ValueKey(child.photoPath),
        radius: size / 2,
        backgroundImage: FileImage(File(child.photoPath!)),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        child.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
