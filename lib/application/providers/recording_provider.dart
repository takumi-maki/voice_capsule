import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../infrastructure/repositories/audio_recorder_repository_impl.dart';

enum RecordingState { idle, recording, stopped }

class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioRecorderRepositoryImpl _repository;
  String? _currentFilePath;

  RecordingNotifier(this._repository) : super(RecordingState.idle);

  String? get currentFilePath => _currentFilePath;

  Future<void> startRecording() async {
    if (state == RecordingState.recording) return;

    final hasPermission = await _repository.hasPermission();
    if (!hasPermission) {
      final granted = await _repository.requestPermission();
      if (!granted) return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    _currentFilePath = '${dir.path}/recording_$timestamp.aac';

    await _repository.startRecording(_currentFilePath!);
    state = RecordingState.recording;
  }

  Future<String?> stopRecording() async {
    if (state != RecordingState.recording) return null;

    final path = await _repository.stopRecording();
    state = RecordingState.stopped;
    return path;
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

final recordingProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier(AudioRecorderRepositoryImpl());
});
