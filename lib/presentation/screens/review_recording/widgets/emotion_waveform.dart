import 'package:flutter/material.dart';
import '../../../../domain/entities/audio_event.dart';

class EmotionWaveform extends StatelessWidget {
  final List<double> bars;
  final List<AudioEvent> events;
  final Duration duration;
  final bool isAnalyzing;
  final bool scrollable;

  const EmotionWaveform({
    super.key,
    required this.bars,
    required this.events,
    required this.duration,
    required this.isAnalyzing,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: isAnalyzing
          ? _buildLoading(theme)
          : scrollable
              ? _buildScrollableContent(theme)
              : _buildFixedContent(context, theme),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return SizedBox(
      height: 130,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('分析中...', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(ThemeData theme) {
    if (bars.isEmpty) return const SizedBox(height: 130);

    final totalWidth = bars.length * 5.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildWaveformStack(theme, totalWidth),
    );
  }

  Widget _buildFixedContent(BuildContext context, ThemeData theme) {
    if (bars.isEmpty) return const SizedBox(height: 130);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return _buildWaveformStack(theme, width);
      },
    );
  }

  SizedBox _buildWaveformStack(ThemeData theme, double totalWidth) {
    return SizedBox(
      width: totalWidth,
      height: 130,
      child: Stack(
        children: [
          _buildBars(theme, totalWidth),
          ..._buildMarkers(theme, totalWidth),
        ],
      ),
    );
  }

  Widget _buildBars(ThemeData theme, double width) {
    const barsHeight = 60.0;
    final eventBarIndices = _calcEventBarIndices();

    return Positioned(
      left: 0,
      right: scrollable ? null : 0,
      bottom: 0,
      height: barsHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(bars.length, (i) {
          final h = (bars[i] * 56 + 4).clamp(4.0, 60.0);
          final isEvent = eventBarIndices.contains(i);
          final barDecoration = BoxDecoration(
            color: isEvent
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          );

          if (scrollable) {
            return Container(
              width: 4.0,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: barDecoration,
            );
          }
          return Expanded(
            child: Container(
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: barDecoration,
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildMarkers(ThemeData theme, double width) {
    if (duration.inMilliseconds == 0) return [];

    return events.map((event) {
      final fraction = (event.timestamp / duration.inSeconds).clamp(0.0, 1.0);
      final centerX = fraction * width;
      final leftPos = (centerX - 20).clamp(0.0, width - 40.0);
      final emoji = event.type == EventType.laugh ? '😂' : '😭';
      final label = _formatTimestamp(event.timestamp);

      return Positioned(
        left: leftPos,
        top: 0,
        width: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            Container(
              width: 1,
              height: 14,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      );
    }).toList();
  }

  Set<int> _calcEventBarIndices() {
    if (duration.inMilliseconds == 0 || bars.isEmpty) return {};
    return events.map((e) {
      return (e.timestamp / duration.inSeconds * bars.length)
          .round()
          .clamp(0, bars.length - 1);
    }).toSet();
  }

  String _formatTimestamp(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).round();
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
