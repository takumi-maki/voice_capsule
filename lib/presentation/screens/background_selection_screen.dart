import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';
import 'background_selection/widgets/scene_card.dart';
import 'background_selection/widgets/scene_preview.dart';

class BackgroundSelectionScreen extends StatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  State<BackgroundSelectionScreen> createState() =>
      _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState extends State<BackgroundSelectionScreen> {
  BackgroundType _selectedType = BackgroundType.house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENVIRONMENT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose a scene', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Where does this memory live?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSceneCards(),
          const SizedBox(height: 24),
          ScenePreview(selectedType: _selectedType),
          const Spacer(),
          _buildConfirmButton(theme),
        ],
      ),
    );
  }

  Widget _buildSceneCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: BackgroundType.values.map((type) {
        return SceneCard(
          type: type,
          isSelected: _selectedType == type,
          onTap: () => setState(() => _selectedType = type),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, _selectedType),
          icon: const Icon(Icons.check_circle),
          label: const Text('Confirm Selection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
