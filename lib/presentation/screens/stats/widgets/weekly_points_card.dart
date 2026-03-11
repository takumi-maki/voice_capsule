import 'package:flutter/material.dart';
import '../../../../domain/models/stats_data.dart';

class WeeklyPointsCard extends StatelessWidget {
  final StatsData stats;

  const WeeklyPointsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = stats.weeklyPointsChange;

    String changeText;
    Color changeColor;
    if (change == null) {
      changeText = '-';
      changeColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    } else if (change >= 0) {
      changeText = '+${change.toStringAsFixed(0)}% vs last week';
      changeColor = Colors.green;
    } else {
      changeText = '${change.toStringAsFixed(0)}% vs last week';
      changeColor = theme.colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Points',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.weeklyPoints}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            changeText,
            style: theme.textTheme.bodySmall?.copyWith(color: changeColor),
          ),
        ],
      ),
    );
  }
}
