import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/emotion_heatmap_provider.dart';
import '../../../domain/entities/daily_emotion_summary.dart';
import '../../widgets/stats/emotion_summary_card.dart';
import '../../widgets/stats/emotion_heatmap_grid.dart';
import '../../widgets/stats/daily_summary_card.dart';
import '../../widgets/stats/monthly_goal_card.dart';

class EmotionHeatmapScreen extends ConsumerWidget {
  const EmotionHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = ref.watch(selectedMonthProvider);
    final summariesAsync = ref.watch(emotionHeatmapProvider);
    final monthlySummary = ref.watch(monthlySummaryProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Emotion Heatmap'),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _pickMonth(context, ref, month),
          ),
        ],
      ),
      body: summariesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (summaries) => _buildContent(
          context,
          ref,
          summaries,
          selectedDate,
          monthlySummary,
          month,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<DailyEmotionSummary> summaries,
    DateTime? selectedDate,
    ({int laugh, int cry, int points}) monthly,
    DateTime month,
  ) {
    // 選択日のサマリー（デフォルトは今日か最後の記録日）
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DailyEmotionSummary displaySummary;

    if (selectedDate != null) {
      displaySummary = summaries.firstWhere(
        (s) => s.date.day == selectedDate.day,
        orElse: () => summaries.first,
      );
    } else {
      // 当月で今日または最後に記録がある日
      final withEvents = summaries.where((s) => s.totalEvents > 0).toList();
      if (withEvents.isNotEmpty) {
        final todaySummary = withEvents.where(
          (s) => s.date.year == today.year &&
              s.date.month == today.month &&
              s.date.day == today.day,
        ).firstOrNull;
        displaySummary = todaySummary ?? withEvents.last;
      } else {
        displaySummary = summaries.isNotEmpty
            ? summaries.first
            : DailyEmotionSummary(
                date: today,
                laughCount: 0,
                cryCount: 0,
                totalPoints: 0,
              );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          EmotionSummaryCard(
            laughCount: monthly.laugh,
            cryCount: monthly.cry,
          ),
          const SizedBox(height: 16),
          EmotionHeatmapGrid(
            month: month,
            summaries: summaries,
            selectedDate: selectedDate ?? displaySummary.date,
            onDayTapped: (date) {
              ref.read(selectedDateProvider.notifier).state = date;
            },
          ),
          const SizedBox(height: 16),
          DailySummaryCard(
            summary: displaySummary,
            onViewMoments: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(height: 16),
          MonthlyGoalCard(totalPoints: monthly.points),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final now = DateTime.now();
    // 前後矢印で月切り替え（BottomSheet）
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MonthPickerSheet(
        current: current,
        maxMonth: DateTime(now.year, now.month),
        onSelected: (m) {
          ref.read(selectedMonthProvider.notifier).state = m;
          ref.read(selectedDateProvider.notifier).state = null;
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _MonthPickerSheet extends StatefulWidget {
  final DateTime current;
  final DateTime maxMonth;
  final ValueChanged<DateTime> onSelected;

  const _MonthPickerSheet({
    required this.current,
    required this.maxMonth,
    required this.onSelected,
  });

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late DateTime _displayed;

  @override
  void initState() {
    super.initState();
    _displayed = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canGoForward = _displayed.isBefore(widget.maxMonth);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _displayed = DateTime(_displayed.year, _displayed.month - 1);
                }),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_displayed),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: canGoForward
                    ? () => setState(() {
                        _displayed = DateTime(_displayed.year, _displayed.month + 1);
                      })
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => widget.onSelected(_displayed),
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }
}
