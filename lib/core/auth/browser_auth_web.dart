import 'browser_auth.dart';

// Web cannot bind a loopback HTTP server. OAuth on web would need a redirect
// page flow; email/password login remains available.
Future<BrowserAuthSession> startBrowserAuth() async =>
    throw UnsupportedError('Browser-based OAuth is not supported on web.');
