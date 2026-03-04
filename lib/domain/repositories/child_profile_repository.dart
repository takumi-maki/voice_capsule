import '../entities/child.dart';

abstract class ChildProfileRepository {
  Future<Child?> getProfile();
  Future<List<Child>> getAllProfiles();
  Future<void> saveProfile(Child child);
  Future<void> deleteProfile();
  Future<void> deleteProfileById(String id);
  Future<String?> savePhoto(String sourcePath, String childId);
  Future<void> deletePhoto(String childId);
}
