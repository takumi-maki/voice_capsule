import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/models/stats_data.dart';
import '../../infrastructure/repositories/audio_event_repository_impl.dart';
import 'recording_list_provider.dart';

final statsProvider = FutureProvider<StatsData>((ref) async {
  final recordings = ref.watch(recordingListProvider);
  final repo = AudioEventRepositoryImpl();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 今週の月曜日
  final thisMonday = today.subtract(Duration(days: today.weekday - 1));
  // 先週の月〜日
  final lastMonday = thisMonday.subtract(const Duration(days: 7));
  final lastSunday = thisMonday.subtract(const Duration(days: 1));

  // 今週の録音
  final thisWeekRecordings = recordings.where((r) {
    final d = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
    return !d.isBefore(thisMonday) && !d.isAfter(today);
  }).toList();

  // 先週の録音
  final lastWeekRecordings = recordings.where((r) {
    final d = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
    return !d.isBefore(lastMonday) && !d.isAfter(lastSunday);
  }).toList();

  // 今日の録音
  final todayRecordings = recordings.where((r) {
    final d = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
    return d == today;
  }).toList();

  // 並列でイベント取得
  final thisWeekEventLists = await Future.wait(
    thisWeekRecordings.map((r) => repo.getEventsByRecordingId(r.id)),
  );
  final lastWeekEventLists = await Future.wait(
    lastWeekRecordings.map((r) => repo.getEventsByRecordingId(r.id)),
  );

  final todayEvents = <AudioEvent>[];
  for (var i = 0; i < todayRecordings.length; i++) {
    final recordingIdx = thisWeekRecordings.indexOf(todayRecordings[i]);
    if (recordingIdx >= 0) {
      todayEvents.addAll(thisWeekEventLists[recordingIdx]);
    }
  }

  final allThisWeekEvents = thisWeekEventLists.expand((e) => e).toList();
  final allLastWeekEvents = lastWeekEventLists.expand((e) => e).toList();

  // 曜日別イベント数
  final weeklyEventsByDay = <int, int>{};
  for (var i = 0; i < thisWeekRecordings.length; i++) {
    final weekday = thisWeekRecordings[i].createdAt.weekday;
    final count = thisWeekEventLists[i].length;
    weeklyEventsByDay[weekday] = (weeklyEventsByDay[weekday] ?? 0) + count;
  }

  // ストリーク計算
  final recordingDates = recordings
      .map((r) => DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day))
      .toSet();
  var streakDays = 0;
  var checkDate = today;
  while (recordingDates.contains(checkDate)) {
    streakDays++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return StatsData(
    todayEvents: todayEvents,
    weeklyPoints: allThisWeekEvents.length,
    lastWeekPoints: allLastWeekEvents.length,
    weeklyEventsByDay: weeklyEventsByDay,
    laughCount: allThisWeekEvents
        .where((e) => e.type == EventType.laugh)
        .length,
    cryCount: allThisWeekEvents
        .where((e) => e.type == EventType.cry)
        .length,
    streakDays: streakDays,
  );
});
