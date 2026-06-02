import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 theming for Loops.
///
/// The app is intentionally dark and immersive (full-bleed video feed), so the
/// dark scheme is the primary surface. Both schemes are seeded from the Loops
/// brand pink so every M3 component — buttons, dialogs, sheets, chips, inputs,
/// progress indicators — picks up a consistent tonal palette automatically,
/// on mobile and desktop alike.
class AppTheme {
  AppTheme._();

  /// Loops brand pink/red. Used as the Material 3 seed colour.
  static const Color brand = Color(0xFFFF2D55);

  // ─── Colour schemes ─────────────────────────────────────────────────────────

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.dark,
  ).copyWith(
    // Keep the immersive pure-black canvas; the seeded surfaceContainer roles
    // stay as tinted dark greys for cards, sheets and dialogs.
    surface: const Color(0xFF000000),
    onSurface: Colors.white,
    // The brand colour reads as the accent throughout (likes, FABs, active
    // states) rather than the muted seeded primary.
    primary: brand,
    onPrimary: Colors.white,
    secondary: brand,
  );

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.light,
  );

  // ─── Public themes ──────────────────────────────────────────────────────────

  static ThemeData get darkTheme => _build(_darkScheme);
  static ThemeData get lightTheme => _build(_lightScheme);

  // ─── Builder ────────────────────────────────────────────────────────────────

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryColor: scheme.primary,

      // Progress indicators — themed once, consistent everywhere.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? Colors.white : scheme.primary,
        linearTrackColor: scheme.onSurface.withValues(alpha: 0.12),
        circularTrackColor: Colors.transparent,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        selectedIconTheme: IconThemeData(color: scheme.onSurface),
        unselectedIconTheme:
            IconThemeData(color: scheme.onSurface.withValues(alpha: 0.55)),
        selectedLabelTextStyle: textTheme.labelLarge
            ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelLarge
            ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.55)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.85),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.onSurface.withValues(alpha: 0.3),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : null,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.white : scheme.onInverseSurface,
        ),
        actionTextColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.25)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.45)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
        selectedColor: scheme.primary,
        side: BorderSide.none,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withValues(alpha: 0.8),
        titleTextStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
        subtitleTextStyle: textTheme.bodyMedium
            ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),

      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF161616) : scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.5),
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
