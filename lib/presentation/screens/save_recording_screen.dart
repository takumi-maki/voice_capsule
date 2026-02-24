import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording.dart';
import '../../application/providers/recording_provider.dart';
import 'character_selection_screen.dart';
import 'background_selection_screen.dart';

class SaveRecordingScreen extends ConsumerStatefulWidget {
  final String filePath;

  const SaveRecordingScreen({
    super.key,
    required this.filePath,
  });

  @override
  ConsumerState<SaveRecordingScreen> createState() => _SaveRecordingScreenState();
}

class _SaveRecordingScreenState extends ConsumerState<SaveRecordingScreen> {
  CharacterType _selectedCharacter = CharacterType.father;
  BackgroundType _selectedBackground = BackgroundType.house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Recording'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your voice capsule settings',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            
            // Character Selection
            Text(
              'Character',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectCharacter(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCharacterIcon(_selectedCharacter),
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _selectedCharacter.name.toUpperCase(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Background Selection
            Text(
              'Background',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectBackground(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getBackgroundIcon(_selectedBackground),
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _selectedBackground.name.toUpperCase(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveRecording(),
                child: const Text('Save Voice Capsule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCharacter() async {
    final character = await Navigator.push<CharacterType>(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterSelectionScreen(),
      ),
    );
    if (character != null) {
      setState(() {
        _selectedCharacter = character;
      });
    }
  }

  void _selectBackground() async {
    final background = await Navigator.push<BackgroundType>(
      context,
      MaterialPageRoute(
        builder: (_) => const BackgroundSelectionScreen(),
      ),
    );
    if (background != null) {
      setState(() {
        _selectedBackground = background;
      });
    }
  }

  void _saveRecording() async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    await recordingNotifier.saveRecording(
      ref,
      _selectedCharacter,
      _selectedBackground,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice capsule saved!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  IconData _getCharacterIcon(CharacterType character) {
    switch (character) {
      case CharacterType.father:
        return Icons.man;
      case CharacterType.mother:
        return Icons.woman;
      case CharacterType.son:
        return Icons.boy;
      case CharacterType.daughter:
        return Icons.girl;
    }
  }

  IconData _getBackgroundIcon(BackgroundType background) {
    switch (background) {
      case BackgroundType.house:
        return Icons.home;
      case BackgroundType.car:
        return Icons.directions_car;
      case BackgroundType.park:
        return Icons.park;
    }
  }
}