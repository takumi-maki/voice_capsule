import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/child_profile_repository.dart';

class ChildProfileRepositoryImpl implements ChildProfileRepository {
  static const String _profileKey = 'child_profile';
  static const String _allProfilesKey = 'child_profiles';
  static const String _photoFileName = 'photo.jpg';

  @override
  Future<Child?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Child.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Child>> getAllProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allProfilesKey);

    if (jsonString == null) {
      // 既存の単一プロフィールを移行
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
    final jsonString = jsonEncode(child.toJson());
    await prefs.setString(_profileKey, jsonString);

    // リストにも追加/更新
    final profiles = await getAllProfiles();
    final index = profiles.indexWhere((p) => p.id == child.id);
    if (index >= 0) {
      profiles[index] = child;
    } else {
      profiles.add(child);
    }
    await _saveAllProfiles(profiles);
  }

  Future<void> _saveAllProfiles(List<Child> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = profiles.map((p) => p.toJson()).toList();
    await prefs.setString(_allProfilesKey, jsonEncode(jsonList));
  }

  @override
  Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await deletePhoto();
  }

  @override
  Future<String?> savePhoto(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${dir.path}/child_profile');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final destPath = '${profileDir.path}/$_photoFileName';
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      return destPath;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deletePhoto() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photoFile = File('${dir.path}/child_profile/$_photoFileName');

      if (await photoFile.exists()) {
        await photoFile.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }
}
