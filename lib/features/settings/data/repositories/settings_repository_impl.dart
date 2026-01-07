import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/core/network/api_client.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepositoryImpl(apiClient);
});

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepositoryImpl(this._apiClient);

  Future<bool> _postWithCsrf(String path, {dynamic data}) async {
    try {
      await _apiClient.ensureCsrfCookie();
      final response = await _apiClient.post(path, data: data);
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return _postWithCsrf(
      'api/v1/account/settings/update-password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );
  }

  @override
  Future<bool> updateProfile({String? name, String? bio}) async {
    return _postWithCsrf(
      'api/v1/account/settings/bio',
      data: {if (name != null) 'name': name, if (bio != null) 'bio': bio},
    );
  }

  @override
  Future<bool> updateDataSettings({
    required String dataRetentionPeriod,
    required bool analyticsTracking,
    required bool researchDataSharing,
  }) async {
    return _postWithCsrf(
      'api/v1/account/settings/data',
      data: {
        'data_retention_period': dataRetentionPeriod,
        'analytics_tracking': analyticsTracking,
        'research_data_sharing': researchDataSharing,
      },
    );
  }
}
