import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../infrastructure/repositories/audio_event_repository_impl.dart';
import 'recording_list_provider.dart';

class TodaySummary {
  final int laughCount;
  final int cryCount;
  final int totalPoints;

  const TodaySummary({
    required this.laughCount,
    required this.cryCount,
    required this.totalPoints,
  });
}

final todaySummaryProvider = FutureProvider<TodaySummary>((ref) async {
  final recordings = ref.watch(recordingListProvider);
  final repo = AudioEventRepositoryImpl();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayRecordings = recordings.where((r) {
    final d = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
    return d == today;
  }).toList();

  final eventLists = await Future.wait(
    todayRecordings.map((r) => repo.getEventsByRecordingId(r.id)),
  );

  final allEvents = eventLists.expand((e) => e).toList();

  return TodaySummary(
    laughCount: allEvents.where((e) => e.type == EventType.laugh).length,
    cryCount: allEvents.where((e) => e.type == EventType.cry).length,
    totalPoints: allEvents.length,
  );
});
