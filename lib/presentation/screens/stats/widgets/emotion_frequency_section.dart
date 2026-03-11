import 'package:flutter/material.dart';
import '../../../../domain/models/stats_data.dart';

class EmotionFrequencySection extends StatelessWidget {
  final StatsData stats;

  const EmotionFrequencySection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stats.laughCount + stats.cryCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion Frequency',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _FrequencyBar(
          emoji: '😆',
          label: 'Laughter',
          count: stats.laughCount,
          total: total,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _FrequencyBar(
          emoji: '😭',
          label: 'Cries',
          count: stats.cryCount,
          total: total,
          color: theme.colorScheme.error,
        ),
      ],
    );
  }
}

class _FrequencyBar extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final int total;
  final Color color;

  const _FrequencyBar({
    required this.emoji,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '$count events',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
