import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveChildNotifier extends StateNotifier<String?> {
  static const String _key = 'active_child_id';

  ActiveChildNotifier() : super(null) {
    _loadActiveChildId();
  }

  Future<void> _loadActiveChildId() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setActiveChild(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
    state = id;
  }

  Future<void> clearActiveChild() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = null;
  }
}

final activeChildProvider = StateNotifierProvider<ActiveChildNotifier, String?>(
  (ref) {
    return ActiveChildNotifier();
  },
);
