import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/providers/recording_provider.dart';
import '../../../../application/providers/audio_player_provider.dart';
import '../../../../application/providers/recording_timer_provider.dart';

class RecordingControls extends ConsumerWidget {
  const RecordingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final theme = Theme.of(context);

    if (recordingState != RecordingState.stopped) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          context,
          icon: Icons.play_arrow,
          label: 'Play',
          onTap: () => _playRecording(ref),
        ),
        _buildControlButton(
          context,
          icon: Icons.save,
          label: 'Save',
          onTap: () => _saveRecording(context, ref),
        ),
        _buildControlButton(
          context,
          icon: Icons.refresh,
          label: 'Retry',
          onTap: () => _retryRecording(context, ref),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _playRecording(WidgetRef ref) async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
    
    final filePath = recordingNotifier.currentFilePath;
    if (filePath != null) {
      await audioPlayerNotifier.play(filePath);
    }
  }

  void _saveRecording(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to save screen with character and background selection
    // For now, just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save functionality coming soon')),
    );
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
      final recordingNotifier = ref.read(recordingProvider.notifier);
      final timerNotifier = ref.read(recordingTimerProvider.notifier);
      
      await recordingNotifier.resetRecording();
      timerNotifier.reset();
    }
  }
}