import 'package:just_audio/just_audio.dart';
import '../../domain/repositories/audio_player_repository.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> load(String filePath) async {
    print('🎵 AudioPlayer: ファイルロード開始 - $filePath');
    await _player.setFilePath(filePath);
    print('🎵 AudioPlayer: ファイルロード完了');
  }

  @override
  Future<void> play(String filePath, {String? title}) async {
    print('🎵 AudioPlayer: 再生開始 - $filePath');
    final source = AudioSource.file(
      filePath,
      tag: {'id': filePath, 'title': title ?? 'VoiceCapsule'},
    );
    await _player.setAudioSource(source);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    print('🎵 AudioPlayer: pause() 呼び出し');
    await _player.pause();
  }

  @override
  Future<void> resume() async {
    print('🎵 AudioPlayer: resume() 呼び出し');
    await _player.play();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<void> get playbackCompletedStream => _player.playerStateStream
      .where((state) => state.processingState == ProcessingState.completed)
      .map((_) {});

  @override
  void dispose() {
    _player.dispose();
  }
}
