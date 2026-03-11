import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/audio_player_provider.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          context,
          icon: Icons.replay_10,
          onTap: () => ref.read(audioPlayerProvider.notifier).skipBackward(),
        ),
        const SizedBox(width: 32),
        _buildLargePlayButton(
          context,
          isPlaying: audioPlayerState.isPlaying,
          onTap: () {
            final notifier = ref.read(audioPlayerProvider.notifier);
            audioPlayerState.isPlaying ? notifier.pause() : notifier.resume();
          },
        ),
        const SizedBox(width: 32),
        _buildControlButton(
          context,
          icon: Icons.forward_10,
          onTap: () => ref.read(audioPlayerProvider.notifier).skipForward(),
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
}
