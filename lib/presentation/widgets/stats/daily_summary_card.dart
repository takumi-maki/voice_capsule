import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/daily_emotion_summary.dart';

class DailySummaryCard extends StatelessWidget {
  final DailyEmotionSummary summary;
  final VoidCallback? onViewMoments;

  const DailySummaryCard({
    super.key,
    required this.summary,
    this.onViewMoments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = DateFormat('EEEE').format(summary.date);
    final monthDay = DateFormat('MMMM d').format(summary.date);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthDay,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${summary.totalPoints} pts',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (summary.totalEvents > 0) ...[
            Wrap(
              spacing: 2,
              children: [
                ...List.generate(summary.laughCount, (_) => const Text('😆', style: TextStyle(fontSize: 18))),
                ...List.generate(summary.cryCount, (_) => const Text('😭', style: TextStyle(fontSize: 18))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.totalEvents} moment${summary.totalEvents == 1 ? '' : 's'} captured',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ] else
            Text(
              'No moments yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewMoments,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('View Moments'),
            ),
          ),
        ],
      ),
    );
  }
}
