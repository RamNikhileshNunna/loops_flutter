import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import 'browser_auth.dart';

Future<BrowserAuthSession> startBrowserAuth() async {
  // Port 0 → the OS assigns a free ephemeral port; we read it back for the
  // redirect URI so each login uses a clean, exact-match loopback address.
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  return _IoBrowserAuthSession(server);
}

class _IoBrowserAuthSession implements BrowserAuthSession {
  _IoBrowserAuthSession(this._server);

  final HttpServer _server;

  @override
  String get redirectUri => 'http://127.0.0.1:${_server.port}/';

  @override
  Future<String?> waitForRedirect(String authUrl) async {
    final launched = await launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) return null;

    try {
      final request = await _server.first.timeout(const Duration(minutes: 5));
      final uri = request.uri;
      request.response
        ..statusCode = 200
        ..headers.set(HttpHeaders.contentTypeHeader, 'text/html; charset=utf-8')
        ..write(_closeHtml);
      await request.response.close();
      return uri.toString();
    } on TimeoutException {
      return null;
    }
  }

  @override
  Future<void> close() => _server.close(force: true);
}

const String _closeHtml =
    '<!doctype html><html><head><meta charset="utf-8"><title>Loops</title></head>'
    '<body style="font-family:sans-serif;background:#111;color:#fff;text-align:center;padding-top:80px">'
    '<h2>Login complete</h2><p>You can close this tab and return to Loops.</p>'
    '</body></html>';
