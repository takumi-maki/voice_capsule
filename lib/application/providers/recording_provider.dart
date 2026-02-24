import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../infrastructure/repositories/audio_recorder_repository_impl.dart';
import '../../domain/entities/recording.dart';
import 'recording_list_provider.dart';
import 'child_profile_provider.dart';

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

  Future<void> saveRecording(
    WidgetRef ref,
    String title,
    BackgroundType location,
  ) async {
    if (_currentFilePath == null) return;

    final childProfile = ref.read(childProfileProvider);
    if (childProfile == null) return;

    final recording = Recording(
      id: const Uuid().v4(),
      filePath: _currentFilePath!,
      createdAt: DateTime.now(),
      title: title,
      location: location,
      childId: childProfile.id,
      duration: 0,
    );

    await ref.read(recordingListProvider.notifier).addRecording(recording);
  }

  Future<void> resetRecording() async {
    if (state == RecordingState.recording) {
      await _repository.stopRecording();
    }
    _currentFilePath = null;
    state = RecordingState.idle;
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
