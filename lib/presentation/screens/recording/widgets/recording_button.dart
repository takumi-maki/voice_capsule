import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/recording_provider.dart';
import '../../../../application/providers/recording_timer_provider.dart';

class RecordingButton extends ConsumerWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final theme = Theme.of(context);

    // stopped状態時はマイクボタンを非表示
    if (recordingState == RecordingState.stopped) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _handleTap(ref),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _getButtonColor(recordingState, theme),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          _getButtonIcon(recordingState),
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleTap(WidgetRef ref) async {
    final recordingState = ref.read(recordingProvider);
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final timerNotifier = ref.read(recordingTimerProvider.notifier);

    switch (recordingState) {
      case RecordingState.idle:
        await recordingNotifier.startRecording();
        timerNotifier.start();
        break;
      case RecordingState.recording:
        await recordingNotifier.stopRecording();
        timerNotifier.stop();
        break;
      case RecordingState.stopped:
        timerNotifier.reset();
        break;
    }
  }

  Color _getButtonColor(RecordingState state, ThemeData theme) {
    switch (state) {
      case RecordingState.idle:
        return theme.colorScheme.primary;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.stopped:
        return theme.colorScheme.primary;
    }
  }

  IconData _getButtonIcon(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
        return Icons.stop;
      case RecordingState.stopped:
        return Icons.mic;
    }
  }
}