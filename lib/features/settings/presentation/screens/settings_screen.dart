import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/settings_controller.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_videos_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _avatarLoading = false;

  // ── Snack helper ──────────────────────────────────────────────────────────

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFF3D1010) : null,
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(currentUserControllerProvider.notifier).refresh();
    if (mounted) context.go('/login');
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Future<void> _pickAvatar() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _avatarLoading = true);
    final ok = await ref
        .read(settingsControllerProvider.notifier)
        .updateAvatar(image.path);
    if (mounted) {
      setState(() => _avatarLoading = false);
      if (ok) {
        unawaited(
            ref.read(currentUserControllerProvider.notifier).refresh());
        _snack('Profile picture updated');
      } else {
        _snack('Failed to update profile picture', error: true);
      }
    }
  }

  // ── Edit profile dialog ───────────────────────────────────────────────────

  void _showEditProfile(String? name, String? bio) {
    final nc = TextEditingController(text: name);
    final bc = TextEditingController(text: bio);
    showDialog(
      context: context,
      builder: (ctx) => _Dialog(
        title: 'Edit Profile',
        fields: [
          _DialogField(ctrl: nc, label: 'Display name', hint: 'Your name'),
          _DialogField(ctrl: bc, label: 'Bio', hint: 'About you', lines: 3),
        ],
        onConfirm: () async {
          final ok = await ref
              .read(settingsControllerProvider.notifier)
              .updateProfile(name: nc.text, bio: bc.text);
          if (ok) {
            unawaited(
                ref.read(currentUserControllerProvider.notifier).refresh());
          }
          return (ok, ok ? 'Profile updated' : 'Update failed');
        },
      ),
    );
  }

  // ── Change password dialog ────────────────────────────────────────────────

  void _showChangePassword() {
    final cc = TextEditingController();
    final nc = TextEditingController();
    final fc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _Dialog(
        title: 'Change Password',
        fields: [
          _DialogField(
              ctrl: cc,
              label: 'Current password',
              hint: '••••••••',
              obscure: true),
          _DialogField(
              ctrl: nc,
              label: 'New password',
              hint: '••••••••',
              obscure: true),
          _DialogField(
              ctrl: fc,
              label: 'Confirm new password',
              hint: '••••••••',
              obscure: true),
        ],
        onConfirm: () async {
          final ok = await ref
              .read(settingsControllerProvider.notifier)
              .updatePassword(
                currentPassword: cc.text,
                newPassword: nc.text,
                confirmPassword: fc.text,
              );
          return (ok, ok ? 'Password changed' : 'Failed to change password');
        },
      ),
    );
  }

  // ── Update email dialog ───────────────────────────────────────────────────

  void _showUpdateEmail() {
    final ec = TextEditingController();
    final pc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _Dialog(
        title: 'Update Email',
        fields: [
          _DialogField(
              ctrl: ec,
              label: 'New email address',
              hint: 'you@example.com',
              keyboard: TextInputType.emailAddress),
          _DialogField(
              ctrl: pc,
              label: 'Current password',
              hint: '••••••••',
              obscure: true),
        ],
        onConfirm: () async {
          if (ec.text.trim().isEmpty) {
            return (false, 'Please enter an email address');
          }
          final ok = await ref
              .read(settingsControllerProvider.notifier)
              .updateEmail(email: ec.text.trim(), password: pc.text);
          return (
            ok,
            ok
                ? 'Email update requested. Check your inbox.'
                : 'Failed to update email',
          );
        },
      ),
    );
  }

  // ── Privacy dialog ────────────────────────────────────────────────────────

  void _showPrivacy() async {
    final raw = await ref
        .read(settingsControllerProvider.notifier)
        .getPrivacySettings();
    if (!mounted) return;

    // API field is "discoverable" — true means public, false means private
    bool discoverable = raw?['discoverable'] as bool? ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Privacy',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrivacyTile(
                icon: Icons.public_rounded,
                title: 'Public account',
                subtitle: 'Anyone can see your content',
                selected: discoverable,
                onTap: () => set(() => discoverable = true),
              ),
              const SizedBox(height: 8),
              _PrivacyTile(
                icon: Icons.lock_rounded,
                title: 'Private account',
                subtitle: 'Only approved followers see your content',
                selected: !discoverable,
                onTap: () => set(() => discoverable = false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black),
              onPressed: () async {
                final ok = await ref
                    .read(settingsControllerProvider.notifier)
                    .updatePrivacySettings({'discoverable': discoverable});
                if (ctx.mounted) Navigator.pop(ctx);
                _snack(ok ? 'Privacy updated' : 'Failed to save',
                    error: !ok);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete / disable dialog ───────────────────────────────────────────────

  void _showDeleteAccount({required bool disable}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          disable ? 'Disable Account' : 'Delete Account',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          disable
              ? 'Your account will be suspended. You can reactivate it by contacting support or logging in again.'
              : 'This permanently deletes your account and all your videos. There is no way to undo this.',
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final ctrl = ref.read(settingsControllerProvider.notifier);
              final ok = disable
                  ? await ctrl.disableAccount()
                  : await ctrl.deleteAccount();
              if (ok && mounted) {
                await ref.read(authRepositoryProvider).logout();
                if (mounted) context.go('/login');
              } else if (mounted) {
                _snack('Operation failed. Try again.', error: true);
              }
            },
            child: Text(disable ? 'Disable' : 'Delete permanently'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserControllerProvider);
    final user = userState.asData?.value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Profile card ─────────────────────────────────────────────────
          _ProfileCard(
            user: user,
            avatarLoading: _avatarLoading,
            onAvatarTap: _pickAvatar,
          ),

          const SizedBox(height: 8),

          // ── Account section ───────────────────────────────────────────────
          _Section(
            title: 'Account',
            items: [
              _Item(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => _showEditProfile(user?.name, user?.bio),
              ),
              _Item(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: _showChangePassword,
              ),
              _Item(
                icon: Icons.email_outlined,
                label: 'Update Email',
                onTap: _showUpdateEmail,
              ),
              _Item(
                icon: Icons.visibility_outlined,
                label: 'Privacy',
                subtitle: 'Public / private account',
                onTap: _showPrivacy,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── General section ───────────────────────────────────────────────
          _Section(
            title: 'General',
            items: [
              _Item(
                icon: Icons.cleaning_services_outlined,
                label: 'Clear Cache',
                onTap: () async {
                  await DefaultCacheManager().emptyCache();
                  if (mounted) _snack('Cache cleared');
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Danger zone ───────────────────────────────────────────────────
          if (user != null)
            _Section(
              title: 'Account Actions',
              items: [
                _Item(
                  icon: Icons.pause_circle_outline_rounded,
                  label: 'Disable Account',
                  labelColor: Colors.orange,
                  onTap: () => _showDeleteAccount(disable: true),
                ),
                _Item(
                  icon: Icons.delete_forever_outlined,
                  label: 'Delete Account',
                  labelColor: Colors.redAccent,
                  onTap: () => _showDeleteAccount(disable: false),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // ── Logout ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: user != null ? _logout : () => context.go('/login'),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      user != null
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user != null ? 'Sign out' : 'Sign in',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Loops v1.0.0',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.avatarLoading,
    required this.onAvatarTap,
  });

  final dynamic user;
  final bool avatarLoading;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final username = user?.username as String? ?? '';
    final name = user?.name as String?;
    final avatar = user?.avatar as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar + edit overlay
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey.shade900,
                  backgroundImage: avatar != null && avatar.isNotEmpty
                      ? CachedNetworkImageProvider(avatar)
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white54, size: 32)
                      : null,
                ),
                if (avatarLoading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 11, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null && name.isNotEmpty)
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  username.isNotEmpty ? '@$username' : 'Not signed in',
                  style: TextStyle(
                    color: name != null && name.isNotEmpty
                        ? Colors.white54
                        : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings section ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                          height: 1,
                          indent: 52,
                          color: Colors.white10),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF141414),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  color: labelColor ?? Colors.white60, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: labelColor ?? Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Privacy tile ─────────────────────────────────────────────────────────────

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.white38 : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Generic dialog with fields ───────────────────────────────────────────────

typedef _OnConfirm = Future<(bool, String)> Function();

class _Dialog extends StatefulWidget {
  const _Dialog({
    required this.title,
    required this.fields,
    required this.onConfirm,
  });

  final String title;
  final List<_DialogField> fields;
  final _OnConfirm onConfirm;

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.fields
            .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: f,
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white54)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black),
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  final (ok, msg) = await widget.onConfirm();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: ok ? null : const Color(0xFF3D1010),
                      ),
                    );
                  }
                },
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.lines = 1,
    this.keyboard,
  });

  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool obscure;
  final int lines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          maxLines: lines,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
