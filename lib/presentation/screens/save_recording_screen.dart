import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording.dart';
import '../../domain/entities/child.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/child_profile_provider.dart';
import 'background_selection_screen.dart';
import 'child_selection_screen.dart';
import 'main_screen.dart';

class SaveRecordingScreen extends ConsumerStatefulWidget {
  final String filePath;

  const SaveRecordingScreen({super.key, required this.filePath});

  @override
  ConsumerState<SaveRecordingScreen> createState() =>
      _SaveRecordingScreenState();
}

class _SaveRecordingScreenState extends ConsumerState<SaveRecordingScreen> {
  final _titleController = TextEditingController();
  BackgroundType _selectedLocation = BackgroundType.house;
  List<String> _selectedChildIds = [];
  List<Child> _allChildren = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final notifier = ref.read(childProfileProvider.notifier);
    final children = await notifier.getAllProfiles();
    setState(() {
      _allChildren = children;
      if (children.isNotEmpty) {
        _selectedChildIds = [children.first.id];
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('録音を保存')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('タイトルと場所を設定してください', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  hintText: '例: 朝のあいさつ',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              _buildLocationSelector(theme),
              if (_allChildren.length > 1) ...[
                const SizedBox(height: 24),
                _buildChildSelector(theme),
              ],
              const SizedBox(height: 24),
              _buildSaveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '場所',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectLocation(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(
                  _getLocationIcon(_selectedLocation),
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  _selectedLocation.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildSelector(ThemeData theme) {
    final selectedNames = _allChildren
        .where((c) => _selectedChildIds.contains(c.id))
        .map((c) => c.name)
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'お子様',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectChildren(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(Icons.people, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedNames.isEmpty ? '選択してください' : selectedNames,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _saveRecording(),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('保存'),
      ),
    );
  }

  void _selectLocation() async {
    final location = await Navigator.push<BackgroundType>(
      context,
      MaterialPageRoute(builder: (_) => const BackgroundSelectionScreen()),
    );
    if (location != null) {
      setState(() => _selectedLocation = location);
    }
  }

  void _selectChildren() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const ChildSelectionScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _selectedChildIds = result);
    }
  }

  void _saveRecording() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
      return;
    }

    final recordingNotifier = ref.read(recordingProvider.notifier);
    await recordingNotifier.saveRecording(
      ref,
      title,
      _selectedLocation,
      childIds: _selectedChildIds,
    );
    await recordingNotifier.resetRecording();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('録音を保存しました')));
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 1)),
      );
    }
  }

  IconData _getLocationIcon(BackgroundType location) {
    switch (location) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }
}
