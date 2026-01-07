import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Directory, File, Platform;

import '../storage/storage_service.dart';
import '../utils/logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

class ApiClient {
  final StorageService _storage;
  final Dio _dio;
  Dio get dio => _dio;
  CookieJar _cookieJar;

  ApiClient(this._storage)
    : _cookieJar = DefaultCookieJar(),
      _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          followRedirects: true,
          validateStatus: (code) => code != null && code >= 200 && code < 500,
        ),
      ) {
    _initCookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    // Attach Sanctum XSRF header if present.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final cookies = await _cookieJar.loadForRequest(options.uri);
            Cookie? xsrf;
            for (final c in cookies) {
              if (c.name == 'XSRF-TOKEN') {
                xsrf = c;
                break;
              }
            }
            if (xsrf != null) {
              options.headers['X-XSRF-TOKEN'] = Uri.decodeComponent(xsrf.value);
              AppLogger.log(
                'Added XSRF-TOKEN header: ${xsrf.value.substring(0, xsrf.value.length > 20 ? 20 : xsrf.value.length)}...',
              );
            } else {
              AppLogger.log('No XSRF-TOKEN cookie found for ${options.uri}');
            }
          } catch (e) {
            AppLogger.error('Error loading cookies for XSRF', e);
          }
          handler.next(options);
        },
      ),
    );
  }

  String _getBaseUrl() {
    final instance = _storage.getInstance();
    if (instance == null || instance.isEmpty) {
      // Default or throw? For now default to a known instance or throw.
      // loops-expo source doesn't seem to have a hardcoded default, it asks user?
      // We will assume the user has set it or we provide a default for testing.
      return 'https://loops.video';
    }
    return 'https://$instance';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = _storage.getToken();
    final base = _getBaseUrl();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      // Sanctum commonly expects origin/referer for SPA-like flows.
      'Origin': base,
      'Referer': '$base/',
      'User-Agent': 'LoopsFlutter/0.1 (Flutter; Dio)',
      // Keep bearer support for other instances (if you later implement OAuth).
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _initCookieJar() {
    // Start with in-memory cookie jar (works everywhere, no file system needed)
    // Try to upgrade to persistent storage in the background
    // Only on platforms that support it (not web, and only if we can write)
    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS)) {
      getApplicationDocumentsDirectory()
          .then((appDocDir) {
            try {
              // Test if we can write to this directory
              final testFile = File('${appDocDir.path}/.cookie_test');
              try {
                testFile.writeAsStringSync('test');
                testFile.deleteSync();

                // If we can write, create the cookie directory
                final cookieDir = Directory('${appDocDir.path}/cookies');
                if (!cookieDir.existsSync()) {
                  cookieDir.createSync(recursive: true);
                }
                // Create new persistent jar and migrate cookies if needed
                final newJar = PersistCookieJar(
                  storage: FileStorage(cookieDir.path),
                );
                // Note: We can't easily migrate cookies from DefaultCookieJar to PersistCookieJar
                // So we'll just switch to persistent for future requests
                _cookieJar = newJar;
                // Update the CookieManager to use the new jar
                _dio.interceptors.removeWhere(
                  (interceptor) => interceptor is CookieManager,
                );
                _dio.interceptors.insert(0, CookieManager(_cookieJar));
                AppLogger.log(
                  'Upgraded to persistent cookie jar at: ${cookieDir.path}',
                );
              } catch (e) {
                // Can't write to directory, keep using in-memory
                AppLogger.error(
                  'Cannot write to directory, using in-memory cookies',
                  e,
                );
              }
            } catch (e) {
              // If directory creation fails, keep using in-memory
              AppLogger.error('Failed to create cookie directory', e);
            }
          })
          .catchError((e) {
            // Keep using in-memory if file system access fails
            AppLogger.error('Failed to initialize persistent cookie jar', e);
          });
    } else {
      AppLogger.log('Using in-memory cookie jar (web or unsupported platform)');
    }
  }

  bool _isAbsolute(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  Future<void> ensureCsrfCookie() async {
    final baseUrl = _getBaseUrl();
    await _dio.get(
      '$baseUrl/sanctum/csrf-cookie',
      options: Options(headers: await _getHeaders(), followRedirects: true),
    );

    // Verify CSRF cookie was received (debug only)
    if (kDebugMode) {
      try {
        final cookies = await _cookieJar.loadForRequest(Uri.parse(baseUrl));
        final xsrfCookie = cookies.firstWhere((c) => c.name == 'XSRF-TOKEN');
        AppLogger.log(
          'CSRF cookie received: ${xsrfCookie.name}=${xsrfCookie.value.substring(0, xsrfCookie.value.length > 20 ? 20 : xsrfCookie.value.length)}...',
        );
      } catch (e) {
        AppLogger.log(
          'Warning: XSRF-TOKEN cookie not found after ensureCsrfCookie: $e',
        );
      }
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    final url = _isAbsolute(path) ? path : '$baseUrl/$path';
    return _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    final url = _isAbsolute(path) ? path : '$baseUrl/$path';

    if (data is FormData) {
      headers.remove('Content-Type');
    }

    final mergedOptions = _mergeOptionsHeaders(options, headers);
    return _dio.post(
      url,
      data: data,
      options: mergedOptions,
      onSendProgress: onSendProgress,
    );
  }

  Options _mergeOptionsHeaders(
    Options? base,
    Map<String, String> defaultHeaders,
  ) {
    // defaultHeaders are the API defaults; caller-specified headers should win.
    if (base == null) return Options(headers: defaultHeaders);
    final merged = <String, dynamic>{};
    merged.addAll(defaultHeaders);
    if (base.headers != null) merged.addAll(base.headers!);
    return base.copyWith(headers: merged);
  }

  /// Clears all cookies (session + XSRF) to avoid stale auth after logout/login.
  Future<void> clearCookies() async {
    try {
      await _cookieJar.deleteAll();
      AppLogger.log('Cleared cookies');
    } catch (e) {
      AppLogger.error('Failed to clear cookies', e);
    }
  }
}
