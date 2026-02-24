import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories/audio_player_repository_impl.dart';

class AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  AudioPlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayerRepositoryImpl _repository;

  AudioPlayerNotifier(this._repository)
    : super(
        AudioPlayerState(
          isPlaying: false,
          position: Duration.zero,
          duration: Duration.zero,
        ),
      ) {
    _setupListeners();
  }

  void _setupListeners() {
    _repository.playingStream.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });

    _repository.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _repository.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _repository.playbackCompletedStream.listen((_) {
      _onPlaybackCompleted();
    });
  }

  void _onPlaybackCompleted() {
    state = state.copyWith(isPlaying: false);
  }

  Future<void> play(String filePath) async {
    await _repository.play(filePath);
  }

  Future<void> pause() async {
    await _repository.pause();
  }

  Future<void> resume() async {
    // 再生完了状態の場合は最初から再生
    if (state.position >= state.duration && state.duration > Duration.zero) {
      await seek(Duration.zero);
    }
    await _repository.resume();
  }

  Future<void> stop() async {
    await _repository.stop();
    state = state.copyWith(
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> seek(Duration position) async {
    await _repository.seek(position);
  }

  Future<void> skipForward() async {
    final newPosition = state.position + const Duration(seconds: 10);
    final maxPosition = state.duration;
    await seek(newPosition > maxPosition ? maxPosition : newPosition);
  }

  Future<void> skipBackward() async {
    final newPosition = state.position - const Duration(seconds: 10);
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier(AudioPlayerRepositoryImpl());
    });
