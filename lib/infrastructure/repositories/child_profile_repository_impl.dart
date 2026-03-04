import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/child_profile_repository.dart';

class ChildProfileRepositoryImpl implements ChildProfileRepository {
  static const String _profileKey = 'child_profile';
  static const String _allProfilesKey = 'child_profiles';

  @override
  Future<Child?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null) return null;
    try {
      return Child.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Child>> getAllProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allProfilesKey);
    if (jsonString == null) {
      final single = await getProfile();
      if (single != null) {
        await _saveAllProfiles([single]);
        return [single];
      }
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Child.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveProfile(Child child) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(child.toJson()));

    final profiles = await getAllProfiles();
    final index = profiles.indexWhere((p) => p.id == child.id);
    if (index >= 0) {
      profiles[index] = child;
    } else {
      profiles.add(child);
    }
    await _saveAllProfiles(profiles);
  }

  @override
  Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  @override
  Future<void> deleteProfileById(String id) async {
    final profiles = await getAllProfiles();
    final updated = profiles.where((p) => p.id != id).toList();
    await _saveAllProfiles(updated);
    await deletePhoto(id);
  }

  Future<void> _saveAllProfiles(List<Child> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _allProfilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Future<String?> savePhoto(String sourcePath, String childId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${dir.path}/child_profiles/$childId');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // タイムスタンプ付きパスで保存（FileImageキャッシュキーを毎回変える）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = '${profileDir.path}/photo_$timestamp.jpg';
      await File(sourcePath).copy(destPath);

      // 古いファイルを非同期でクリーンアップ（失敗しても新ファイルは残る）
      _cleanupOldPhotos(profileDir, destPath);

      return destPath;
    } catch (e) {
      return null;
    }
  }

  void _cleanupOldPhotos(Directory dir, String keepPath) async {
    try {
      await for (final file in dir.list()) {
        if (file is File && file.path != keepPath) {
          await file.delete();
        }
      }
    } catch (_) {
      // クリーンアップ失敗は無視
    }
  }

  @override
  Future<void> deletePhoto(String childId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${dir.path}/child_profiles/$childId');
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
      }
    } catch (e) {
      // ignore
    }
  }
}
