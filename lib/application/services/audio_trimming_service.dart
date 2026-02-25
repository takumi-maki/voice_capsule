import 'dart:io';

class AudioTrimmingService {
  /// AAC ファイルをバイトレベルでトリミング
  /// 精度は限定的だが、外部パッケージ不要
  Future<String> trimAudio({
    required String inputPath,
    required Duration startTime,
    required Duration endTime,
    required Duration totalDuration,
  }) async {
    final inputFile = File(inputPath);
    final bytes = await inputFile.readAsBytes();
    final totalBytes = bytes.length;

    if (totalDuration.inMilliseconds == 0) {
      throw Exception('Total duration is zero');
    }

    final startRatio = startTime.inMilliseconds / totalDuration.inMilliseconds;
    final endRatio = endTime.inMilliseconds / totalDuration.inMilliseconds;

    final startByte = (totalBytes * startRatio).round();
    final endByte = (totalBytes * endRatio).round();

    final trimmedBytes = bytes.sublist(
      startByte.clamp(0, totalBytes),
      endByte.clamp(0, totalBytes),
    );

    final outputPath = inputPath.replaceAll('.aac', '_trimmed.aac');
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(trimmedBytes);

    return outputPath;
  }
}
