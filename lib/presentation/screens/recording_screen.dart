import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';

class RecordingScreen extends ConsumerWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final recordingNotifier = ref.read(recordingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
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
          ],
        ),
      ),
    );
  }
}
