import 'dart:io';
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
  final Set<String> _selectedChildIds = {};

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
      _selectedChildIds.addAll(children.map((c) => c.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRecordings = ref.watch(recordingListProvider);
    final recordings = allRecordings
        .where((r) => r.childIds.any((id) => _selectedChildIds.contains(id)))
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
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final child = _children[index];
          final isSelected = _selectedChildIds.contains(child.id);
          return _ChildPillChip(
            child: child,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedChildIds.remove(child.id);
                } else {
                  _selectedChildIds.add(child.id);
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List recordings) {
    if (recordings.isEmpty) {
      final message = _selectedChildIds.length < _children.length
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

class _ChildPillChip extends StatelessWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildPillChip({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(theme),
            const SizedBox(width: 8),
            Text(
              child.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final hasPhoto =
        child.photoPath != null && File(child.photoPath!).existsSync();

    if (hasPhoto) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: FileImage(File(child.photoPath!)),
      );
    }

    return CircleAvatar(
      radius: 12,
      backgroundColor: isSelected
          ? theme.colorScheme.onPrimary.withValues(alpha: 0.3)
          : theme.colorScheme.primary.withValues(alpha: 0.15),
      child: Text(
        child.initials,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
      ),
    );
  }
}
