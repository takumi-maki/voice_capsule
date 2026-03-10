import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/trimming_provider.dart';
import '../../application/providers/recording_analysis_provider.dart';
import '../../domain/entities/audio_event.dart';
import 'recording/widgets/recording_button.dart';
import 'recording/widgets/recording_timer.dart';
import 'recording/widgets/waveform_visualizer.dart';
import 'recording/widgets/playback_progress_bar.dart';
import 'recording/widgets/playback_controls.dart';
import 'recording/widgets/trimming_slider.dart';

class RecordingScreen extends ConsumerWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    final isPlaybackMode =
        audioPlayerState.isPlaying || recordingState == RecordingState.stopped;

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
              if (isPlaybackMode) ...[
                const PlaybackControls(),
                const SizedBox(height: 24),
                _buildAnalysisResult(ref, theme),
                const SizedBox(height: 8),
                _buildTrimmingSection(ref, audioPlayerState),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrimmingSection(WidgetRef ref, AudioPlayerState audioState) {
    final trimmingRange = ref.watch(trimmingProvider);
    final theme = Theme.of(ref.context);

    if (trimmingRange == null && audioState.duration > Duration.zero) {
      return TextButton.icon(
        onPressed: () {
          ref.read(trimmingProvider.notifier).initialize(audioState.duration);
        },
        icon: Icon(Icons.content_cut, color: theme.colorScheme.primary),
        label: Text(
          'Trim Audio',
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      );
    }

    if (trimmingRange != null) {
      return const TrimmingSlider();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAnalysisResult(WidgetRef ref, ThemeData theme) {
    final analysis = ref.watch(recordingAnalysisProvider);

    if (analysis.status == RecordingAnalysisStatus.analyzing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text('分析中...', style: theme.textTheme.bodySmall),
        ],
      );
    }

    if (analysis.status == RecordingAnalysisStatus.done &&
        analysis.events.isEmpty) {
      return Text(
        '笑い声・泣き声は検出されませんでした',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
        textAlign: TextAlign.center,
      );
    }

    if (analysis.events.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: analysis.events.map((e) => _buildEventChip(e, theme)).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEventChip(AudioEvent event, ThemeData theme) {
    final isLaugh = event.type == EventType.laugh;
    final icon = isLaugh ? '😄' : '😢';
    final label = isLaugh ? '笑い声' : '泣き声';
    final pct = (event.score * 100).round();
    final sec = event.timestamp.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '$icon $label $pct% @ ${sec}s',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
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
      case RecordingState.paused:
        return 'Recording paused. Tap play to resume';
      case RecordingState.stopped:
        return 'Recording complete! Play, save, or try again';
    }
  }
}
