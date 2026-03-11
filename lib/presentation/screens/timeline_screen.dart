import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../domain/entities/child.dart';
import '../widgets/timeline_header.dart';
import '../widgets/free_version_banner.dart';
import '../widgets/recording_card.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  List<Child> _children = [];
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children =
        await ref.read(childProfileProvider.notifier).getAllProfiles();
    setState(() {
      _children = children;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRecordings = ref.watch(recordingListProvider);
    final recordings = _selectedChildId == null
        ? allRecordings
        : allRecordings
            .where((r) => r.childIds.contains(_selectedChildId))
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const TimelineHeader(),
            const FreeVersionBanner(),
            if (_children.length > 1) _buildFilterChips(),
            Expanded(
              child: _buildList(context, recordings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final child = _children[index];
          final isSelected = _selectedChildId == child.id;
          return FilterChip(
            label: Text(child.name),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedChildId = isSelected ? null : child.id;
              });
            },
            selectedColor: theme.colorScheme.primaryContainer,
            checkmarkColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List recordings) {
    if (recordings.isEmpty) {
      final message = _selectedChildId != null
          ? 'この子供の録音はまだありません'
          : 'まだ録音がありません';
      return Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: 0.4,
            ),
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
