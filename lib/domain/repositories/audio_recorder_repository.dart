abstract class AudioRecorderRepository {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<void> startRecording(String filePath);
  Future<String?> stopRecording();
  Future<bool> isRecording();
}
