import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/screens/recording_screen.dart';
import 'presentation/screens/onboarding/child_profile_setup_screen.dart';
import 'application/providers/child_profile_provider.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _clearOldData();

  runApp(const ProviderScope(child: MyApp()));
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
    final childProfile = ref.watch(childProfileProvider);

    if (childProfile == null) {
      return const ChildProfileSetupScreen();
    }

    return const RecordingScreen();
  }
}
