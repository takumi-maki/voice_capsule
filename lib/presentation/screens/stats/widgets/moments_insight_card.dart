import 'package:flutter/material.dart';
import '../../../../domain/models/stats_data.dart';

class MomentsInsightCard extends StatelessWidget {
  final StatsData stats;

  const MomentsInsightCard({super.key, required this.stats});

  String _buildMessage() {
    final laugh = stats.laughCount;
    final cry = stats.cryCount;
    final total = laugh + cry;

    if (total == 0) return 'No moments recorded this week yet.';

    if (laugh > cry) {
      final times = cry == 0 ? '' : '${(laugh / cry).toStringAsFixed(0)}x more ';
      return 'This week felt joyful. You recorded ${times}laughter than crying moments. Keep capturing these happy sounds!';
    } else {
      return 'This week felt challenging. You had more crying moments recorded. Every emotion is worth capturing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moments Insight',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _buildMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
