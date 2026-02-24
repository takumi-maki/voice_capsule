import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/child_profile_repository.dart';

class ChildProfileRepositoryImpl implements ChildProfileRepository {
  static const String _profileKey = 'child_profile';
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
  Future<void> saveProfile(Child child) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(child.toJson());
    await prefs.setString(_profileKey, jsonString);
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
