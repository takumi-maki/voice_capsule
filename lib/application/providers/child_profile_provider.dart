import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  /// 新規作成：写真は一時パスのまま渡す。childId確定後にIDベースパスへコピー。
  Future<void> createProfile(String name, {String? tempPhotoPath}) async {
    final id = const Uuid().v4();
    String? finalPhotoPath;

    if (tempPhotoPath != null) {
      finalPhotoPath = await _repository.savePhoto(tempPhotoPath, id);
    }

    final child = Child(
      id: id,
      name: name,
      photoPath: finalPhotoPath,
      createdAt: DateTime.now(),
    );
    await _repository.saveProfile(child);
    state = child;
  }

  Future<void> updateProfile(Child child) async {
    await _repository.saveProfile(child);
    state = child;
  }

  Future<void> deleteProfileById(String id) async {
    await _repository.deleteProfileById(id);
  }

  Future<List<Child>> getAllProfiles() async {
    return await _repository.getAllProfiles();
  }

  /// 写真を一時ディレクトリに保存して返す（新規作成時はchildId未確定のため）
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _saveTempPhoto(image.path);
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
      return await _saveTempPhoto(image.path);
    } catch (e) {
      return null;
    }
  }

  /// 編集時：childIdが確定済みなのでIDベースパスに直接保存
  Future<String?> pickImageFromGalleryForChild(String childId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _repository.savePhoto(image.path, childId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> pickImageFromCameraForChild(String childId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _repository.savePhoto(image.path, childId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _saveTempPhoto(String sourcePath) async {
    try {
      final dir = await getTemporaryDirectory();
      final destPath = '${dir.path}/child_photo_temp.jpg';
      await File(sourcePath).copy(destPath);
      return destPath;
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
