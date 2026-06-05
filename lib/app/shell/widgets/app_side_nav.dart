import 'package:flutter/material.dart';

import 'package:loops_flutter/features/studio/presentation/screens/studio_screen.dart';

/// The desktop / wide-window left navigation rail.
///
/// Collapses to an icon-only strip on medium widths and expands to show labels
/// and the "Loops" wordmark on wide windows ([expanded]). Mirrors the tab set
/// of `AppBottomNav` but adds a Studio entry that — like Settings from the
/// profile screen — is a *pushed* destination rather than a feed tab.
class AppSideNav extends StatelessWidget {
  const AppSideNav({
    super.key,
    required this.activeTab,
    required this.onTabTap,
    required this.onUploadTap,
    required this.expanded,
  });

  final int activeTab;
  final void Function(int) onTabTap;
  final VoidCallback onUploadTap;

  /// When true the rail is wide and shows text labels; otherwise icon-only.
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
            // Brand header: wordmark when expanded, logo glyph when collapsed.
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
            // Settings opens from the profile screen. Wrapped in a Builder so
            // the push uses a context *below* the Navigator.
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

/// One rail destination. Lays out as an icon+label row when [expanded], or a
/// centred icon when collapsed.
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
                    child: Icon(active ? activeIcon : icon,
                        color: color, size: 28),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The primary "Upload" call-to-action at the bottom of the rail; a filled
/// brand-coloured button that adapts to the collapsed/expanded width.
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
