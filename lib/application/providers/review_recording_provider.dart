import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/repositories/audio_event_repository.dart';
import '../../infrastructure/audio/audio_analyzer.dart';
import '../../infrastructure/audio/yamnet_classifier.dart';
import '../usecases/analyze_recording_usecase.dart';

class ReviewRecordingState {
  final bool isAnalyzing;
  final List<AudioEvent> events;
  final List<double> waveformBars;

  const ReviewRecordingState({
    required this.isAnalyzing,
    required this.events,
    required this.waveformBars,
  });

  ReviewRecordingState copyWith({
    bool? isAnalyzing,
    List<AudioEvent>? events,
    List<double>? waveformBars,
  }) => ReviewRecordingState(
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    events: events ?? this.events,
    waveformBars: waveformBars ?? this.waveformBars,
  );

  static const initial = ReviewRecordingState(
    isAnalyzing: false,
    events: [],
    waveformBars: [],
  );
}

class ReviewRecordingNotifier extends StateNotifier<ReviewRecordingState> {
  ReviewRecordingNotifier() : super(ReviewRecordingState.initial);

  // 波形抽出と YAMNet 分析を並列実行（DBには保存しない）
  Future<void> initAnalysis(String filePath, {int barCount = 60}) async {
    state = state.copyWith(isAnalyzing: true, events: [], waveformBars: []);

    List<double> waveformBars = [];
    List<AudioEvent> events = [];
    final useCase = AnalyzeRecordingUseCase(_NoOpAudioEventRepository());
    // extractAmplitudes は classifier を使用しないため未ロードで問題なし
    final analyzer = AudioAnalyzer(YamnetClassifier());

    try {
      await Future.wait([
        analyzer
            .extractAmplitudes(filePath, barCount)
            .then((bars) => waveformBars = bars),
        useCase
            .execute('preview', filePath)
            .then((evts) => events = evts),
      ]);
    } catch (e) {
      print('🔴 ReviewRecording: 分析エラー - $e');
    } finally {
      useCase.dispose();
    }

    state = state.copyWith(
      isAnalyzing: false,
      events: events,
      waveformBars: waveformBars,
    );
  }

  void reset() => state = ReviewRecordingState.initial;
}

final reviewRecordingProvider =
    StateNotifierProvider<ReviewRecordingNotifier, ReviewRecordingState>((ref) {
      return ReviewRecordingNotifier();
    });

class _NoOpAudioEventRepository implements AudioEventRepository {
  @override
  Future<void> saveEvents(List<AudioEvent> events) async {}

  @override
  Future<List<AudioEvent>> getEventsByRecordingId(String recordingId) async =>
      [];

  @override
  Future<List<AudioEvent>> getEventsByDateRange(
    DateTime from,
    DateTime to,
  ) async => [];
}
