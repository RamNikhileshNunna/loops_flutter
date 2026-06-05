import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/app/router/app_router.dart';
import 'package:loops_flutter/core/theme/app_theme.dart';
import 'package:loops_flutter/core/theme/theme_mode_controller.dart';

/// The root widget: a routed `MaterialApp` wired to the app's light/dark themes
/// and the `GoRouter` from [routerProvider].
///
/// `themeMode` is driven by [themeModeControllerProvider] (System/Light/Dark,
/// persisted in settings), so toggling appearance rebuilds the whole tree with
/// the new scheme.
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
        // A top-level Focus node (which never grabs focus itself) sits above
        // the whole navigator, so any key event unhandled by a focused widget
        // bubbles up here — letting Escape act as a global "back" on desktop.
        return Focus(
          canRequestFocus: false,
          onKeyEvent: _handleEscapeAsBack,
          child: MediaQuery(
            data: mq.copyWith(textScaler: clamped),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  /// Treats the Escape key like the system back button.
  ///
  /// Pops whatever is on top of the *focused* navigator first (a pushed screen
  /// such as Settings/Studio/a tag feed, or an open dialog). If that navigator
  /// has nothing to pop, it falls back to the root navigator's [maybePop] so
  /// the shell's tab-history back logic still runs.
  KeyEventResult _handleEscapeAsBack(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }

    final focusCtx = FocusManager.instance.primaryFocus?.context;
    final nav = focusCtx != null ? Navigator.maybeOf(focusCtx) : null;
    if (nav != null && nav.canPop()) {
      nav.maybePop();
      return KeyEventResult.handled;
    }

    // Nothing on the focused navigator → let the shell step back a tab.
    rootNavigatorKey.currentState?.maybePop();
    return KeyEventResult.handled;
  }
}

/// Enables smooth dragging with touch, mouse and trackpad on every platform
/// (desktop/web included) so the feed and grids scroll consistently anywhere.
///
/// By default Flutter omits mouse from [dragDevices], which would make the feed
/// un-draggable with a mouse on desktop.
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
