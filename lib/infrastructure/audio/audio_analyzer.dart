import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import '../../domain/entities/audio_event.dart';
import 'yamnet_classifier.dart';
import 'package:uuid/uuid.dart';

const int _sampleRate = 16000;
const int _windowSamples = 15600; // モデルの実際の入力サイズ
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

    print('🔍 分析結果: ${events.length}件検出');
    for (final e in events) {
      print('  → ${e.type.name} score:${e.score.toStringAsFixed(2)} at ${e.timestamp.toStringAsFixed(1)}s');
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

  // 音声ファイルから barCount 個の正規化済み振幅を抽出する
  Future<List<double>> extractAmplitudes(String filePath, int barCount) async {
    final samples = await _loadWavSamples(filePath);
    if (samples.isEmpty || barCount <= 0) return List.filled(barCount, 0.0);

    final chunkSize = (samples.length / barCount).ceil().clamp(1, samples.length);
    final rmsValues = <double>[];

    for (int i = 0; i < barCount; i++) {
      final start = i * chunkSize;
      final end = (start + chunkSize).clamp(0, samples.length);
      if (start >= samples.length) {
        rmsValues.add(0.0);
        continue;
      }
      final chunk = samples.sublist(start, end);
      final meanSquare = chunk.fold(0.0, (sum, s) => sum + s * s) / chunk.length;
      rmsValues.add(sqrt(meanSquare));
    }

    final maxRms = rmsValues.reduce((a, b) => a > b ? a : b);
    if (maxRms == 0) return List.filled(barCount, 0.0);
    return rmsValues.map((v) => v / maxRms).toList();
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
