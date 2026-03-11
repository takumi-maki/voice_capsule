import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/trimming_provider.dart';
import '../../application/providers/review_recording_provider.dart';
import '../../application/providers/recording_timer_provider.dart';
import 'recording/widgets/recording_button.dart';
import 'recording/widgets/recording_timer.dart';
import 'recording/widgets/waveform_visualizer.dart';
import 'recording/widgets/playback_progress_bar.dart';
import 'recording/widgets/playback_controls.dart';
import 'recording/widgets/trimming_slider.dart';
import 'review_recording/widgets/emotion_waveform.dart';
import 'review_recording/widgets/emotion_points_card.dart';
import 'save_recording_screen.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final isReviewMode = recordingState == RecordingState.stopped;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Voice')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isReviewMode ? _buildReviewMode() : _buildRecordingMode(),
      ),
    );
  }

  Widget _buildRecordingMode() {
    final recordingState = ref.watch(recordingProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const ValueKey('recording'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _getStateMessage(recordingState, audioState),
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const WaveformVisualizer(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            const RecordingButton(),
            const SizedBox(height: 48),
            const RecordingTimer(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewMode() {
    final reviewState = ref.watch(reviewRecordingProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const ValueKey('review'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildEmotionHeader(theme),
            const SizedBox(height: 24),
            EmotionWaveform(
              bars: reviewState.waveformBars,
              events: reviewState.events,
              duration: audioState.duration,
              isAnalyzing: reviewState.isAnalyzing,
            ),
            const SizedBox(height: 24),
            const PlaybackControls(),
            const SizedBox(height: 16),
            const PlaybackProgressBar(),
            const SizedBox(height: 24),
            EmotionPointsCard(points: reviewState.events.length),
            const SizedBox(height: 24),
            _buildSaveButton(theme),
            const SizedBox(height: 16),
            _buildDeleteButton(theme),
            const SizedBox(height: 8),
            _buildTrimmingSection(audioState),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMOTION DETECTION',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "We've mapped your feelings",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveToMemories,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Save to Memories'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: _deleteRecording,
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        label: Text(
          'Delete',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildTrimmingSection(AudioPlayerState audioState) {
    final trimmingRange = ref.watch(trimmingProvider);
    final theme = Theme.of(context);

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

  void _saveToMemories() {
    final filePath = ref.read(recordingProvider.notifier).currentFilePath;
    if (filePath == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveRecordingScreen(filePath: filePath),
      ),
    );
  }

  Future<void> _deleteRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音を削除しますか？'),
        content: const Text('この録音は完全に削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final filePath = ref.read(recordingProvider.notifier).currentFilePath;

    await ref.read(audioPlayerProvider.notifier).stop();
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    }

    await ref.read(recordingProvider.notifier).resetRecording();
    ref.read(recordingTimerProvider.notifier).reset();
    ref.read(reviewRecordingProvider.notifier).reset();
    ref.read(trimmingProvider.notifier).reset();
  }

  String _getStateMessage(
    RecordingState recordingState,
    AudioPlayerState audioState,
  ) {
    switch (recordingState) {
      case RecordingState.idle:
        return 'Tap the microphone to start recording your voice capsule';
      case RecordingState.recording:
        return 'Recording... Speak clearly into your device';
      case RecordingState.paused:
        return 'Recording paused. Tap play to resume';
      case RecordingState.stopped:
        return '';
    }
  }
}
