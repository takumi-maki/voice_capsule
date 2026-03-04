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

    // アクティブ子供が削除されていたら解除
    final activeId = ref.read(activeChildProvider);
    final activeExists = children.any((c) => c.id == activeId);
    if (activeId != null && !activeExists) {
      await ref.read(activeChildProvider.notifier).clearActiveChild();
    }

    setState(() {
      _children = children;
      _selectedChildId = ref.read(activeChildProvider);
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
                const SizedBox(height: 24),
                _buildDescription(theme),
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

    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            fontSize: 14,
          ),
        ),
        trailing: isActive
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : Icon(
                Icons.radio_button_unchecked,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
        onTap: () => setState(() => _selectedChildId = child.id),
      ),
    );
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

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Selecting a child will customize the VoiceCapsule experience and organize voice recordings for their specific profile.',
      style: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 14,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      color: theme.scaffoldBackgroundColor,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _saveSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
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

  Future<void> _addChild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileSetupScreen()),
    );
    _loadChildren();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('選択を保存しました')));
    }
  }
}
