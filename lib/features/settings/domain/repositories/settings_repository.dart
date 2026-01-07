
abstract class SettingsRepository {
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<bool> updateProfile({String? name, String? bio});

  Future<bool> updateDataSettings({
    required String dataRetentionPeriod,
    required bool analyticsTracking,
    required bool researchDataSharing,
  });
}
