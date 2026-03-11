import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/entities/daily_emotion_summary.dart';
import '../../infrastructure/repositories/audio_event_repository_impl.dart';
import 'recording_list_provider.dart';

/// 選択中の月 (year, month のみ使用)
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// 選択日
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final emotionHeatmapProvider =
    FutureProvider<List<DailyEmotionSummary>>((ref) async {
      final month = ref.watch(selectedMonthProvider);
      final recordings = ref.watch(recordingListProvider);
      final repo = AudioEventRepositoryImpl();

      // 当月の録音のみ抽出
      final monthRecordings = recordings.where((r) {
        return r.createdAt.year == month.year &&
            r.createdAt.month == month.month;
      }).toList();

      // 並列でイベント取得
      final eventLists = await Future.wait(
        monthRecordings.map((r) => repo.getEventsByRecordingId(r.id)),
      );

      // 日付 → (laugh, cry) の集計
      final Map<int, ({int laugh, int cry})> byDay = {};
      for (var i = 0; i < monthRecordings.length; i++) {
        final day = monthRecordings[i].createdAt.day;
        final events = eventLists[i];
        final laugh = events.where((e) => e.type == EventType.laugh).length;
        final cry = events.where((e) => e.type == EventType.cry).length;
        final existing = byDay[day];
        byDay[day] = (
          laugh: (existing?.laugh ?? 0) + laugh,
          cry: (existing?.cry ?? 0) + cry,
        );
      }

      // 当月の全日数分のサマリーを生成
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      return List.generate(daysInMonth, (i) {
        final day = i + 1;
        final data = byDay[day];
        return DailyEmotionSummary(
          date: DateTime(month.year, month.month, day),
          laughCount: data?.laugh ?? 0,
          cryCount: data?.cry ?? 0,
          totalPoints: (data?.laugh ?? 0) + (data?.cry ?? 0),
        );
      });
    });

/// 当月の合計笑い・泣き
final monthlySummaryProvider = Provider<({int laugh, int cry, int points})>(
  (ref) {
    final summaries = ref.watch(emotionHeatmapProvider).valueOrNull ?? [];
    final laugh = summaries.fold(0, (s, d) => s + d.laughCount);
    final cry = summaries.fold(0, (s, d) => s + d.cryCount);
    return (laugh: laugh, cry: cry, points: laugh + cry);
  },
);
