import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/user_profile_provider.dart';
import '../../../application/providers/child_profile_provider.dart';
import '../main_screen.dart';
import 'child_profile_setup_screen.dart';

class UserProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isEditing;

  const UserProfileSetupScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<UserProfileSetupScreen> createState() =>
      _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState
    extends ConsumerState<UserProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final user = ref.read(userProfileProvider);
      if (user != null) {
        _nameController.text = user.name;
        _photoPath = user.photoPath;
      }
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
      appBar: widget.isEditing ? AppBar(title: const Text('プロフィール編集')) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                widget.isEditing ? 'プロフィールを編集' : 'あなたのプロフィールを設定',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEditing
                    ? ''
                    : 'VoiceCapsuleへようこそ。まずあなた自身のプロフィールを登録してください。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
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
                  labelText: 'あなたの名前',
                  hintText: '例: 山田 花子',
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
                      : Text(widget.isEditing ? '更新する' : '次へ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(ThemeData theme) {
    if (_photoPath != null) {
      return Container(
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
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
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

  Future<void> _pickImageFromCamera() async {
    final path = await ref
        .read(userProfileProvider.notifier)
        .pickImageFromCamera();
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _pickImageFromGallery() async {
    final path = await ref
        .read(userProfileProvider.notifier)
        .pickImageFromGallery();
    if (path != null) setState(() => _photoPath = path);
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
      final notifier = ref.read(userProfileProvider.notifier);

      if (widget.isEditing) {
        // 既存のid・createdAtを保持したまま更新
        final current = ref.read(userProfileProvider);
        if (current != null) {
          await notifier.updateProfile(
            current.copyWith(name: name, photoPath: _photoPath),
          );
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      await notifier.createProfile(name, photoPath: _photoPath);

      if (!mounted) return;

      // オンボーディング: 子供プロフィールが未設定なら次のステップへ
      final childProfile = ref.read(childProfileProvider);
      if (childProfile == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ChildProfileSetupScreen(isOnboarding: true),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
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
