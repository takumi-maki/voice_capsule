import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getProfile();
  Future<void> saveProfile(User user);
  Future<void> deleteProfile();
  Future<String?> savePhoto(String sourcePath);
  Future<void> deletePhoto();
}
