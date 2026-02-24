abstract class AudioPlayerRepository {
  Future<void> play(String filePath);
  Future<void> pause();
  Future<void> stop();
  Stream<bool> get playingStream;
  void dispose();
}
