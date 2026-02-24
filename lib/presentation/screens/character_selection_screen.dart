import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  CharacterType _selectedCharacter = CharacterType.father;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Voice'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your capsule\'s storyteller',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildCharacterOption(CharacterType.father, Icons.man, 'Father'),
                const SizedBox(width: 16),
                _buildCharacterOption(CharacterType.mother, Icons.woman, 'Mother'),
                const SizedBox(width: 16),
                _buildCharacterOption(CharacterType.son, Icons.boy, 'Son'),
                const SizedBox(width: 16),
                _buildCharacterOption(CharacterType.daughter, Icons.girl, 'Daughter'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getCharacterIcon(_selectedCharacter),
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedCharacter.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedCharacter);
                },
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOption(
    CharacterType character,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedCharacter == character;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = character;
        });
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
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
}
