import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/recording_timer_provider.dart';

class RecordingTimer extends ConsumerWidget {
  const RecordingTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(recordingTimerProvider);
    final theme = Theme.of(context);

    return Text(
      _formatDuration(duration),
      style: theme.textTheme.headlineSmall?.copyWith(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}