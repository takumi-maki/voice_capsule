import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await ref
        .read(childProfileProvider.notifier)
        .getAllProfiles();
    setState(() {
      _children = children;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          'Tap to select',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        trailing: Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
        onTap: () => _editChild(child),
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
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 1.5,
            style: BorderStyle.solid,
          ),
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
      style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      color: const Color(0xFFFAF7F2),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
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

  void _addChild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileSetupScreen()),
    );
    _loadChildren();
  }

  void _editChild(Child child) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildProfileSetupScreen(isEditing: true),
      ),
    );
    _loadChildren();
  }
}
