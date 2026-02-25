import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_list_provider.dart';
import '../widgets/timeline_header.dart';
import '../widgets/free_version_banner.dart';
import '../widgets/recording_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            const TimelineHeader(),
            const FreeVersionBanner(),
            Expanded(
              child: recordings.isEmpty
                  ? const Center(
                      child: Text(
                        'まだ録音がありません',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recordings.length,
                      itemBuilder: (context, index) {
                        final recording = recordings[index];
                        return RecordingCard(recording: recording);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
