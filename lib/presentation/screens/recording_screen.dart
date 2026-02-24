import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import 'recording/widgets/recording_button.dart';
import 'recording/widgets/recording_timer.dart';
import 'recording/widgets/waveform_visualizer.dart';
import 'recording/widgets/recording_controls.dart';

class RecordingScreen extends ConsumerWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Voice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _getStateMessage(recordingState),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const RecordingTimer(),
            const SizedBox(height: 24),
            const WaveformVisualizer(),
            const Spacer(),
            const RecordingButton(),
            const SizedBox(height: 48),
            const RecordingControls(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getStateMessage(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return 'Tap the microphone to start recording your voice capsule';
      case RecordingState.recording:
        return 'Recording... Speak clearly into your device';
      case RecordingState.stopped:
        return 'Recording complete! Play, save, or try again';
    }
  }
}
