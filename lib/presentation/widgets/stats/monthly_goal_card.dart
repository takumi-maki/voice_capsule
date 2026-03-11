import 'package:flutter/material.dart';

class MonthlyGoalCard extends StatelessWidget {
  final int totalPoints;

  const MonthlyGoalCard({super.key, required this.totalPoints});

  String get _message {
    if (totalPoints >= 100) return 'Amazing month! Keep it up!';
    if (totalPoints >= 50) return 'Great progress this month!';
    if (totalPoints >= 10) return 'Good start – keep capturing moments!';
    return 'Start capturing moments to earn points!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY GOAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalPoints pts',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 36)),
        ],
      ),
    );
  }
}
