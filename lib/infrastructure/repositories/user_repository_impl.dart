import 'dart:convert';
import 'dart:io';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(user.toJson()));
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
      final profileDir = Directory('${dir.path}/user_profile');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      } else {
        // 古い写真ファイルをクリーンアップ
        await for (final file in profileDir.list()) {
          if (file is File) await file.delete();
        }
      }

      // タイムスタンプ付きファイル名でキャッシュ問題を回避
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = '${profileDir.path}/photo_$timestamp.jpg';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (e) {
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
