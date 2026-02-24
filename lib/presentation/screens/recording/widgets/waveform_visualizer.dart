import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/recording_provider.dart';

class WaveformVisualizer extends ConsumerStatefulWidget {
  const WaveformVisualizer({super.key});

  @override
  ConsumerState<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends ConsumerState<WaveformVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final theme = Theme.of(context);

    ref.listen(recordingProvider, (previous, next) {
      if (next == RecordingState.recording) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });

    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final animationValue = (_animationController.value + delay) % 1.0;
              final height = recordingState == RecordingState.recording
                  ? 20 + (40 * (0.5 + 0.5 * (animationValue * 2 - 1).abs()))
                  : 20.0;

              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}