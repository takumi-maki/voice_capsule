import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../application/providers/selected_children_provider.dart';
import '../../domain/entities/child.dart';
import '../widgets/child_avatar.dart';

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
    final notifier = ref.read(childProfileProvider.notifier);
    final children = await notifier.getAllProfiles();
    setState(() {
      _children = children;
      _isLoading = false;
    });

    if (children.isNotEmpty) {
      final selectedIds = ref.read(selectedChildrenProvider);
      if (selectedIds.isEmpty) {
        ref.read(selectedChildrenProvider.notifier).initialize([
          children.first.id,
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(selectedChildrenProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Children')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Who is this recording for?',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  _buildChildGrid(selectedIds, theme),
                  const Spacer(),
                  _buildConfirmButton(theme, selectedIds),
                ],
              ),
            ),
    );
  }

  Widget _buildChildGrid(List<String> selectedIds, ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _children.map((child) {
        final isSelected = selectedIds.contains(child.id);
        return _buildChildCard(child, isSelected, theme);
      }).toList(),
    );
  }

  Widget _buildChildCard(Child child, bool isSelected, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedChildrenProvider.notifier).toggle(child.id);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ChildAvatar(child: child, size: 64),
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            child.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme, List<String> selectedIds) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: selectedIds.isNotEmpty
            ? () => Navigator.pop(context, selectedIds)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('Continue'),
      ),
    );
  }
}
