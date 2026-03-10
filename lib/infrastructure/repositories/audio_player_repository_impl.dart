import 'package:just_audio/just_audio.dart';
import '../../domain/repositories/audio_player_repository.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerRepositoryImpl() {
    // プレーヤー状態変化を全てログ出力
    _player.playerStateStream.listen((state) {
      print('🎵 [PlayerState] playing=${state.playing}, processingState=${state.processingState}');
    });

    // エラーイベントをキャッチ
    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        print('🔴 [PlaybackError] $e');
        print('🔴 [PlaybackError] StackTrace: $st');
      },
    );
  }

  @override
  Future<void> load(String filePath) async {
    print('🎵 AudioPlayer: ファイルロード開始 - $filePath');
    try {
      final duration = await _player.setFilePath(filePath);
      print('🎵 AudioPlayer: ファイルロード完了 - duration=$duration');
      print('🎵 AudioPlayer: processingState=${_player.processingState}');
    } catch (e, st) {
      print('🔴 AudioPlayer: setFilePath エラー - $e');
      print('🔴 AudioPlayer: StackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> play(String filePath, {String? title}) async {
    print('🎵 AudioPlayer: 再生開始 - $filePath');
    try {
      final source = AudioSource.file(
        filePath,
        tag: {'id': filePath, 'title': title ?? 'VoiceCapsule'},
      );
      final duration = await _player.setAudioSource(source);
      print('🎵 AudioPlayer: setAudioSource 完了 - duration=$duration');
      print('🎵 AudioPlayer: play() 呼び出し前 processingState=${_player.processingState}');
      await _player.play();
      print('🎵 AudioPlayer: play() 完了');
    } catch (e, st) {
      print('🔴 AudioPlayer: play エラー - $e');
      print('🔴 AudioPlayer: StackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    print('🎵 AudioPlayer: pause() 呼び出し');
    await _player.pause();
  }

  @override
  Future<void> resume() async {
    print('🎵 AudioPlayer: resume() 呼び出し - processingState=${_player.processingState}, playing=${_player.playing}');
    try {
      await _player.play();
      print('🎵 AudioPlayer: resume() 完了 - playing=${_player.playing}');
    } catch (e, st) {
      print('🔴 AudioPlayer: resume エラー - $e');
      print('🔴 AudioPlayer: StackTrace: $st');
      rethrow;
    }
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
