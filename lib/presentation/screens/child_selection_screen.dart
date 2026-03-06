import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../application/providers/selected_children_provider.dart';
import '../../domain/entities/child.dart';
import '../widgets/child_avatar.dart';
import 'main_screen.dart';

class ChildSelectionScreen extends ConsumerStatefulWidget {
  const ChildSelectionScreen({super.key});

  @override
  ConsumerState<ChildSelectionScreen> createState() =>
      _ChildSelectionScreenState();
}

class _ChildSelectionScreenState extends ConsumerState<ChildSelectionScreen> {
  List<Child> _children = [];
  bool _isLoading = true;

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
      _isLoading = false;
    });

    if (children.isNotEmpty) {
      final selectedIds = ref.read(selectedChildrenProvider);
      if (selectedIds.isEmpty) {
        ref
            .read(selectedChildrenProvider.notifier)
            .initialize([children.first.id]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(selectedChildrenProvider);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_children.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Multi-Member Selection',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildAvatarRow(selectedIds, theme),
                  const SizedBox(height: 32),
                  _buildOverlapPreview(selectedIds, theme),
                  const SizedBox(height: 24),
                  _buildSelectionInfo(selectedIds, theme),
                ],
              ),
            ),
          ),
          _buildSaveButton(selectedIds, theme),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Who is in this memory?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select one or more family members',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvatarRow(List<String> selectedIds, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _children.map((child) {
          final isSelected = selectedIds.contains(child.id);
          return _buildSelectableAvatar(child, isSelected, theme);
        }).toList(),
      ),
    );
  }

  Widget _buildSelectableAvatar(
    Child child,
    bool isSelected,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => ref.read(selectedChildrenProvider.notifier).toggle(child.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ChildAvatar(child: child, size: 60),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              child.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlapPreview(List<String> selectedIds, ThemeData theme) {
    final selected =
        _children.where((c) => selectedIds.contains(c.id)).toList();
    final count = selected.length;

    return SizedBox(
      height: 160,
      child: Center(
        child: count == 0
            ? _buildEmptyPreview(theme)
            : count == 1
            ? ChildAvatar(child: selected[0], size: 120)
            : _buildGroupPreview(selected, theme),
      ),
    );
  }

  Widget _buildEmptyPreview(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.people_outline,
        size: 48,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildGroupPreview(List<Child> selected, ThemeData theme) {
    final extra = selected.length - 2;
    return SizedBox(
      width: 200,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 10, child: ChildAvatar(child: selected[0], size: 90)),
          Positioned(
            right: 10,
            child: ChildAvatar(child: selected[1], size: 90),
          ),
          if (extra > 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo(List<String> selectedIds, ThemeData theme) {
    final count = selectedIds.length;
    final isSolo = count == 1;

    return Column(
      children: [
        if (count > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSolo ? Icons.person : Icons.group,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSolo ? 'SOLO MEMORY' : 'GROUP MEMORY',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          count == 0 ? 'No members selected' : '$count Selected',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These members will be associated with the recording\nand indexed in the archive.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSaveButton(List<String> selectedIds, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedIds.isNotEmpty
              ? () => Navigator.pop(context, selectedIds)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            disabledBackgroundColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Text(
        'PARTICIPANTS CAN BE EDITED LATER IN MEMORY DETAILS',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          letterSpacing: 0.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Scaffold _buildEmptyState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Multi-Member Selection',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'まだ子供が登録されていません',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Family タブで追加する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
