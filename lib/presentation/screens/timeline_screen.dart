import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../domain/entities/recording.dart';
import '../widgets/child_avatar.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingListProvider);
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
    final child = ref.watch(childProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('タイムライン')),
      body: recordings.isEmpty
          ? const Center(child: Text('まだ録音がありません'))
          : ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: child != null
                        ? ChildAvatar(child: child, size: 48)
                        : null,
                    title: Text(
                      recording.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${recording.location.displayName} • ${_formatDate(recording.createdAt)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 32,
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

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }
}
