import 'package:flutter/material.dart';
import '../../../../domain/entities/audio_event.dart';
import '../../../../domain/models/stats_data.dart';

class TodayEmotionCard extends StatelessWidget {
  final StatsData stats;

  const TodayEmotionCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${stats.todayPoints} pts',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          stats.todayEvents.isEmpty
              ? Text(
                  'No moments captured today',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.6),
                  ),
                )
              : Wrap(
                  spacing: 4,
                  children: stats.todayEvents
                      .map((e) => Text(
                            e.type == EventType.laugh ? '😆' : '😭',
                            style: const TextStyle(fontSize: 24),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}
