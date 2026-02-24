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
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
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
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  void dispose() {
    _recorder.dispose();
  }
}
