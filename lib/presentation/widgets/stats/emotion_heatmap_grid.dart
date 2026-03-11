import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/daily_emotion_summary.dart';

// ヒートマップ専用カラー（デザイン仕様準拠）
const _colorNone = Color(0xFFF3E8DD);
const _colorLow = Color(0xFFF5CBA7);
const _colorMedium = Color(0xFFE89B57);
const _colorHigh = Color(0xFFC76B2A);

Color _intensityColor(HeatmapIntensity intensity) {
  switch (intensity) {
    case HeatmapIntensity.none:
      return _colorNone;
    case HeatmapIntensity.low:
      return _colorLow;
    case HeatmapIntensity.medium:
      return _colorMedium;
    case HeatmapIntensity.high:
      return _colorHigh;
  }
}

class EmotionHeatmapGrid extends StatelessWidget {
  final DateTime month;
  final List<DailyEmotionSummary> summaries;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDayTapped;

  const EmotionHeatmapGrid({
    super.key,
    required this.month,
    required this.summaries,
    required this.selectedDate,
    required this.onDayTapped,
  });

  static const _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

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
          _buildHeader(theme),
          const SizedBox(height: 8),
          _buildWeekLabels(theme),
          const SizedBox(height: 4),
          _buildGrid(theme, now),
          const SizedBox(height: 8),
          _buildLegend(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(month),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekLabels(ThemeData theme) {
    return Row(
      children: _weekLabels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGrid(ThemeData theme, DateTime now) {
    // 月の最初の日の曜日（1=Mon〜7=Sun）
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final daysInMonth = summaries.length;
    final totalCells = firstWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNumber = cellIndex - (firstWeekday - 1) + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox());
            }

            final summary = summaries[dayNumber - 1];
            final date = summary.date;
            final isFuture = date.isAfter(now);
            final isSelected = selectedDate != null &&
                selectedDate!.year == date.year &&
                selectedDate!.month == date.month &&
                selectedDate!.day == date.day;

            return Expanded(
              child: GestureDetector(
                onTap: isFuture ? null : () => onDayTapped(date),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFuture
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                            : _intensityColor(summary.intensity),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: theme.colorScheme.primary, width: 2)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'INTENSITY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        ...[ _colorNone, _colorLow, _colorMedium, _colorHigh].map(
          (c) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
