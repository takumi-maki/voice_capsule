abstract class AudioRecorderRepository {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<void> startRecording(String filePath);
  Future<String?> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<bool> isRecording();
  Future<bool> isPaused();
}
