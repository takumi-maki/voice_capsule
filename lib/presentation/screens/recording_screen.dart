import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../domain/entities/recording.dart';
import 'timeline_screen.dart';
import 'character_selection_screen.dart';
import 'background_selection_screen.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  CharacterType _selectedCharacter = CharacterType.son;
  BackgroundType _selectedBackground = BackgroundType.house;

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimelineScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              recordingState == RecordingState.recording
                  ? Icons.mic
                  : Icons.mic_none,
              size: 100,
              color: recordingState == RecordingState.recording
                  ? Colors.red
                  : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              recordingState == RecordingState.recording
                  ? 'Recording...'
                  : 'Ready',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                if (recordingState == RecordingState.recording) {
                  final path = await recordingNotifier.stopRecording();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved: $path')),
                    );
                  }
                } else {
                  await recordingNotifier.startRecording();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: Text(
                recordingState == RecordingState.recording ? 'Stop' : 'Start',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (recordingState == RecordingState.stopped &&
                recordingNotifier.currentFilePath != null)
              const SizedBox(height: 24),
            if (recordingState == RecordingState.stopped &&
                recordingNotifier.currentFilePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final character = await Navigator.push<CharacterType>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CharacterSelectionScreen(),
                        ),
                      );
                      if (character != null) {
                        setState(() {
                          _selectedCharacter = character;
                        });
                      }
                    },
                    icon: const Icon(Icons.person),
                    label: Text(_selectedCharacter.name),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final background = await Navigator.push<BackgroundType>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BackgroundSelectionScreen(),
                        ),
                      );
                      if (background != null) {
                        setState(() {
                          _selectedBackground = background;
                        });
                      }
                    },
                    icon: const Icon(Icons.place),
                    label: Text(_selectedBackground.name),
                  ),
                ],
              ),
            if (recordingState == RecordingState.stopped &&
                recordingNotifier.currentFilePath != null)
              const SizedBox(height: 16),
            if (recordingState == RecordingState.stopped &&
                recordingNotifier.currentFilePath != null)
              ElevatedButton.icon(
                onPressed: () async {
                  await recordingNotifier.saveRecording(
                    ref,
                    _selectedCharacter,
                    _selectedBackground,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved!')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }
}
