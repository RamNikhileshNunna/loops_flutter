import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loops_flutter/app/loops_app.dart';
import 'package:loops_flutter/app/widgets/safe_error_widget.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';

/// Application entry point.
///
/// Kept deliberately small — it only performs one-time platform bootstrap and
/// hands off to [LoopsApp]. Everything else lives under `lib/app/` (root app,
/// router, shell, navigation) and `lib/features/` (per-feature screens):
///
///   lib/
///     main.dart                  ← you are here: bootstrap + runApp
///     app/                       ← cross-feature app wiring
///       loops_app.dart           ← root MaterialApp (themes + router)
///       router/app_router.dart   ← GoRouter + auth redirect guard
///       shell/                   ← persistent shell around the tabs
///         main_screen.dart       ← responsive layout + tab/back state
///         widgets/               ← bottom nav + side rail
///         upload/                ← video upload flow + progress dialog
///       widgets/                 ← app-wide widgets (error placeholder)
///     core/                      ← shared infra (network, storage, theme, …)
///     features/{feature}/        ← data / domain / presentation per feature
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the desktop video backend (libmpv via media_kit). No-op-safe on
  // mobile/web, where playback falls back to video_player.
  MediaKit.ensureInitialized();

  // Replace the default red error screen with a quiet, on-brand placeholder so
  // an isolated render error on one device never shows a scary crash overlay.
  ErrorWidget.builder = (details) => const SafeErrorWidget();

  // Load SharedPreferences once and inject it so the synchronous
  // [storageServiceProvider] never has to handle a "still loading" state.
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
