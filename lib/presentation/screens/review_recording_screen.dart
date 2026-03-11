import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/recording_timer_provider.dart';
import '../../application/providers/review_recording_provider.dart';
import 'review_recording/widgets/emotion_waveform.dart';
import 'review_recording/widgets/emotion_points_card.dart';
import 'save_recording_screen.dart';
import '../screens/recording/widgets/playback_progress_bar.dart';

class ReviewRecordingScreen extends ConsumerStatefulWidget {
  final String filePath;

  const ReviewRecordingScreen({super.key, required this.filePath});

  @override
  ConsumerState<ReviewRecordingScreen> createState() =>
      _ReviewRecordingScreenState();
}

class _ReviewRecordingScreenState extends ConsumerState<ReviewRecordingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewRecordingProvider.notifier).initAnalysis(widget.filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewRecordingProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Recording')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              EmotionWaveform(
                bars: reviewState.waveformBars,
                events: reviewState.events,
                duration: audioState.duration,
                isAnalyzing: reviewState.isAnalyzing,
              ),
              const SizedBox(height: 24),
              _buildPlaybackControls(audioState, theme),
              const SizedBox(height: 16),
              const PlaybackProgressBar(),
              const SizedBox(height: 24),
              EmotionPointsCard(points: reviewState.events.length),
              const SizedBox(height: 24),
              _buildSaveButton(context, theme),
              const SizedBox(height: 16),
              _buildDeleteButton(context, theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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

  Widget _buildPlaybackControls(AudioPlayerState audioState, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          theme,
          icon: Icons.replay_10,
          onTap: () => ref.read(audioPlayerProvider.notifier).skipBackward(),
        ),
        const SizedBox(width: 32),
        _buildPlayButton(theme, audioState.isPlaying),
        const SizedBox(width: 32),
        _buildControlButton(
          theme,
          icon: Icons.forward_10,
          onTap: () => ref.read(audioPlayerProvider.notifier).skipForward(),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    ThemeData theme, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
    );
  }

  Widget _buildPlayButton(ThemeData theme, bool isPlaying) {
    return GestureDetector(
      onTap: () {
        final notifier = ref.read(audioPlayerProvider.notifier);
        isPlaying ? notifier.pause() : notifier.resume();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _saveToMemories(context),
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

  Widget _buildDeleteButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: () => _deleteRecording(context),
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

  void _saveToMemories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveRecordingScreen(filePath: widget.filePath),
      ),
    );
  }

  Future<void> _deleteRecording(BuildContext context) async {
    final navigator = Navigator.of(context);
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

    await ref.read(audioPlayerProvider.notifier).stop();

    final file = File(widget.filePath);
    if (await file.exists()) await file.delete();

    await ref.read(recordingProvider.notifier).resetRecording();
    ref.read(recordingTimerProvider.notifier).reset();
    ref.read(reviewRecordingProvider.notifier).reset();

    if (mounted) {
      navigator.popUntil((route) => route.isFirst);
    }
  }
}
