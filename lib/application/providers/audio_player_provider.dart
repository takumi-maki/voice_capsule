import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories/audio_player_repository_impl.dart';

class AudioPlayerNotifier extends StateNotifier<bool> {
  final AudioPlayerRepositoryImpl _repository;

  AudioPlayerNotifier(this._repository) : super(false);

  Future<void> play(String filePath) async {
    await _repository.play(filePath);
    state = true;
  }

  Future<void> pause() async {
    await _repository.pause();
    state = false;
  }

  Future<void> stop() async {
    await _repository.stop();
    state = false;
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, bool>((ref) {
  return AudioPlayerNotifier(AudioPlayerRepositoryImpl());
});
