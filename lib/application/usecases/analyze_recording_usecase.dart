import '../../domain/entities/audio_event.dart';
import '../../domain/repositories/audio_event_repository.dart';
import '../../infrastructure/audio/audio_analyzer.dart';
import '../../infrastructure/audio/yamnet_classifier.dart';

class AnalyzeRecordingUseCase {
  final AudioEventRepository _repository;
  YamnetClassifier? _classifier;

  AnalyzeRecordingUseCase(this._repository);

  Future<List<AudioEvent>> execute(String recordingId, String filePath) async {
    _classifier ??= YamnetClassifier();
    await _classifier!.load();

    final analyzer = AudioAnalyzer(_classifier!);
    final events = await analyzer.analyze(recordingId, filePath);

    if (events.isNotEmpty) {
      await _repository.saveEvents(events);
    }
    return events;
  }

  void dispose() {
    _classifier?.dispose();
    _classifier = null;
  }
}
