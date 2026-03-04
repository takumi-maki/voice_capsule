import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/repositories/user_repository_impl.dart';

class UserProfileNotifier extends StateNotifier<User?> {
  final UserRepositoryImpl _repository;
  final ImagePicker _imagePicker = ImagePicker();

  UserProfileNotifier(this._repository) : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.getProfile();
    state = profile;
  }

  Future<void> createProfile(String name, {String? photoPath}) async {
    final user = User(
      id: const Uuid().v4(),
      name: name,
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );
    await _repository.saveProfile(user);
    state = user;
  }

  Future<void> updateProfile(User user) async {
    await _repository.saveProfile(user);
    state = user;
    // 固定パス上書きによるFileImageキャッシュを破棄
    PaintingBinding.instance.imageCache.clear();
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
      return await _repository.savePhoto(image.path);
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
      return await _repository.savePhoto(image.path);
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

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, User?>((
  ref,
) {
  return UserProfileNotifier(UserRepositoryImpl());
});
