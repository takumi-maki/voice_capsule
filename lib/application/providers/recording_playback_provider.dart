import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../infrastructure/audio/audio_analyzer.dart';
import '../../infrastructure/audio/yamnet_classifier.dart';
import '../../infrastructure/repositories/audio_event_repository_impl.dart';

class RecordingPlaybackState {
  final bool isLoading;
  final List<AudioEvent> events;
  final List<double> waveformBars;

  const RecordingPlaybackState({
    required this.isLoading,
    required this.events,
    required this.waveformBars,
  });

  static const initial = RecordingPlaybackState(
    isLoading: false,
    events: [],
    waveformBars: [],
  );

  RecordingPlaybackState copyWith({
    bool? isLoading,
    List<AudioEvent>? events,
    List<double>? waveformBars,
  }) {
    return RecordingPlaybackState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      waveformBars: waveformBars ?? this.waveformBars,
    );
  }
}

class RecordingPlaybackNotifier
    extends StateNotifier<RecordingPlaybackState> {
  RecordingPlaybackNotifier() : super(RecordingPlaybackState.initial);

  Future<void> load(
    String recordingId,
    String filePath, {
    int barCount = 60,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        AudioEventRepositoryImpl().getEventsByRecordingId(recordingId),
        AudioAnalyzer(YamnetClassifier()).extractAmplitudes(filePath, barCount),
      ]);

      state = state.copyWith(
        isLoading: false,
        events: results[0] as List<AudioEvent>,
        waveformBars: results[1] as List<double>,
      );
    } catch (e) {
      print('🔴 RecordingPlayback: ロードエラー - $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    state = RecordingPlaybackState.initial;
  }
}

final recordingPlaybackProvider =
    StateNotifierProvider<RecordingPlaybackNotifier, RecordingPlaybackState>(
  (ref) => RecordingPlaybackNotifier(),
);
