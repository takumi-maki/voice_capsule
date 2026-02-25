import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrimmingRange {
  final Duration start;
  final Duration end;
  final Duration totalDuration;

  TrimmingRange({
    required this.start,
    required this.end,
    required this.totalDuration,
  });

  Duration get duration => end - start;

  bool get isValid =>
      start < end &&
      duration >= const Duration(seconds: 1) &&
      start >= Duration.zero &&
      end <= totalDuration;

  TrimmingRange copyWith({Duration? start, Duration? end}) {
    return TrimmingRange(
      start: start ?? this.start,
      end: end ?? this.end,
      totalDuration: totalDuration,
    );
  }
}

class TrimmingNotifier extends StateNotifier<TrimmingRange?> {
  TrimmingNotifier() : super(null);

  void initialize(Duration totalDuration) {
    state = TrimmingRange(
      start: Duration.zero,
      end: totalDuration,
      totalDuration: totalDuration,
    );
  }

  void setStart(Duration start) {
    if (state == null) return;
    final newState = state!.copyWith(start: start);
    if (newState.isValid) {
      state = newState;
    }
  }

  void setEnd(Duration end) {
    if (state == null) return;
    final newState = state!.copyWith(end: end);
    if (newState.isValid) {
      state = newState;
    }
  }

  void reset() {
    state = null;
  }
}

final trimmingProvider =
    StateNotifierProvider<TrimmingNotifier, TrimmingRange?>((ref) {
      return TrimmingNotifier();
    });
