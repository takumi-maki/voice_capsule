import '../entities/audio_event.dart';

class StatsData {
  final List<AudioEvent> todayEvents;
  final int weeklyPoints;
  final int lastWeekPoints;
  final Map<int, int> weeklyEventsByDay; // weekday 1=Mon〜7=Sun → count
  final int laughCount; // this week
  final int cryCount; // this week
  final int streakDays;

  const StatsData({
    required this.todayEvents,
    required this.weeklyPoints,
    required this.lastWeekPoints,
    required this.weeklyEventsByDay,
    required this.laughCount,
    required this.cryCount,
    required this.streakDays,
  });

  int get todayPoints => todayEvents.length;

  /// 先週比（%）。先週0件のときは null
  double? get weeklyPointsChange {
    if (lastWeekPoints == 0) return null;
    return (weeklyPoints - lastWeekPoints) / lastWeekPoints * 100;
  }
}
