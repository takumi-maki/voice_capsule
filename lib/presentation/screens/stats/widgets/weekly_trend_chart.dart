import 'package:flutter/material.dart';
import '../../../../domain/models/stats_data.dart';

class WeeklyTrendChart extends StatelessWidget {
  final StatsData stats;

  const WeeklyTrendChart({super.key, required this.stats});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = stats.weeklyEventsByDay.values.fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Trend',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final weekday = i + 1; // 1=Mon〜7=Sun
              final count = stats.weeklyEventsByDay[weekday] ?? 0;
              final ratio = maxCount == 0 ? 0.0 : count / maxCount;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: ratio < 0.05 ? 0.05 : ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
