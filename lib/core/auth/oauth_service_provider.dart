import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/core/auth/oauth_service.dart';
import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';

final oauthServiceProvider = Provider<OAuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return OAuthService(apiClient.dio, storage);
});
