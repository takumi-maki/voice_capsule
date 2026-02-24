import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import 'recording/widgets/recording_button.dart';
import 'recording/widgets/recording_timer.dart';
import 'recording/widgets/waveform_visualizer.dart';
import 'recording/widgets/playback_progress_bar.dart';
import 'recording/widgets/playback_controls.dart';

class RecordingScreen extends ConsumerWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    final isPlaybackMode =
        audioPlayerState.isPlaying ||
        (recordingState == RecordingState.stopped &&
            audioPlayerState.duration.inMilliseconds > 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Record Voice')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _getStateMessage(recordingState, audioPlayerState),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const WaveformVisualizer(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              const RecordingButton(),
              const SizedBox(height: 48),
              if (isPlaybackMode) ...[
                const PlaybackProgressBar(),
              ] else ...[
                const RecordingTimer(),
              ],
              const SizedBox(height: 24),
              if (isPlaybackMode) ...[const PlaybackControls()],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getStateMessage(
    RecordingState recordingState,
    AudioPlayerState audioPlayerState,
  ) {
    if (audioPlayerState.isPlaying) {
      return 'Playing your voice capsule...';
    }

    switch (recordingState) {
      case RecordingState.idle:
        return 'Tap the microphone to start recording your voice capsule';
      case RecordingState.recording:
        return 'Recording... Speak clearly into your device';
      case RecordingState.stopped:
        return 'Recording complete! Play, save, or try again';
    }
  }
}
