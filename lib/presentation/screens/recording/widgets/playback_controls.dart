import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/audio_player_provider.dart';
import '../../../../application/providers/recording_provider.dart';
import '../../../../application/providers/recording_timer_provider.dart';
import '../../save_recording_screen.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              context,
              icon: Icons.replay_10,
              onTap: () =>
                  ref.read(audioPlayerProvider.notifier).skipBackward(),
            ),
            const SizedBox(width: 32),
            _buildLargePlayButton(
              context,
              isPlaying: audioPlayerState.isPlaying,
              onTap: () => _togglePlayPause(ref, audioPlayerState.isPlaying),
            ),
            const SizedBox(width: 32),
            _buildControlButton(
              context,
              icon: Icons.forward_10,
              onTap: () => ref.read(audioPlayerProvider.notifier).skipForward(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Action buttons
        _buildPrimaryButton(
          context,
          label: 'Save to Memories',
          onTap: () => _saveRecording(context, ref),
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          context,
          label: 'Discard and Retry',
          onTap: () => _retryRecording(context, ref),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

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

  Widget _buildLargePlayButton(
    BuildContext context, {
    required bool isPlaying,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
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

  void _togglePlayPause(WidgetRef ref, bool isPlaying) {
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
    if (isPlaying) {
      audioPlayerNotifier.pause();
    } else {
      audioPlayerNotifier.resume();
    }
  }

  void _saveRecording(BuildContext context, WidgetRef ref) {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final filePath = recordingNotifier.currentFilePath;

    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SaveRecordingScreen(filePath: filePath),
        ),
      );
    }
  }

  void _retryRecording(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音をやり直しますか？'),
        content: const Text('現在の録音が削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('やり直し'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
      final recordingNotifier = ref.read(recordingProvider.notifier);
      final timerNotifier = ref.read(recordingTimerProvider.notifier);

      await audioPlayerNotifier.stop();
      await recordingNotifier.resetRecording();
      timerNotifier.reset();
    }
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
