import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/repositories/audio_event_repository.dart';
import '../../application/usecases/analyze_recording_usecase.dart';

enum RecordingAnalysisStatus { idle, analyzing, done, error }

class RecordingAnalysisState {
  final RecordingAnalysisStatus status;
  final List<AudioEvent> events;

  const RecordingAnalysisState({
    required this.status,
    required this.events,
  });

  RecordingAnalysisState copyWith({
    RecordingAnalysisStatus? status,
    List<AudioEvent>? events,
  }) {
    return RecordingAnalysisState(
      status: status ?? this.status,
      events: events ?? this.events,
    );
  }

  static const initial = RecordingAnalysisState(
    status: RecordingAnalysisStatus.idle,
    events: [],
  );
}

class RecordingAnalysisNotifier
    extends StateNotifier<RecordingAnalysisState> {
  RecordingAnalysisNotifier() : super(RecordingAnalysisState.initial);

  // 表示専用の分析（DBには保存しない）
  Future<void> analyze(String filePath) async {
    state = state.copyWith(
      status: RecordingAnalysisStatus.analyzing,
      events: [],
    );

    final useCase = AnalyzeRecordingUseCase(_NoOpAudioEventRepository());

    try {
      final events = await useCase.execute('preview', filePath);
      print('🎯 RecordingAnalysis: 検出 ${events.length}件');
      state = state.copyWith(
        status: RecordingAnalysisStatus.done,
        events: events,
      );
    } catch (e) {
      print('🔴 RecordingAnalysis: 分析エラー - $e');
      state = state.copyWith(status: RecordingAnalysisStatus.error);
    } finally {
      useCase.dispose();
    }
  }

  void reset() {
    state = RecordingAnalysisState.initial;
  }
}

final recordingAnalysisProvider = StateNotifierProvider<
    RecordingAnalysisNotifier, RecordingAnalysisState>((ref) {
  return RecordingAnalysisNotifier();
});

// 表示専用：DBに保存しないリポジトリ
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
  ) async =>
      [];
}
