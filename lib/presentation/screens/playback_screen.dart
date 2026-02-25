import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../domain/entities/recording.dart';
import 'recording/widgets/playback_progress_bar.dart';

class PlaybackScreen extends ConsumerStatefulWidget {
  final Recording recording;

  const PlaybackScreen({super.key, required this.recording});

  @override
  ConsumerState<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends ConsumerState<PlaybackScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    final notifier = ref.read(audioPlayerProvider.notifier);
    await notifier.play(widget.recording.filePath);
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final theme = Theme.of(context);

    ref.listen(audioPlayerProvider, (previous, next) {
      if (next.isPlaying) {
        _waveformController.repeat();
      } else {
        _waveformController.stop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recording.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildWaveform(theme, audioState),
            const SizedBox(height: 24),
            const PlaybackProgressBar(),
            const SizedBox(height: 24),
            _buildPlaybackControls(theme, audioState),
            const Spacer(),
            _buildActionButtons(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform(ThemeData theme, AudioPlayerState audioState) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveformController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final value = (_waveformController.value + delay) % 1.0;
              final height = audioState.isPlaying
                  ? 20 + (40 * (0.5 + 0.5 * (value * 2 - 1).abs()))
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

  Widget _buildPlaybackControls(ThemeData theme, AudioPlayerState audioState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          theme,
          icon: Icons.replay_10,
          onTap: () => ref.read(audioPlayerProvider.notifier).skipBackward(),
        ),
        const SizedBox(width: 24),
        _buildPlayButton(theme, audioState),
        const SizedBox(width: 24),
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

  Widget _buildPlayButton(ThemeData theme, AudioPlayerState audioState) {
    return GestureDetector(
      onTap: () => _togglePlayPause(audioState.isPlaying),
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
          audioState.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  void _togglePlayPause(bool isPlaying) {
    final notifier = ref.read(audioPlayerProvider.notifier);
    if (isPlaying) {
      notifier.pause();
    } else {
      notifier.resume();
    }
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareRecording(),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _deleteRecording(),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareRecording() async {
    // share_plus で共有
  }

  Future<void> _deleteRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音を削除'),
        content: const Text('この録音を削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(audioPlayerProvider.notifier).stop();
      await ref
          .read(recordingListProvider.notifier)
          .deleteRecording(widget.recording.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
