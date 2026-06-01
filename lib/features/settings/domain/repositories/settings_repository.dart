
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

  Future<bool> updateEmail({required String email, String? password});

  Future<bool> updateAvatar(String filePath);

  Future<Map<String, dynamic>?> getPrivacySettings();

  Future<bool> updatePrivacySettings(Map<String, dynamic> settings);

  Future<bool> disableAccount();

  Future<bool> deleteAccount();
}
