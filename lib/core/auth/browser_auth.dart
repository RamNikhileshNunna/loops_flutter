import 'browser_auth_io.dart'
    if (dart.library.html) 'browser_auth_web.dart' as impl;

/// A browser-based OAuth session using the loopback-redirect pattern: a local
/// HTTP server listens on 127.0.0.1, the system browser is opened to the
/// authorize URL, and the server captures the redirect (with the auth `code`
/// or `token`). This replaces the in-app webview flow so desktop builds don't
/// need WebKitGTK.
abstract class BrowserAuthSession {
  /// The loopback redirect URI to register with the OAuth server and pass as
  /// `redirect_uri` in the authorize URL. Known up-front so it can be embedded
  /// in the request and registered with the instance.
  String get redirectUri;

  /// Opens [authUrl] in the system browser and completes with the full redirect
  /// URL once the browser hits the loopback callback, or null on timeout.
  Future<String?> waitForRedirect(String authUrl);

  Future<void> close();
}

/// Starts a loopback auth session. Throws [UnsupportedError] on web.
Future<BrowserAuthSession> startBrowserAuth() => impl.startBrowserAuth();
