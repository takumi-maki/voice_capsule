import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingTimerNotifier extends StateNotifier<Duration> {
  Timer? _timer;

  RecordingTimerNotifier() : super(Duration.zero);

  void start() {
    _timer?.cancel();
    state = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = Duration(seconds: state.inSeconds + 1);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = Duration(seconds: state.inSeconds + 1);
    });
  }

  void reset() {
    _timer?.cancel();
    state = Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final recordingTimerProvider =
    StateNotifierProvider<RecordingTimerNotifier, Duration>((ref) {
      return RecordingTimerNotifier();
    });
