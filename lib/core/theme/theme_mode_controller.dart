import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/storage/storage_service.dart';

/// Holds the user's appearance preference (System / Light / Dark) and persists
/// it to [StorageService]. Watched by the root [MaterialApp] so a change takes
/// effect instantly across the whole app.
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.watch(storageServiceProvider).getThemeMode();
    return _fromString(stored);
  }

  /// Persist and apply a new appearance preference.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(storageServiceProvider).setThemeMode(_toString(mode));
  }

  static ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
