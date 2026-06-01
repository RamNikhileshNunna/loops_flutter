import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
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

  // POST /api/v1/account/settings/email/update — requires email + current password
  @override
  Future<bool> updateEmail({required String email, String? password}) async {
    return _postWithCsrf(
      'api/v1/account/settings/email/update',
      data: {'email': email, if (password != null) 'password': password},
    );
  }

  @override
  Future<bool> updateAvatar(String filePath) async {
    try {
      await _apiClient.ensureCsrfCookie();
      final ext = filePath.toLowerCase().split('.').last;
      final subtype = ext == 'png'
          ? 'png'
          : ext == 'gif'
              ? 'gif'
              : 'jpeg';
      final multipart = await MultipartFile.fromFile(
        filePath,
        filename: 'avatar.$ext',
        contentType: MediaType('image', subtype),
      );
      final form = FormData.fromMap({'avatar': multipart});
      // Must NOT send Content-Type header manually — Dio sets it with boundary
      final response = await _apiClient.post(
        'api/v1/account/settings/update-avatar',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPrivacySettings() async {
    try {
      final response =
          await _apiClient.get('api/v1/account/settings/privacy');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        if (data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Field is "discoverable" (not "is_private")
  @override
  Future<bool> updatePrivacySettings(Map<String, dynamic> settings) async {
    return _postWithCsrf('api/v1/account/settings/privacy', data: settings);
  }

  @override
  Future<bool> disableAccount() async {
    return _postWithCsrf('api/v1/account/disable');
  }

  @override
  Future<bool> deleteAccount() async {
    return _postWithCsrf('api/v1/account/delete');
  }
}
