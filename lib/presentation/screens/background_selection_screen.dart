import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

class BackgroundSelectionScreen extends StatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  State<BackgroundSelectionScreen> createState() =>
      _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState extends State<BackgroundSelectionScreen> {
  BackgroundType _selectedLocation = BackgroundType.house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('場所を選択')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'どこで録音しましたか？',
                  style: theme.textTheme.bodyMedium?.copyWith(
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
                _buildLocationOption(BackgroundType.house, Icons.home, '家'),
                const SizedBox(width: 16),
                _buildLocationOption(
                  BackgroundType.car,
                  Icons.directions_car,
                  '車',
                ),
                const SizedBox(width: 16),
                _buildLocationOption(BackgroundType.park, Icons.park, '公園'),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getLocationIcon(_selectedLocation),
              size: 100,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedLocation.displayName,
            style: theme.textTheme.headlineSmall,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('決定'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption(
    BackgroundType location,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedLocation == location;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = location;
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
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected ? theme.colorScheme.primary : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : Colors.black38,
            ),
          ),
        ],
      ),
    );
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
