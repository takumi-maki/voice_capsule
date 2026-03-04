import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding/user_profile_setup_screen.dart';
import 'presentation/screens/onboarding/child_profile_setup_screen.dart';
import 'application/providers/user_profile_provider.dart';
import 'application/providers/child_profile_provider.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _clearOldData();
  await _initAudioSession();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
    ),
  );
}

Future<void> _clearOldData() async {
  final prefs = await SharedPreferences.getInstance();
  final hasCleared = prefs.getBool('data_cleared_v2') ?? false;

  if (!hasCleared) {
    await prefs.remove('recordings');
    await prefs.setBool('data_cleared_v2', true);
    debugPrint('🗑️ 旧データをクリアしました');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VoiceCapsule',
      theme: AppTheme.theme,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final childProfile = ref.watch(childProfileProvider);

    if (userProfile == null) {
      return const UserProfileSetupScreen();
    }

    if (childProfile == null) {
      return const ChildProfileSetupScreen();
    }

    return const MainScreen();
  }
}
