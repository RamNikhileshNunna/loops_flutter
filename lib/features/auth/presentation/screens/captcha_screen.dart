import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Cloudflare Turnstile integration used by loops.video.
///
/// The Turnstile site key is domain-bound. On Android WebView, loading HTML via a raw `data:`
/// URL results in an opaque origin and Turnstile returns "Invalid domain".
///
/// Fix: load the HTML with a `baseUrl` of `https://loops.video`, so the document origin is
/// considered loops.video by the WebView engine.
class CaptchaScreen extends StatefulWidget {
  const CaptchaScreen({super.key, required this.siteKey});

  final String siteKey;

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  late final WebViewController _controller;

  static final Uri _baseUrl = Uri.parse('https://loops.video/');

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Turnstile',
        onMessageReceived: (message) {
          final token = message.message.trim();
          if (token.isEmpty) return;
          if (!mounted) return;
          Navigator.of(context).pop(token);
        },
      )
      ..loadHtmlString(
        _html(siteKey: widget.siteKey),
        baseUrl: _baseUrl.toString(),
      );
  }

  String _html({required String siteKey}) {
    final payload = {'siteKey': siteKey};

    return '''<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body { background: #000; color: #fff; margin: 0; display: flex; align-items: center; justify-content: center; height: 100vh; }
    </style>
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
  </head>
  <body>
    <div>
      <div class="cf-turnstile" data-sitekey="$siteKey" data-callback="onTurnstile"></div>
    </div>
    <script>
      const cfg = ${jsonEncode(payload)};
      function onTurnstile(token) {
        try { Turnstile.postMessage(token); } catch (e) {}
      }
    </script>
  </body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captcha')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
