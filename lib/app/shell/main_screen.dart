import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:loops_flutter/app/shell/upload/video_upload_flow.dart';
import 'package:loops_flutter/app/shell/widgets/app_bottom_nav.dart';
import 'package:loops_flutter/app/shell/widgets/app_side_nav.dart';
import 'package:loops_flutter/core/responsive/responsive.dart';
import 'package:loops_flutter/features/explore/presentation/widgets/desktop_sidebar.dart';

/// The persistent application shell that wraps every primary tab.
///
/// Hosted by the router's `ShellRoute`, so [child] is whichever tab screen the
/// current route resolves to. Responsibilities:
///   • choose a responsive layout — bottom nav on phones, a left rail (plus an
///     optional right sidebar) on desktop;
///   • keep the highlighted tab in sync with the current route;
///   • maintain a small tab-history stack so the system back button steps back
///     through visited tabs instead of leaving the app.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.child});

  /// The active tab's screen, provided by the router's ShellRoute.
  final Widget child;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Currently selected tab. Never 2 — index 2 is the upload action, not a tab.
  int _activeTab = 0;

  // Visited-tab stack powering back navigation between tabs.
  final List<int> _tabHistory = [0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route changes flow in here; mirror them onto [_activeTab].
    _syncTabFromRoute();
  }

  /// Derive the active tab from the current location so the nav highlight stays
  /// correct even when navigation is driven externally (deep link, back, etc.).
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
      // Record the visit (bounded so the history can't grow without limit).
      if (_tabHistory.isEmpty || _tabHistory.last != idx) {
        _tabHistory.add(idx);
        if (_tabHistory.length > 12) _tabHistory.removeAt(0);
      }
    }
  }

  /// Navigate to the route backing [idx]. No-op when already on that tab.
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

  /// Kicks off the video upload flow (defined in [startVideoUpload]).
  void _onUploadTap() => startVideoUpload(context, ref);

  @override
  Widget build(BuildContext context) {
    // We only intercept back when there's tab history to pop.
    final canGoBack = _tabHistory.length > 1;

    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return; // system already handled it
        // Pop the current tab off the history and return to the previous one.
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

  /// Phone / narrow window: full-bleed body with the bottom nav floating over it.
  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true, // video bleeds behind the translucent nav bar
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        activeTab: _activeTab,
        onTabTap: _navigateTo,
        onUploadTap: _onUploadTap,
      ),
    );
  }

  /// Desktop: left rail · centred content · optional right sidebar on wide
  /// windows.
  Widget _buildDesktop(BoxConstraints constraints) {
    final wide = constraints.maxWidth >= Breakpoints.expanded;

    // The feed keeps its phone-shaped column centred; every other tab (grids,
    // lists, profiles) fills the available width.
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
          AppSideNav(
            activeTab: _activeTab,
            onTabTap: _navigateTo,
            onUploadTap: _onUploadTap,
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
