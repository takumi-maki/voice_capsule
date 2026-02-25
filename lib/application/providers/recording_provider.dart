import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../infrastructure/repositories/audio_recorder_repository_impl.dart';
import '../../domain/entities/recording.dart';
import 'recording_list_provider.dart';
import 'child_profile_provider.dart';

enum RecordingState { idle, recording, paused, stopped }

class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioRecorderRepositoryImpl _repository;
  String? _currentFilePath;

  RecordingNotifier(this._repository) : super(RecordingState.idle);

  String? get currentFilePath => _currentFilePath;

  Future<void> startRecording() async {
    print('🎤 startRecording: 開始');
    if (state == RecordingState.recording) {
      print('🎤 startRecording: すでに録音中のため終了');
      return;
    }

    print('🎤 startRecording: パーミッション確認');
    final hasPermission = await _repository.hasPermission();
    print('🎤 startRecording: パーミッション = $hasPermission');
    if (!hasPermission) {
      print('🎤 startRecording: パーミッション要求');
      final granted = await _repository.requestPermission();
      print('🎤 startRecording: パーミッション許可 = $granted');
      if (!granted) {
        print('🎤 startRecording: パーミッション拒否のため終了');
        return;
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    _currentFilePath = '${dir.path}/recording_$timestamp.aac';
    print('🎤 startRecording: ファイルパス = $_currentFilePath');

    print('🎤 startRecording: 録音開始');
    await _repository.startRecording(_currentFilePath!);
    state = RecordingState.recording;
    print('🎤 startRecording: 状態を recording に変更');
  }

  Future<String?> stopRecording() async {
    print('⏹️ stopRecording: 開始');
    if (state != RecordingState.recording && state != RecordingState.paused) {
      print('⏹️ stopRecording: 録音中/一時停止中ではないため終了 (state = $state)');
      return null;
    }

    print('⏹️ stopRecording: 録音停止');
    final path = await _repository.stopRecording();
    print('⏹️ stopRecording: 保存パス = $path');
    state = RecordingState.stopped;
    print('⏹️ stopRecording: 状態を stopped に変更');
    return path;
  }

  Future<void> pauseRecording() async {
    print('⏸️ pauseRecording: 開始');
    if (state != RecordingState.recording) {
      print('⏸️ pauseRecording: 録音中ではないため終了 (state = $state)');
      return;
    }
    await _repository.pauseRecording();
    state = RecordingState.paused;
    print('⏸️ pauseRecording: 状態を paused に変更');
  }

  Future<void> resumeRecording() async {
    print('▶️ resumeRecording: 開始');
    if (state != RecordingState.paused) {
      print('▶️ resumeRecording: 一時停止中ではないため終了 (state = $state)');
      return;
    }
    await _repository.resumeRecording();
    state = RecordingState.recording;
    print('▶️ resumeRecording: 状態を recording に変更');
  }

  Future<void> saveRecording(
    WidgetRef ref,
    String title,
    BackgroundType location,
  ) async {
    print('💾 saveRecording: 開始');
    print('💾 saveRecording: title = $title, location = $location');
    if (_currentFilePath == null) {
      print('💾 saveRecording: _currentFilePath が null のため終了');
      return;
    }
    print('💾 saveRecording: _currentFilePath = $_currentFilePath');

    final childProfile = ref.read(childProfileProvider);
    print('💾 saveRecording: childProfile = $childProfile');
    if (childProfile == null) {
      print('💾 saveRecording: childProfile が null のため終了');
      return;
    }

    final recording = Recording(
      id: const Uuid().v4(),
      filePath: _currentFilePath!,
      createdAt: DateTime.now(),
      title: title,
      location: location,
      childId: childProfile.id,
      duration: 0,
    );
    print('💾 saveRecording: Recording作成 = ${recording.id}');

    print('💾 saveRecording: recordingListProviderに追加');
    await ref.read(recordingListProvider.notifier).addRecording(recording);
    print('💾 saveRecording: 完了');
  }

  Future<void> resetRecording() async {
    print('🔄 resetRecording: 開始 (state = $state)');
    if (state == RecordingState.recording || state == RecordingState.paused) {
      print('🔄 resetRecording: 録音中/一時停止中のため停止');
      await _repository.stopRecording();
    }
    _currentFilePath = null;
    state = RecordingState.idle;
    print('🔄 resetRecording: 状態を idle に変更');
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
