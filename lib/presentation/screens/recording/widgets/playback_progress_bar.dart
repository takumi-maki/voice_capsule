import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/audio_player_provider.dart';

class PlaybackProgressBar extends ConsumerWidget {
  const PlaybackProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTapDown: (details) =>
              _handleSeek(details.localPosition, ref, context),
          onHorizontalDragUpdate: (details) =>
              _handleSeek(details.localPosition, ref, context),
          child: Container(
            width: double.infinity,
            height: 24,
            child: Stack(
              children: [
                Positioned(
                  top: 11,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                if (audioPlayerState.duration.inMilliseconds > 0)
                  Positioned(
                    top: 11,
                    left: 0,
                    child: Container(
                      width: _getProgressWidth(audioPlayerState, context),
                      height: 2,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                if (audioPlayerState.duration.inMilliseconds > 0)
                  Positioned(
                    top: 7,
                    left: _getProgressWidth(audioPlayerState, context) - 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(audioPlayerState.position),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDuration(audioPlayerState.duration),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _getProgressWidth(AudioPlayerState state, BuildContext context) {
    if (state.duration.inMilliseconds == 0) return 0;

    final screenWidth = MediaQuery.of(context).size.width - 48;
    final progress =
        state.position.inMilliseconds / state.duration.inMilliseconds;
    return screenWidth * progress.clamp(0.0, 1.0);
  }

  void _handleSeek(Offset localPosition, WidgetRef ref, BuildContext context) {
    final audioPlayerState = ref.read(audioPlayerProvider);
    if (audioPlayerState.duration.inMilliseconds == 0) return;

    final screenWidth = MediaQuery.of(context).size.width - 48;
    final tapPosition = localPosition.dx;
    final progress = (tapPosition / screenWidth).clamp(0.0, 1.0);
    final seekPosition = Duration(
      milliseconds: (audioPlayerState.duration.inMilliseconds * progress)
          .round(),
    );

    ref.read(audioPlayerProvider.notifier).seek(seekPosition);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
