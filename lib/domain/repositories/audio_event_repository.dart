import '../entities/audio_event.dart';

abstract class AudioEventRepository {
  Future<void> saveEvents(List<AudioEvent> events);
  Future<List<AudioEvent>> getEventsByRecordingId(String recordingId);
  Future<List<AudioEvent>> getEventsByDateRange(DateTime from, DateTime to);
}
