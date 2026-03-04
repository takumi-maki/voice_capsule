import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../application/providers/child_profile_provider.dart';
import '../../../domain/entities/child.dart';
import '../main_screen.dart';

class ChildProfileSetupScreen extends ConsumerStatefulWidget {
  final Child? child; // 編集時に渡す。nullなら新規作成
  final bool isOnboarding; // オンボーディングからの遷移かどうか

  const ChildProfileSetupScreen({
    super.key,
    this.child,
    this.isOnboarding = false,
  });

  bool get isEditing => child != null;

  @override
  ConsumerState<ChildProfileSetupScreen> createState() =>
      _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState
    extends ConsumerState<ChildProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nameController.text = widget.child!.name;
      _photoPath = widget.child!.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'プロフィール編集' : 'お子様のプロフィール')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              widget.isEditing ? 'プロフィールを編集してください' : 'お子様の情報を登録してください',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _showPhotoOptions,
              child: _buildPhotoPreview(theme),
            ),
            const SizedBox(height: 16),
            Text(
              'タップして写真を設定',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お子様の名前',
                hintText: '例: 太郎',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing ? '更新する' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(ThemeData theme) {
    final hasPhoto = _photoPath != null && File(_photoPath!).existsSync();

    if (hasPhoto) {
      return Container(
        key: ValueKey(_photoPath),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(_photoPath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Icon(
        Icons.add_a_photo,
        size: 48,
        color: theme.colorScheme.primary,
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('写真を削除'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final notifier = ref.read(childProfileProvider.notifier);
    String? path;

    if (widget.isEditing) {
      // 編集時はchildIdが確定済みなのでIDベースパスに直接保存
      path = source == ImageSource.camera
          ? await notifier.pickImageFromCameraForChild(widget.child!.id)
          : await notifier.pickImageFromGalleryForChild(widget.child!.id);
    } else {
      // 新規作成時は一時パスに保存
      path = source == ImageSource.camera
          ? await notifier.pickImageFromCamera()
          : await notifier.pickImageFromGallery();
    }

    if (path != null) {
      setState(() => _photoPath = path);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('写真の取得に失敗しました。設定から権限を許可してください。')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('名前を入力してください')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(childProfileProvider.notifier);

      if (widget.isEditing) {
        await notifier.updateProfile(
          widget.child!.copyWith(name: name, photoPath: _photoPath),
        );
      } else {
        await notifier.createProfile(name, tempPhotoPath: _photoPath);
      }

      if (!mounted) return;

      if (widget.isOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存に失敗しました')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
