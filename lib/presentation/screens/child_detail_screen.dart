import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/child_profile_provider.dart';
import '../../domain/entities/child.dart';
import '../widgets/child_avatar.dart';
import 'onboarding/child_profile_setup_screen.dart';

class ChildDetailScreen extends ConsumerWidget {
  final Child child;

  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          child.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            ChildAvatar(child: child, size: 80),
            const SizedBox(height: 16),
            Text(
              child.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _editProfile(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(height: 16),
            _DeleteButton(child: child),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildProfileSetupScreen(child: child),
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  final Child child;

  const _DeleteButton({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Child>>(
      future: ref.read(childProfileProvider.notifier).getAllProfiles(),
      builder: (context, snapshot) {
        final canDelete = (snapshot.data?.length ?? 1) > 1;

        return SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: canDelete ? () => _confirmDelete(context, ref) : null,
            style: TextButton.styleFrom(
              foregroundColor: canDelete
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Delete'),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${child.name}?'),
        content: const Text(
          'This profile will be deleted. Recordings will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(childProfileProvider.notifier)
          .deleteProfileById(child.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
