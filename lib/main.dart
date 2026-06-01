import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/feed/data/repositories/video_upload_repository_impl.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'package:dio/dio.dart';

// ─── Shell / main scaffold ────────────────────────────────────────────────────

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Tab index — never 2 (upload is an action, not a destination)
  int _activeTab = 0;
  final List<int> _tabHistory = [0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTabFromRoute();
  }

  void _syncTabFromRoute() {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = loc.startsWith('/explore')
        ? 1
        : loc.startsWith('/activity')
            ? 3
            : loc.startsWith('/profile')
                ? 4
                : 0;

    if (idx != _activeTab) {
      setState(() => _activeTab = idx);
      if (_tabHistory.isEmpty || _tabHistory.last != idx) {
        _tabHistory.add(idx);
        if (_tabHistory.length > 12) _tabHistory.removeAt(0);
      }
    }
  }

  void _navigateTo(int idx) {
    if (idx == _activeTab) return;
    switch (idx) {
      case 0:
        context.go('/');
      case 1:
        context.go('/explore');
      case 3:
        context.go('/activity');
      case 4:
        context.go('/profile');
    }
  }

  // ── Upload flow ──────────────────────────────────────────────────────────

  Future<void> _startUpload() async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);

    final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    if (!context.mounted) return;

    // Caption dialog
    String? caption;
    caption = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Add a caption',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Say something about your video…',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text('Skip', style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black),
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    final repo = ref.read(videoUploadRepositoryProvider);
    final progress = ValueNotifier<double>(0.0);

    // Show progress dialog (non-blocking — upload runs in parallel)
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _UploadProgressDialog(progress: progress),
      ),
    );

    try {
      await repo.uploadVideo(
        file: picked,
        caption: caption,
        onProgress: (sent, total) {
          if (total > 0) progress.value = sent / total;
        },
      );
      if (context.mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        String msg = 'Upload failed';
        if (e is DioException) {
          msg += ': ${e.response?.data?['message'] ?? e.message}';
        } else {
          msg += ': $e';
        }
        messenger.showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  // ── Back button ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canGoBack = _tabHistory.length > 1;

    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() => _tabHistory.removeLast());
        _navigateTo(_tabHistory.last);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true, // video bleeds behind the nav bar
        body: widget.child,
        bottomNavigationBar: _BottomNav(
          activeTab: _activeTab,
          onTabTap: _navigateTo,
          onUploadTap: _startUpload,
        ),
      ),
    );
  }
}

// ─── Custom bottom nav bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.activeTab,
    required this.onTabTap,
    required this.onUploadTap,
  });

  final int activeTab;
  final void Function(int) onTabTap;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.85),
            Colors.black,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                active: activeTab == 0,
                onTap: () => onTabTap(0),
              ),
              _NavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Explore',
                active: activeTab == 1,
                onTap: () => onTabTap(1),
              ),

              // Upload button — centre, distinctive
              Expanded(
                child: GestureDetector(
                  onTap: onUploadTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              _NavItem(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: 'Activity',
                active: activeTab == 3,
                onTap: () => onTabTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                active: activeTab == 4,
                onTap: () => onTabTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                active ? activeIcon : icon,
                key: ValueKey(active),
                color: active ? Colors.white : Colors.white38,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Upload progress dialog ───────────────────────────────────────────────────

class _UploadProgressDialog extends StatelessWidget {
  const _UploadProgressDialog({required this.progress});
  final ValueNotifier<double> progress;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Uploading…',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, value, __) {
          final pct = (value * 100).clamp(0.0, 100.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── App entry ────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace the default red error screen with a quiet, on-brand placeholder so
  // an isolated render error on one device never shows a scary crash overlay.
  ErrorWidget.builder = (details) => const _SafeErrorWidget();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(StorageService(prefs)),
      ],
      child: const LoopsApp(),
    ),
  );
}

class _SafeErrorWidget extends StatelessWidget {
  const _SafeErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 32),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authRepo = ref.read(authRepositoryProvider);
      final isAuthenticated = await authRepo.isAuthenticated();
      final isLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginPage) return '/login';
      if (isAuthenticated && isLoginPage) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/activity', builder: (_, __) => const ActivityScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/user/:id',
        builder: (_, state) =>
            UserProfileScreen(userId: state.pathParameters['id']!),
      ),
    ],
  );
});

class LoopsApp extends ConsumerWidget {
  const LoopsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Loops',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      builder: (context, child) {
        // Clamp text scaling so devices with very large system font settings
        // can't overflow the fixed-size video overlays and nav bars.
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.2,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Enables smooth dragging with touch, mouse and trackpad on every platform
/// (desktop/web included) so the feed and grids scroll consistently anywhere.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
