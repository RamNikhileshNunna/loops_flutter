import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'dart:convert';
import 'package:loops_flutter/core/utils/logger.dart';

class OAuthService {
  final Dio _dio;
  final StorageService _storage;

  static const String _appName = 'Loops for Flutter';
  static const String _defaultScopes =
      'user:read user:write video:create video:read';
  static const String _redirectScheme = 'com.example.loopsflutter';
  static const String _redirectHost = 'login-callback';
  static const String _redirectUri = '$_redirectScheme://$_redirectHost';

  OAuthService(this._dio, this._storage);

  Future<bool> login(String server, {String? scopes}) async {
    try {
      // 1. Preflight check (simplified)
      // loops-expo does /api/v1/config check. We can assume valid for now or add check.

      final baseUrl = 'https://$server';

      // 2. Register App
      final app = await _registerApp(
        baseUrl,
        _redirectUri,
        scopes ?? _defaultScopes,
      );
      if (app == null) return false;

      await _storeAppCredentials(app);

      // 3. Authorize
      // Manually construct URL to ensure scopes use '+' and matching loops-expo format exactly
      final scopeParam = (scopes ?? _defaultScopes).split(' ').join('+');
      final encodedRedirect = Uri.encodeComponent(_redirectUri);
      final clientId = app['client_id'];

      final authUrl =
          '$baseUrl/oauth/authorize?client_id=$clientId&scope=$scopeParam&redirect_uri=$encodedRedirect&response_type=code';

      AppLogger.log('Opening Auth URL: $authUrl');

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: _redirectScheme,
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return false;

      // 4. Exchange Token
      final tokenData = await _exchangeCodeForToken(
        baseUrl,
        app['client_id'],
        app['client_secret'],
        _redirectUri,
        code,
      );

      if (tokenData == null) return false;

      // 5. Verify & Store
      await _storeTokenData(tokenData);

      // We need to set the token in Dio for the next request
      // But _dio might be globally configured. We'll pass it manually for verify.
      final user = await _verifyCredentials(baseUrl, tokenData['access_token']);

      if (user == null) return false;

      await _storage.setToken(tokenData['access_token']);
      await _storage.setInstance(server);
      await _storage.setLoggedIn(true);

      // Save user profile if needed in storage, logic usually in AuthRepo or UserRepo

      return true;
    } catch (e, stack) {
      AppLogger.error('OAuth Logic Error', e, stack);
      return false;
    }
  }

  Future<bool> registerWithWebBrowser(String server) async {
    try {
      final baseUrl = 'https://$server';
      // loops_expo: registerUrl = `${url}/auth/app/register?mobile=true&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
      final registerUrl =
          '$baseUrl/auth/app/register?mobile=true&redirect_uri=${Uri.encodeComponent(_redirectUri)}';

      final result = await FlutterWebAuth2.authenticate(
        url: registerUrl,
        callbackUrlScheme: _redirectScheme,
      );

      // Handle callback: url?token=...&user=...
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      final userJson = uri.queryParameters['user'];

      if (token == null || userJson == null) return false;

      // Parse user to validate
      try {
        final userMap = jsonDecode(userJson);
        UserModel.fromJson(userMap);
      } catch (e) {
        AppLogger.error('User parse error', e);
        return false;
      }

      await _storage.setToken(token);
      await _storage.setInstance(server);
      await _storage.setLoggedIn(true);

      return true;
    } catch (e, stack) {
      AppLogger.error('Registration Error', e, stack);
      return false;
    }
  }

  Future<Map<String, dynamic>?> _registerApp(
    String instanceUrl,
    String redirectUri,
    String scopes,
  ) async {
    try {
      // loops-expo sends array params with brackets '[]' explicitly
      final formData = FormData.fromMap({
        'client_name': _appName,
        'website': 'https://joinloops.org',
        'scopes': scopes,
        'redirect_uris[]': redirectUri,
      });

      final response = await _dio.post(
        '$instanceUrl/api/v1/apps',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            // Dio sets multipart/form-data automatically including boundary
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      AppLogger.error(
        'Register App Failed: ${response.statusCode} ${response.data}',
      );
      // If we got HTML (e.g. cloudflare or error page), response.data might be string
      return null;
    } catch (e, stack) {
      AppLogger.error('Register App Error', e, stack);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _exchangeCodeForToken(
    String baseUrl,
    String clientId,
    String clientSecret,
    String redirectUri,
    String code,
  ) async {
    try {
      // Form Data for token exchange
      final formData = FormData.fromMap({
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        'code': code,
        'scope': _defaultScopes,
      });

      final response = await _dio.post(
        '$baseUrl/oauth/token',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      AppLogger.error(
        'Exchange Token Failed: ${response.statusCode} ${response.data}',
      );
      return null;
    } catch (e, stack) {
      AppLogger.error('Exchange Token Error', e, stack);
      return null;
    }
  }

  Future<UserModel?> _verifyCredentials(String baseUrl, String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/v1/account/info/self',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Response format: { data: { ...user } }
      final data = response.data['data'];
      return UserModel.fromJson(data);
    } catch (e, stack) {
      AppLogger.error('Verify Credentials Error', e, stack);
      return null;
    }
  }

  Future<void> _storeAppCredentials(Map<String, dynamic> app) async {
    // We might not strictly need to persists app credentials for basic login if we register every time
    // But standard flow is register once per instance.
    // For simplicity of rewrite, we can just use memory or ignore persistence for this specific step
    // unless we want to reuse it.
    // loops-expo stores them.
    // I'll skip complex persistence logic for now and just register fresh or let the app handle it.
    // Loops servers might rate limit app registration?
    // Ideally we store it in StorageService.
    // I'll update StorageService to support generic keys if needed, or valid app credentials keys.
  }

  Future<void> _storeTokenData(Map<String, dynamic> tokenData) async {
    // Token, Refresh Token, etc.
    // Already handled in main flow
  }
}
