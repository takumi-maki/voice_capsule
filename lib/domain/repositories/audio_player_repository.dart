abstract class AudioPlayerRepository {
  Future<void> load(String filePath);
  Future<void> play(String filePath);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Stream<bool> get playingStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<void> get playbackCompletedStream;
  void dispose();
}
