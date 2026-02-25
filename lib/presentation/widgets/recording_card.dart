import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/recording.dart';
import '../screens/playback_screen.dart';
import 'category_icon.dart';

class RecordingCard extends ConsumerWidget {
  final Recording recording;

  const RecordingCard({super.key, required this.recording});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CategoryIcon(category: recording.location),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(theme),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recording.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _playRecording(ref),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Listen Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: _getThumbnailColor(theme),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getCategoryIcon(),
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryLabel(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThumbnailColor(ThemeData theme) {
    switch (recording.location) {
      case BackgroundType.house:
        return Colors.teal[300]!;
      case BackgroundType.car:
        return Colors.blueGrey[400]!;
      case BackgroundType.park:
        return Colors.green[400]!;
    }
  }

  IconData _getCategoryIcon() {
    switch (recording.location) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }

  String _getCategoryLabel() {
    switch (recording.location) {
      case BackgroundType.house:
        return 'HOME';
      case BackgroundType.car:
        return 'ON THE GO';
      case BackgroundType.park:
        return 'OUTDOOR';
    }
  }

  String _formatDateTime() {
    final date = DateFormat('MMM dd').format(recording.createdAt);
    final time = DateFormat('h:mm a').format(recording.createdAt);
    final duration = _formatDuration(recording.duration);
    return '$date • $time • $duration';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecording(WidgetRef ref) async {
    final context = ref.context;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaybackScreen(recording: recording)),
    );
  }
}
