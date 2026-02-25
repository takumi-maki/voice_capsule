import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/recording_provider.dart';
import '../../../../application/providers/recording_timer_provider.dart';
import '../../../../application/providers/audio_player_provider.dart';

class RecordingButton extends ConsumerWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final theme = Theme.of(context);

    if (recordingState == RecordingState.stopped) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _handleTap(ref),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _getButtonColor(recordingState, theme),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
        ),
        if (recordingState == RecordingState.recording ||
            recordingState == RecordingState.paused) ...[
          const SizedBox(height: 24),
          _buildSecondaryControls(context, ref, recordingState),
        ],
      ],
    );
  }

  Widget _buildSecondaryControls(
    BuildContext context,
    WidgetRef ref,
    RecordingState recordingState,
  ) {
    final theme = Theme.of(context);
    final isPaused = recordingState == RecordingState.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _togglePause(ref, isPaused),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
      ],
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
      case RecordingState.paused:
        final filePath = await recordingNotifier.stopRecording();
        timerNotifier.stop();
        if (filePath == null) {
          _showErrorDialog(ref);
        } else {
          final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
          await audioPlayerNotifier.load(filePath);
        }
        break;
      case RecordingState.stopped:
        break;
    }
  }

  void _togglePause(WidgetRef ref, bool isPaused) async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final timerNotifier = ref.read(recordingTimerProvider.notifier);

    if (isPaused) {
      await recordingNotifier.resumeRecording();
      timerNotifier.resume();
    } else {
      await recordingNotifier.pauseRecording();
      timerNotifier.pause();
    }
  }

  void _showErrorDialog(WidgetRef ref) async {
    final context = ref.context;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音エラー'),
        content: const Text('録音の保存に失敗しました。もう一度お試しください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    final recordingNotifier = ref.read(recordingProvider.notifier);
    await recordingNotifier.resetRecording();
  }

  Color _getButtonColor(RecordingState state, ThemeData theme) {
    switch (state) {
      case RecordingState.idle:
        return theme.colorScheme.primary;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.paused:
        return Colors.red.withValues(alpha: 0.7);
      case RecordingState.stopped:
        return theme.colorScheme.primary;
    }
  }

  IconData _getButtonIcon(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
      case RecordingState.paused:
        return Icons.stop;
      case RecordingState.stopped:
        return Icons.mic;
    }
  }
}
