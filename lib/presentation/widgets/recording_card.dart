import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/providers/audio_events_by_recording_provider.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../domain/entities/audio_event.dart';
import '../../domain/entities/child.dart';
import '../../domain/entities/recording.dart';
import '../screens/playback_screen.dart';

class RecordingCard extends ConsumerWidget {
  final Recording recording;

  const RecordingCard({super.key, required this.recording});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(audioEventsByRecordingProvider(recording.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaybackScreen(recording: recording),
          ),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, eventsAsync),
                const SizedBox(height: 8),
                _ChildRow(childIds: recording.childIds),
                const SizedBox(height: 8),
                _buildEmojis(eventsAsync),
                if (recording.waveformBars.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _WaveformBars(bars: recording.waveformBars),
                ],
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AsyncValue<List<AudioEvent>> eventsAsync) {
    final points = eventsAsync.valueOrNull?.length ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('h:mm a').format(recording.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+$points pt',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojis(AsyncValue<List<AudioEvent>> eventsAsync) {
    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (events) {
        if (events.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 2,
          children: events
              .map((e) => Text(
                    e.type == EventType.laugh ? '😆' : '😭',
                    style: const TextStyle(fontSize: 18),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        Text(
          _formatDuration(recording.duration),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.play_circle_outline,
          color: theme.colorScheme.primary,
          size: 28,
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _ChildRow extends ConsumerWidget {
  final List<String> childIds;

  const _ChildRow({required this.childIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Child>>(
      future: ref.read(childProfileProvider.notifier).getAllProfiles(),
      builder: (context, snapshot) {
        final allChildren = snapshot.data ?? [];
        final children = childIds
            .map((id) => allChildren.where((c) => c.id == id).firstOrNull)
            .whereType<Child>()
            .take(2)
            .toList();

        if (children.isEmpty) return const SizedBox.shrink();

        return Row(
          children: [
            SizedBox(
              width: children.length == 1 ? 24 : 36,
              height: 24,
              child: Stack(
                children: [
                  for (var i = 0; i < children.length; i++)
                    Positioned(
                      left: i * 16.0,
                      child: _MiniAvatar(child: children[i], theme: theme),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              children.map((c) => c.name).join(', '),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final Child child;
  final ThemeData theme;

  const _MiniAvatar({required this.child, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (child.photoPath != null && File(child.photoPath!).existsSync()) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: FileImage(File(child.photoPath!)),
      );
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        child.initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  final List<double> bars;

  const _WaveformBars({required this.bars});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bars.map((amplitude) {
          final height = (amplitude * 36).clamp(2.0, 36.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
