import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/stats_provider.dart';
import 'stats/emotion_heatmap_screen.dart';
import 'stats/widgets/today_emotion_card.dart';
import 'stats/widgets/weekly_points_card.dart';
import 'stats/widgets/streak_card.dart';
import 'stats/widgets/emotion_frequency_section.dart';
import 'stats/widgets/weekly_trend_chart.dart';
import 'stats/widgets/moments_insight_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Stats',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmotionHeatmapScreen()),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TodayEmotionCard(stats: stats),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: WeeklyPointsCard(stats: stats)),
                  const SizedBox(width: 16),
                  Expanded(child: StreakCard(stats: stats)),
                ],
              ),
              const SizedBox(height: 24),
              EmotionFrequencySection(stats: stats),
              const SizedBox(height: 24),
              WeeklyTrendChart(stats: stats),
              const SizedBox(height: 24),
              MomentsInsightCard(stats: stats),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
