import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _profileKey = 'user_profile';
  static const String _photoFileName = 'photo.jpg';

  @override
  Future<User?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(User user) async {
    debugPrint(
      '💾 [UserRepositoryImpl] saveProfile: id=${user.id}, photoPath=${user.photoPath}',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(user.toJson()));
    debugPrint('✅ [UserRepositoryImpl] saveProfile done');
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
      debugPrint('📁 [UserRepositoryImpl] savePhoto: src=$sourcePath');
      final dir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${dir.path}/user_profile');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // 固定パスに上書き（コピー失敗時も元ファイルが残る安全な方式）
      final destPath = '${profileDir.path}/$_photoFileName';
      await File(sourcePath).copy(destPath);
      debugPrint('✅ [UserRepositoryImpl] savePhoto done: dest=$destPath');
      return destPath;
    } catch (e) {
      debugPrint('❌ [UserRepositoryImpl] savePhoto error: $e');
      return null;
    }
  }

  @override
  Future<void> deletePhoto() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photoFile = File('${dir.path}/user_profile/$_photoFileName');
      if (await photoFile.exists()) {
        await photoFile.delete();
      }
    } catch (e) {
      // ignore
    }
  }
}
