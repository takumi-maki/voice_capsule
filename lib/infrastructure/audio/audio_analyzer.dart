import 'dart:io';
import 'dart:typed_data';
import '../../domain/entities/audio_event.dart';
import 'yamnet_classifier.dart';
import 'package:uuid/uuid.dart';

const int _sampleRate = 16000;
const int _windowSamples = 15360; // 0.96秒 × 16000Hz
const double _scoreThreshold = 0.6;

class AudioAnalyzer {
  final YamnetClassifier _classifier;

  AudioAnalyzer(this._classifier);

  Future<List<AudioEvent>> analyze(String recordingId, String filePath) async {
    final samples = await _loadWavSamples(filePath);
    if (samples.isEmpty) return [];

    final events = <AudioEvent>[];
    int offset = 0;

    while (offset + _windowSamples <= samples.length) {
      final window = samples.sublist(offset, offset + _windowSamples);
      final result = _classifier.classify(window);
      final timestamp = offset / _sampleRate;

      if (result.laughterScore >= _scoreThreshold) {
        events.add(_createEvent(recordingId, EventType.laugh, timestamp, result.laughterScore));
      }
      if (result.babyCryScore >= _scoreThreshold) {
        events.add(_createEvent(recordingId, EventType.cry, timestamp, result.babyCryScore));
      }

      offset += _windowSamples;
    }

    return events;
  }

  AudioEvent _createEvent(
    String recordingId,
    EventType type,
    double timestamp,
    double score,
  ) {
    return AudioEvent(
      id: const Uuid().v4(),
      recordingId: recordingId,
      type: type,
      timestamp: timestamp,
      score: score,
    );
  }

  // WAVファイルのPCMサンプルを[-1.0, 1.0]の範囲で読み込む
  Future<List<double>> _loadWavSamples(String filePath) async {
    final bytes = await File(filePath).readAsBytes();

    // WAVヘッダーは44バイト
    const headerSize = 44;
    if (bytes.length <= headerSize) return [];

    final pcmBytes = bytes.sublist(headerSize);
    final byteData = ByteData.sublistView(Uint8List.fromList(pcmBytes));
    final sampleCount = pcmBytes.length ~/ 2; // 16bit = 2bytes per sample

    return List<double>.generate(
      sampleCount,
      (i) => byteData.getInt16(i * 2, Endian.little) / 32768.0,
    );
  }
}
