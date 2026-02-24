import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../application/providers/audio_player_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingListProvider);
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: recordings.isEmpty
          ? const Center(child: Text('No recordings yet'))
          : ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(
                      _getCharacterIcon(recording.character.name),
                      size: 40,
                    ),
                    title: Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(recording.createdAt),
                    ),
                    subtitle: Text(recording.background.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () async {
                        await audioPlayerNotifier.play(recording.filePath);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getCharacterIcon(String character) {
    switch (character) {
      case 'father':
        return Icons.man;
      case 'mother':
        return Icons.woman;
      case 'son':
        return Icons.boy;
      case 'daughter':
        return Icons.girl;
      default:
        return Icons.person;
    }
  }
}
