import 'package:tflite_flutter/tflite_flutter.dart';

// YAMNet AudioSetラベルインデックス
const int _laughterIndex = 13;
const int _babyCryIndex = 20;
const int _yamnetOutputSize = 521;

class YamnetResult {
  final double laughterScore;
  final double babyCryScore;

  YamnetResult({required this.laughterScore, required this.babyCryScore});
}

class YamnetClassifier {
  Interpreter? _interpreter;

  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset('assets/models/yamnet.tflite');
  }

  // inputSamples: 16kHz mono PCM、長さ15360（0.96秒分）
  YamnetResult classify(List<double> inputSamples) {
    assert(_interpreter != null, 'YamnetClassifier.load() を先に呼ぶこと');

    final input = [inputSamples];
    final output = [List<double>.filled(_yamnetOutputSize, 0.0)];

    _interpreter!.run(input, output);

    final scores = output[0];
    return YamnetResult(
      laughterScore: scores[_laughterIndex],
      babyCryScore: scores[_babyCryIndex],
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
