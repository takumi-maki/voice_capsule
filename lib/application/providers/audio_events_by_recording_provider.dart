import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../infrastructure/repositories/audio_event_repository_impl.dart';

final audioEventsByRecordingProvider =
    FutureProvider.family<List<AudioEvent>, String>((ref, recordingId) async {
      return AudioEventRepositoryImpl().getEventsByRecordingId(recordingId);
    });
