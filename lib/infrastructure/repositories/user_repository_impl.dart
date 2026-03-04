import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _profileKey = 'user_profile';

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
  Future<void> deletePhoto() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${dir.path}/user_profile');
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
      }
    } catch (e) {
      // ignore
    }
  }
}
