import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/notification_model.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ActivityRepositoryImpl(apiClient);
});

abstract class ActivityRepository {
  Future<ActivityPage> getNotifications({String? cursor});
}

class ActivityPage {
  final List<NotificationModel> notifications;
  final String? nextCursor;
  const ActivityPage({required this.notifications, required this.nextCursor});
}

class ActivityRepositoryImpl implements ActivityRepository {
  final ApiClient _apiClient;
  ActivityRepositoryImpl(this._apiClient);

  ActivityPage _parsePage(dynamic data) {
    // Handle various shapes: {data: [...], meta: {next_cursor}}
    // or {notifications: [...]} or a raw List
    List<dynamic> items = const [];
    String? nextCursor;

    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final raw = data['data'] ?? data['notifications'];
      items = raw is List ? raw : const [];

      final meta = data['meta'];
      if (meta is Map) {
        final v = meta['next_cursor'] ?? meta['nextCursor'];
        if (v != null) {
          final s = v.toString();
          if (s.isNotEmpty && s != 'null') nextCursor = s;
        }
      }
    }

    final notifications = items
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ActivityPage(notifications: notifications, nextCursor: nextCursor);
  }

  @override
  Future<ActivityPage> getNotifications({String? cursor}) async {
    // Try multiple known endpoints; stop on first success
    final query = cursor != null ? {'cursor': cursor} : null;
    // Expanded list of possible endpoints used by different Loops deployments.
    // For loops.video specifically, `/api/v1/account/notifications` is the one
    // that returns data, so we try it first.
    final endpoints = <String>[
      'api/v1/account/notifications',
      'api/v1/notifications',
      'api/v1/notifications/unread',
      'api/notifications',
      'api/v1/notifications/list',
    ];

    final List<String> tried = [];
    for (final path in endpoints) {
      tried.add(path);
      try {
        final res = await _apiClient.get(path, queryParameters: query);
        if (res.statusCode != null && res.statusCode! >= 400) {
          // If hard 404, keep trying next endpoint
          if (res.statusCode == 404) continue;
          throw Exception('Failed to load notifications (${res.statusCode})');
        }
        return _parsePage(res.data);
      } catch (_) {
        // keep trying next
        continue;
      }
    }
    throw Exception(
      'Notifications endpoint not found. Tried: ${tried.join(", ")}',
    );
  }
}
