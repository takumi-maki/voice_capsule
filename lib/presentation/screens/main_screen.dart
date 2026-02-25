import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/recording_provider.dart';
import '../../application/providers/audio_player_provider.dart';
import '../../application/providers/recording_timer_provider.dart';
import 'recording_screen.dart';
import 'timeline_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [RecordingScreen(), TimelineScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTabTapped(index),
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'RECORD'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'MEMORIES'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) async {
    if (index == _currentIndex) return;

    final recordingState = ref.read(recordingProvider);

    if (recordingState == RecordingState.recording ||
        recordingState == RecordingState.paused) {
      final confirmed = await _showRecordingWarningDialog();
      if (confirmed == true) {
        await _stopAndDiscardRecording();
        setState(() {
          _currentIndex = index;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<bool?> _showRecordingWarningDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('録音中です'),
        content: const Text('録音を破棄してタブを切り替えますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('破棄して切り替え'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopAndDiscardRecording() async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);
    final timerNotifier = ref.read(recordingTimerProvider.notifier);

    await audioPlayerNotifier.stop();
    await recordingNotifier.resetRecording();
    timerNotifier.reset();
  }
}
