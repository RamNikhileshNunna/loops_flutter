import 'package:flutter/material.dart';

/// The phone / narrow-window bottom navigation bar.
///
/// A custom bar (rather than [NavigationBar]) because it overlays the
/// full-bleed video feed: the background is a transparent→surface gradient so
/// the video shows through near the top edge and the icons stay legible at the
/// bottom. The centre slot is the distinctive upload action rather than a
/// destination.
///
/// Tab indices are shared with the desktop rail and the router and are
/// intentionally sparse — index 2 is the upload action, not a tab:
///   0 Home · 1 Explore · (2 = upload) · 3 Activity · 4 Profile
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabTap,
    required this.onUploadTap,
  });

  /// Currently selected tab index (0/1/3/4).
  final int activeTab;

  /// Called with the tapped tab index.
  final void Function(int) onTabTap;

  /// Called when the centre upload button is tapped.
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        // Fade from fully transparent (video visible) to opaque surface at the
        // very bottom where the icons sit.
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
        top: false, // only pad the bottom (home indicator / gesture area)
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

              // Centre upload action — visually distinct, not a tab.
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

/// A single destination in [AppBottomNav]: an icon that swaps to its filled
/// variant when active, with a small label underneath. Animations give a subtle
/// press/selection feel.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon; // outline variant (inactive)
  final IconData activeIcon; // filled variant (active)
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
        behavior: HitTestBehavior.opaque, // whole cell is tappable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cross-fade between the outline/filled icons on selection.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                active ? activeIcon : icon,
                key: ValueKey(active), // force the switcher to animate
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
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
