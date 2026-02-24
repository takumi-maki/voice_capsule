import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

class BackgroundSelectionScreen extends StatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  State<BackgroundSelectionScreen> createState() =>
      _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState
    extends State<BackgroundSelectionScreen> {
  BackgroundType _selectedBackground = BackgroundType.house;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Scene'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose where this memory was made',
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
                _buildBackgroundOption(BackgroundType.house, Icons.home, 'Home'),
                const SizedBox(width: 16),
                _buildBackgroundOption(
                    BackgroundType.car, Icons.directions_car, 'Car'),
                const SizedBox(width: 16),
                _buildBackgroundOption(BackgroundType.park, Icons.park, 'Park'),
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
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getBackgroundIcon(_selectedBackground),
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedBackground.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedBackground);
                },
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(
    BackgroundType background,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedBackground == background;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBackground = background;
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
                    ? Theme.of(context).colorScheme.secondary
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
                  ? Theme.of(context).colorScheme.secondary
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
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
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
