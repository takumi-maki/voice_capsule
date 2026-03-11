import 'package:flutter/material.dart';

class EmotionSummaryCard extends StatelessWidget {
  final int laughCount;
  final int cryCount;

  const EmotionSummaryCard({
    super.key,
    required this.laughCount,
    required this.cryCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: _SummaryChip(emoji: '😆', count: laughCount, label: 'Laughs', theme: theme)),
        const SizedBox(width: 16),
        Expanded(child: _SummaryChip(emoji: '😭', count: cryCount, label: 'Cries', theme: theme)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String emoji;
  final int count;
  final String label;
  final ThemeData theme;

  const _SummaryChip({
    required this.emoji,
    required this.count,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
