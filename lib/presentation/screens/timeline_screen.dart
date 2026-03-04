import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../application/providers/active_child_provider.dart';
import '../widgets/timeline_header.dart';
import '../widgets/free_version_banner.dart';
import '../widgets/recording_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecordings = ref.watch(recordingListProvider);
    final activeChildId = ref.watch(activeChildProvider);

    final recordings = activeChildId == null
        ? allRecordings
        : allRecordings
              .where((r) => r.childIds.contains(activeChildId))
              .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const TimelineHeader(),
            const FreeVersionBanner(),
            Expanded(child: _buildList(context, recordings, activeChildId)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List recordings,
    String? activeChildId,
  ) {
    if (recordings.isEmpty) {
      final message = activeChildId != null ? 'この子供の録音はまだありません' : 'まだ録音がありません';
      return Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: recordings.length,
      itemBuilder: (context, index) =>
          RecordingCard(recording: recordings[index]),
    );
  }
}
