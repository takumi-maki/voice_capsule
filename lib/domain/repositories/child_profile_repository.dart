import '../entities/child.dart';

abstract class ChildProfileRepository {
  Future<Child?> getProfile();
  Future<void> saveProfile(Child child);
  Future<void> deleteProfile();
  Future<String?> savePhoto(String sourcePath);
  Future<void> deletePhoto();
}
