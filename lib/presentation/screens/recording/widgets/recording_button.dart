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

    if (recordingState == RecordingState.idle) {
      return _buildMicButton(ref, theme);
    }

    return _buildRecordingControls(context, ref, recordingState, theme);
  }

  Widget _buildMicButton(WidgetRef ref, ThemeData theme) {
    return GestureDetector(
      onTap: () => _startRecording(ref),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.mic, size: 48, color: Colors.white),
      ),
    );
  }

  Widget _buildRecordingControls(
    BuildContext context,
    WidgetRef ref,
    RecordingState state,
    ThemeData theme,
  ) {
    final isPaused = state == RecordingState.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          icon: Icons.close,
          color: Colors.white,
          iconColor: Colors.grey,
          size: 56,
          onTap: () => _showDiscardDialog(context, ref),
        ),
        const SizedBox(width: 24),
        _buildCircleButton(
          icon: isPaused ? Icons.play_arrow : Icons.pause,
          color: theme.colorScheme.primary,
          iconColor: Colors.white,
          size: 80,
          iconSize: 40,
          onTap: () => _togglePause(ref, isPaused),
        ),
        const SizedBox(width: 24),
        _buildCircleButton(
          icon: Icons.check,
          color: Colors.white,
          iconColor: Colors.grey,
          size: 56,
          onTap: () => _stopRecording(ref),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    double iconSize = 24,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }

  void _startRecording(WidgetRef ref) async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final timerNotifier = ref.read(recordingTimerProvider.notifier);
    await recordingNotifier.startRecording();
    timerNotifier.start();
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

  void _stopRecording(WidgetRef ref) async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final timerNotifier = ref.read(recordingTimerProvider.notifier);

    final filePath = await recordingNotifier.stopRecording();
    timerNotifier.stop();

    if (filePath == null) {
      print('🔴 RecordingButton: filePath が null のためエラーダイアログを表示');
      _showErrorDialog(ref);
    } else {
      print('🎵 RecordingButton: load() 開始 - filePath=$filePath');
      final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
      await audioPlayerNotifier.load(filePath);
      print('🎵 RecordingButton: load() 完了 - duration=${ref.read(audioPlayerProvider).duration}');
    }
  }

  void _showDiscardDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音を破棄'),
        content: const Text('現在の録音を破棄しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('破棄', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final recordingNotifier = ref.read(recordingProvider.notifier);
      final timerNotifier = ref.read(recordingTimerProvider.notifier);
      await recordingNotifier.resetRecording();
      timerNotifier.reset();
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
}
