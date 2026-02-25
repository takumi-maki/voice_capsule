import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/child.dart';
import '../../infrastructure/repositories/child_profile_repository_impl.dart';

class ChildProfileNotifier extends StateNotifier<Child?> {
  final ChildProfileRepositoryImpl _repository;
  final ImagePicker _imagePicker = ImagePicker();

  ChildProfileNotifier(this._repository) : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.getProfile();
    state = profile;
  }

  Future<void> createProfile(String name, {String? photoPath}) async {
    final child = Child(
      id: const Uuid().v4(),
      name: name,
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );

    await _repository.saveProfile(child);
    state = child;
  }

  Future<void> updateProfile(Child child) async {
    await _repository.saveProfile(child);
    state = child;
  }

  Future<List<Child>> getAllProfiles() async {
    return await _repository.getAllProfiles();
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      final savedPath = await _repository.savePhoto(image.path);
      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      final savedPath = await _repository.savePhoto(image.path);
      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProfile() async {
    await _repository.deleteProfile();
    state = null;
  }

  bool get hasProfile => state != null;
}

final childProfileProvider =
    StateNotifierProvider<ChildProfileNotifier, Child?>((ref) {
      return ChildProfileNotifier(ChildProfileRepositoryImpl());
    });
