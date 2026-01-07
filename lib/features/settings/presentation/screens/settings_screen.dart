import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import '../controllers/settings_controller.dart';
import 'dart:async';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_videos_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    await ref.read(currentUserControllerProvider.notifier).refresh();
    if (context.mounted) {
      context.go('/login');
    }
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
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true,
            ),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password updated'
                          : 'Failed to update password',
                    ),
                  ),
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update profile')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text(
                  isLoggedIn ? '@${user.username}' : 'Not logged in',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  isLoggedIn
                      ? 'Manage your account'
                      : 'Login to manage account',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const Divider(color: Colors.white12),
              const _SettingsSectionHeader(title: 'Account'),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () =>
                    _showEditProfileDialog(context, ref, user?.name, user?.bio),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.white),
                title: const Text(
                  'Privacy',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Change Password',
                  style: TextStyle(color: Colors.white54),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.security, color: Colors.white),
                title: const Text(
                  'Security',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () {},
              ),
              const Divider(color: Colors.white12),
              const _SettingsSectionHeader(title: 'General'),
              ListTile(
                leading: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () {},
              ),
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.white),
                title: const Text(
                  'Language',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'English',
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {},
              ),
              const Divider(color: Colors.white12),
              const _SettingsSectionHeader(title: 'About'),
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
              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Open Source Libraries',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.redAccent),
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
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

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
