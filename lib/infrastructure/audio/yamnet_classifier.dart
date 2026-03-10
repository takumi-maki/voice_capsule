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
    _interpreter!.allocateTensors();

    // デバッグ: テンソル形状確認
    final inputTensor = _interpreter!.getInputTensor(0);
    print('🧠 YAMNet input shape: ${inputTensor.shape}, type: ${inputTensor.type}');
    for (var i = 0; i < _interpreter!.getOutputTensors().length; i++) {
      final t = _interpreter!.getOutputTensor(i);
      print('🧠 YAMNet output[$i] shape: ${t.shape}, type: ${t.type}');
    }
  }

  // inputSamples: 16kHz mono PCM、長さ15360（0.96秒分）
  YamnetResult classify(List<double> inputSamples) {
    assert(_interpreter != null, 'YamnetClassifier.load() を先に呼ぶこと');

    // YAMNet TFLiteは複数出力（scores, embeddings, spectrogram）
    final inputs = [inputSamples];
    final outputs = <int, Object>{
      0: [List<double>.filled(_yamnetOutputSize, 0.0)],
    };

    _interpreter!.runForMultipleInputs(inputs, outputs);

    final scores = (outputs[0]! as List<List<double>>)[0];
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
