import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/settings_controller.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_videos_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    await ref.read(currentUserControllerProvider.notifier).refresh();
    if (context.mounted) context.go('/login');
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DarkTextField(
              controller: currentPasswordController,
              label: 'Current Password',
              obscure: true,
            ),
            _DarkTextField(
              controller: newPasswordController,
              label: 'New Password',
              obscure: true,
            ),
            _DarkTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              obscure: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(settingsControllerProvider.notifier)
                  .updatePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                    confirmPassword: confirmPasswordController.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                _snack(
                  context,
                  success ? 'Password updated' : 'Failed to update password',
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentName,
    String? currentBio,
  ) {
    final nameController = TextEditingController(text: currentName);
    final bioController = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DarkTextField(controller: nameController, label: 'Name'),
            _DarkTextField(
              controller: bioController,
              label: 'Bio',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(settingsControllerProvider.notifier)
                  .updateProfile(
                    name: nameController.text,
                    bio: bioController.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  unawaited(
                    ref.read(currentUserControllerProvider.notifier).refresh(),
                  );
                }
                _snack(
                  context,
                  success ? 'Profile updated' : 'Failed to update profile',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Update Email',
          style: TextStyle(color: Colors.white),
        ),
        content: _DarkTextField(
          controller: emailController,
          label: 'New email address',
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final success = await ref
                  .read(settingsControllerProvider.notifier)
                  .updateEmail(email: email);
              if (context.mounted) {
                Navigator.pop(context);
                _snack(
                  context,
                  success
                      ? 'Email update requested. Check your inbox.'
                      : 'Failed to update email',
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final success = await ref
        .read(settingsControllerProvider.notifier)
        .updateAvatar(image.path);

    if (context.mounted) {
      if (success) {
        unawaited(
          ref.read(currentUserControllerProvider.notifier).refresh(),
        );
      }
      _snack(
        context,
        success ? 'Avatar updated' : 'Failed to update avatar',
      );
    }
  }

  void _showPrivacyDialog(BuildContext context, WidgetRef ref) async {
    final settings = await ref
        .read(settingsControllerProvider.notifier)
        .getPrivacySettings();

    if (!context.mounted) return;

    bool isPrivate = settings?['is_private'] as bool? ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Privacy Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Private Account',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Only approved followers can see your content',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: isPrivate,
                onChanged: (val) => setDialogState(() => isPrivate = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await ref
                    .read(settingsControllerProvider.notifier)
                    .updatePrivacySettings({'is_private': isPrivate});
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _snack(
                    context,
                    success
                        ? 'Privacy settings saved'
                        : 'Failed to save privacy settings',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool disable,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          disable ? 'Disable Account' : 'Delete Account',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          disable
              ? 'Your account will be temporarily disabled. You can reactivate it by logging in again.'
              : 'This will permanently delete your account and all your data. This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final controller = ref.read(settingsControllerProvider.notifier);
              final success = disable
                  ? await controller.disableAccount()
                  : await controller.deleteAccount();
              if (success && context.mounted) {
                await ref.read(authRepositoryProvider).logout();
                if (context.mounted) context.go('/login');
              } else if (context.mounted) {
                _snack(context, 'Operation failed. Please try again.');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: Text(disable ? 'Disable' : 'Delete'),
          ),
        ],
      ),
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: currentUser.when(
        data: (user) {
          final isLoggedIn = user != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account header
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text(
                  isLoggedIn ? '@${user.username}' : 'Not logged in',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  isLoggedIn
                      ? (user.name ?? 'Manage your account')
                      : 'Login to manage account',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const Divider(color: Colors.white12),

              const _SectionHeader(title: 'Account'),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () =>
                    _showEditProfileDialog(context, ref, user?.name, user?.bio),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.white),
                title: const Text(
                  'Change Profile Picture',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => _pickAndUploadAvatar(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.white),
                title: const Text(
                  'Update Email',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => _showUpdateEmailDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.white),
                title: const Text(
                  'Change Password',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: Colors.white),
                title: const Text(
                  'Privacy',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Control who can see your content',
                  style: TextStyle(color: Colors.white54),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => _showPrivacyDialog(context, ref),
              ),

              const Divider(color: Colors.white12),
              const _SectionHeader(title: 'General'),
              ListTile(
                leading: const Icon(
                  Icons.cleaning_services_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Clear Cache',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await DefaultCacheManager().emptyCache();
                  if (context.mounted) _snack(context, 'Cache cleared');
                },
              ),

              const Divider(color: Colors.white12),
              const _SectionHeader(title: 'About'),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),

              const Divider(color: Colors.white12),
              if (isLoggedIn) ...[
                ListTile(
                  leading: const Icon(
                    Icons.pause_circle_outline,
                    color: Colors.orange,
                  ),
                  title: const Text(
                    'Disable Account',
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: () => _showDeleteAccountDialog(
                    context,
                    ref,
                    disable: true,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => _showDeleteAccountDialog(
                    context,
                    ref,
                    disable: false,
                  ),
                ),
                const Divider(color: Colors.white12),
              ],
              ListTile(
                leading: Icon(
                  isLoggedIn ? Icons.logout : Icons.login,
                  color: Colors.redAccent,
                ),
                title: Text(
                  isLoggedIn ? 'Logout' : 'Login',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  if (isLoggedIn) {
                    await _logout(context, ref);
                  } else {
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
