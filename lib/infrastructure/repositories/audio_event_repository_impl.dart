import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/repositories/audio_event_repository.dart';

const _storageKey = 'audio_events';

class AudioEventRepositoryImpl implements AudioEventRepository {
  Future<List<AudioEvent>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map((e) => AudioEvent.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<AudioEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, raw);
  }

  @override
  Future<void> saveEvents(List<AudioEvent> events) async {
    final existing = await _loadAll();
    existing.addAll(events);
    await _saveAll(existing);
  }

  @override
  Future<List<AudioEvent>> getEventsByRecordingId(String recordingId) async {
    final all = await _loadAll();
    return all.where((e) => e.recordingId == recordingId).toList();
  }

  @override
  Future<List<AudioEvent>> getEventsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    // recordingIdからdateを引く手段が現状ないため、全件返す（将来対応）
    return _loadAll();
  }
}
