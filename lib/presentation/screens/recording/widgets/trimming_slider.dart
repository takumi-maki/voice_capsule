import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/trimming_provider.dart';
import '../../../../application/providers/audio_player_provider.dart';

class TrimmingSlider extends ConsumerWidget {
  const TrimmingSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmingRange = ref.watch(trimmingProvider);
    final theme = Theme.of(context);

    if (trimmingRange == null) return const SizedBox.shrink();

    final totalMs = trimmingRange.totalDuration.inMilliseconds.toDouble();
    if (totalMs == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trim Audio',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            trimmingRange.start.inMilliseconds.toDouble(),
            trimmingRange.end.inMilliseconds.toDouble(),
          ),
          min: 0,
          max: totalMs,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          onChanged: (values) {
            _onRangeChanged(ref, values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(trimmingRange.start),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDuration(trimmingRange.end),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previewTrimmed(ref, trimmingRange),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onRangeChanged(WidgetRef ref, RangeValues values) {
    final notifier = ref.read(trimmingProvider.notifier);
    notifier.setStart(Duration(milliseconds: values.start.round()));
    notifier.setEnd(Duration(milliseconds: values.end.round()));
  }

  void _previewTrimmed(WidgetRef ref, TrimmingRange range) {
    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    audioNotifier.seek(range.start);
    audioNotifier.resume();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
