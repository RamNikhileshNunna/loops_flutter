import 'package:flutter/widgets.dart';

/// Layout breakpoints used to switch between the phone UI and the desktop UI.
class Breakpoints {
  Breakpoints._();

  /// Below this we render the original phone layout (bottom nav, full-bleed).
  static const double medium = 880;

  /// At/above this the desktop layout also shows the right-hand sidebar.
  static const double expanded = 1200;

  /// Max width of the centered feed column on desktop (keeps it phone-shaped).
  static const double feedColumn = 480;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// True when there's enough width for the side-rail desktop layout.
  bool get isDesktopLayout => screenWidth >= Breakpoints.medium;

  /// True when there's room for the right-hand sidebar as well.
  bool get isWideDesktopLayout => screenWidth >= Breakpoints.expanded;
}

/// Number of grid columns that comfortably fit in [width].
///
/// Keeps tiles near [target] px wide, clamped to [min]..[max] columns, so a
/// grid that shows 3 columns on a phone fans out on a wide desktop window.
int gridColumnsForWidth(
  double width, {
  double target = 200,
  int min = 3,
  int max = 8,
}) {
  final n = (width / target).floor();
  if (n < min) return min;
  if (n > max) return max;
  return n;
}
