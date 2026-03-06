import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../application/providers/active_child_provider.dart';
import '../../domain/entities/child.dart';
import '../widgets/child_avatar.dart';
import 'onboarding/child_profile_setup_screen.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  List<Child> _children = [];
  bool _isLoading = true;
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await ref
        .read(childProfileProvider.notifier)
        .getAllProfiles();
    final activeChildId = ref.read(activeChildProvider);
    setState(() {
      _children = children;
      _selectedChildId = activeChildId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Family Members',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._children.map((child) => _buildChildCard(child, theme)),
                const SizedBox(height: 16),
                _buildAddChildButton(theme),
                const SizedBox(height: 16),
                Text(
                  'Selecting a child will customize the VoiceCapsule experience and organize voice recordings for their specific profile.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _buildSaveButton(theme),
      ],
    );
  }

  Widget _buildChildCard(Child child, ThemeData theme) {
    final isActive = _selectedChildId == child.id;
    final canDelete = _children.length > 1;

    return GestureDetector(
      onTap: () => setState(() => _selectedChildId = child.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ChildAvatar(child: child, size: 48),
          title: Text(
            child.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            isActive ? 'Active Profile' : 'Tap to select',
            style: TextStyle(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isActive
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () => _editChild(child),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: canDelete
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                onPressed: canDelete ? () => _confirmDelete(child) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Save Selection',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSelection() async {
    if (_selectedChildId != null) {
      await ref
          .read(activeChildProvider.notifier)
          .setActiveChild(_selectedChildId!);
    } else {
      await ref.read(activeChildProvider.notifier).clearActiveChild();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selection saved')),
      );
    }
  }

  Widget _buildAddChildButton(ThemeData theme) {
    return GestureDetector(
      onTap: _addChild,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Add Child',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addChild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileSetupScreen()),
    );
    _loadChildren();
  }

  Future<void> _editChild(Child child) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildProfileSetupScreen(child: child)),
    );
    _loadChildren();
  }

  Future<void> _confirmDelete(Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${child.name}を削除'),
        content: const Text('このプロフィールを削除しますか？録音データは残ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(childProfileProvider.notifier).deleteProfileById(child.id);
      if (child.id == ref.read(activeChildProvider)) {
        await ref.read(activeChildProvider.notifier).clearActiveChild();
      }
      _loadChildren();
    }
  }
}
