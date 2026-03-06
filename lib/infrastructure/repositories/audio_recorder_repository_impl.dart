import 'package:record/record.dart';
import '../../domain/repositories/audio_recorder_repository.dart';

class AudioRecorderRepositoryImpl implements AudioRecorderRepository {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<void> startRecording(String filePath) async {
    if (await hasPermission()) {
      print('🎙️ 録音開始: $filePath');
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );
    } else {
      print('⚠️ マイク権限がありません');
    }
  }

  @override
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    print('⏹️ 録音停止: $path');
    return path;
  }

  @override
  Future<void> pauseRecording() async {
    await _recorder.pause();
    print('⏸️ 録音一時停止');
  }

  @override
  Future<void> resumeRecording() async {
    await _recorder.resume();
    print('▶️ 録音再開');
  }

  @override
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  @override
  Future<bool> isPaused() async {
    return await _recorder.isPaused();
  }

  void dispose() {
    _recorder.dispose();
  }
}
