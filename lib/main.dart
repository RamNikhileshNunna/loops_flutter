import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/responsive/responsive.dart';
import 'features/explore/presentation/widgets/desktop_sidebar.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'package:go_router/go_router.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/studio/presentation/screens/studio_screen.dart';
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
          title: const Text('Add a caption'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Say something about your video…',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Skip'),
            ),
            FilledButton(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= Breakpoints.medium;
          return desktop ? _buildDesktop(constraints) : _buildMobile();
        },
      ),
    );
  }

  // Phone / narrow window: full-bleed body + bottom nav.
  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true, // video bleeds behind the nav bar
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        activeTab: _activeTab,
        onTabTap: _navigateTo,
        onUploadTap: _startUpload,
      ),
    );
  }

  // Desktop: left rail · centered content · optional right sidebar.
  Widget _buildDesktop(BoxConstraints constraints) {
    final wide = constraints.maxWidth >= Breakpoints.expanded;
    // The feed stays phone-shaped in a centered column; grids/lists fill the
    // available area instead.
    final Widget content = _activeTab == 0
        ? Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: Breakpoints.feedColumn),
              child: ClipRect(child: widget.child),
            ),
          )
        : widget.child;

    final divider = Theme.of(context).colorScheme.outlineVariant;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          _SideNav(
            activeTab: _activeTab,
            onTabTap: _navigateTo,
            onUploadTap: _startUpload,
            expanded: wide,
          ),
          VerticalDivider(width: 1, color: divider),
          Expanded(child: content),
          if (wide) ...[
            VerticalDivider(width: 1, color: divider),
            const DesktopSidebar(),
          ],
        ],
      ),
    );
  }
}

// ─── Desktop side navigation rail ─────────────────────────────────────────────

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.activeTab,
    required this.onTabTap,
    required this.onUploadTap,
    required this.expanded,
  });

  final int activeTab;
  final void Function(int) onTabTap;
  final VoidCallback onUploadTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: expanded ? 220 : 76,
      color: cs.surface,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment:
              expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 22 : 0, vertical: 22),
              child: expanded
                  ? Text(
                      'Loops',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )
                  : Icon(Icons.all_inclusive_rounded,
                      color: cs.onSurface, size: 28),
            ),
            _SideNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              active: activeTab == 0,
              expanded: expanded,
              onTap: () => onTabTap(0),
            ),
            _SideNavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
              label: 'Explore',
              active: activeTab == 1,
              expanded: expanded,
              onTap: () => onTabTap(1),
            ),
            _SideNavItem(
              icon: Icons.notifications_none_rounded,
              activeIcon: Icons.notifications_rounded,
              label: 'Activity',
              active: activeTab == 3,
              expanded: expanded,
              onTap: () => onTabTap(3),
            ),
            _SideNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              active: activeTab == 4,
              expanded: expanded,
              onTap: () => onTabTap(4),
            ),
            // Studio is a pushed destination (not a feed tab), mirroring how
            // Settings opens from the profile screen.
            Builder(
              builder: (ctx) => _SideNavItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: 'Studio',
                active: false,
                expanded: expanded,
                onTap: () => Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const StudioScreen()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 14),
              child: _UploadButton(expanded: expanded, onTap: onUploadTap),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = active ? cs.onSurface : cs.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: expanded ? 12 : 0, vertical: 12),
            child: expanded
                ? Row(
                    children: [
                      Icon(active ? activeIcon : icon, color: color, size: 26),
                      const SizedBox(width: 16),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child:
                        Icon(active ? activeIcon : icon, color: color, size: 28),
                  ),
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.expanded, required this.onTap});
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: expanded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: cs.onPrimary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Upload',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              : Icon(Icons.add_rounded, color: cs.onPrimary, size: 26),
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
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            surface.withValues(alpha: 0.0),
            surface.withValues(alpha: 0.85),
            surface,
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
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
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
    final cs = Theme.of(context).colorScheme;
    final color = active ? cs.onSurface : cs.onSurfaceVariant;
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
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: color,
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
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text(
        'Uploading…',
        style: TextStyle(fontWeight: FontWeight.w700),
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
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
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

  // Initialise the desktop video backend (libmpv via media_kit). No-op-safe on
  // mobile/web, where playback falls back to video_player.
  MediaKit.ensureInitialized();

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
      themeMode: ref.watch(themeModeControllerProvider),
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
