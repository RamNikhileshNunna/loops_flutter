import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, void>(() {
      return SettingsController();
    });

class SettingsController extends AsyncNotifier<void> {
  late final SettingsRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(settingsRepositoryProvider);
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? bio}) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.updateProfile(name: name, bio: bio);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateDataSettings({
    required String dataRetentionPeriod,
    required bool analyticsTracking,
    required bool researchDataSharing,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.updateDataSettings(
        dataRetentionPeriod: dataRetentionPeriod,
        analyticsTracking: analyticsTracking,
        researchDataSharing: researchDataSharing,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
