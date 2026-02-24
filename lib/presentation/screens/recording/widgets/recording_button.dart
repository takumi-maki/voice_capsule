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

    print('🔘 RecordingButton: タップ (state = $recordingState)');

    switch (recordingState) {
      case RecordingState.idle:
        print('🔘 RecordingButton: 録音開始処理');
        await recordingNotifier.startRecording();
        timerNotifier.start();
        print('🔘 RecordingButton: タイマー開始');
        break;
      case RecordingState.recording:
        print('🔘 RecordingButton: 録音停止処理');
        final filePath = await recordingNotifier.stopRecording();
        timerNotifier.stop();
        print('🔘 RecordingButton: タイマー停止');

        if (filePath == null) {
          print('🔘 RecordingButton: filePath が null - エラーダイアログ表示');
          _showErrorDialog(ref);
        } else {
          print('🔘 RecordingButton: 録音成功 - filePath = $filePath');
        }
        break;
      case RecordingState.stopped:
        print('🔘 RecordingButton: stopped 状態 - 何もしない');
        break;
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
