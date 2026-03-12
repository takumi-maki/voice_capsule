import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/providers/recording_list_provider.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../domain/entities/child.dart';
import '../../domain/entities/recording.dart';
import '../widgets/timeline_header.dart';
import '../widgets/free_version_banner.dart';
import '../widgets/recording_card.dart';
import '../widgets/today_summary_card.dart';

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

  Widget _buildList(BuildContext context, List<Recording> recordings) {
    if (recordings.isEmpty) {
      final message = _selectedChildIds.length < _children.length
          ? '音声がありません'
          : 'まだ録音がありません';
      return Column(
        children: [
          const TodaySummaryCard(),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 日付グループ化
    final items = _buildGroupedItems(recordings);

    return ListView.builder(
      itemCount: items.length + 1, // +1 for TodaySummaryCard at top
      itemBuilder: (context, index) {
        if (index == 0) return const TodaySummaryCard();

        final item = items[index - 1];
        if (item is String) {
          return _buildDateHeader(context, item);
        }
        return RecordingCard(recording: item as Recording);
      },
    );
  }

  List<Object> _buildGroupedItems(List<Recording> recordings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // 日付でグループ化（新しい順）
    final Map<DateTime, List<Recording>> grouped = {};
    for (final r in recordings) {
      final date = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      grouped.putIfAbsent(date, () => []).add(r);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final items = <Object>[];
    for (final date in sortedDates) {
      items.add(_formatDateHeader(date, today, yesterday));
      items.addAll(grouped[date]!..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    }
    return items;
  }

  String _formatDateHeader(DateTime date, DateTime today, DateTime yesterday) {
    final weekday = DateFormat('EEEE').format(date); // Monday
    final monthDay = DateFormat('MMMM d').format(date); // October 24

    if (date == today) return 'Today, $weekday, $monthDay';
    if (date == yesterday) return 'Yesterday, $weekday, $monthDay';
    return '$weekday, $monthDay';
  }

  Widget _buildDateHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.5,
        ),
      ),
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
