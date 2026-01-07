import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/models/notification_model.dart';

part 'activity_controller.g.dart';

@riverpod
class ActivityController extends _$ActivityController {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  FutureOr<List<NotificationModel>> build() async {
    final page = await _fetchPage();
    _setCursor(page);
    return page.notifications;
  }

  Future<ActivityPage> _fetchPage({String? cursor}) async {
    final repository = ref.read(activityRepositoryProvider);
    return repository.getNotifications(cursor: cursor);
  }

  void _setCursor(ActivityPage page) {
    _nextCursor = page.nextCursor;
    _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final current = state.asData?.value ?? const <NotificationModel>[];
    final cursor = _nextCursor;
    if (cursor == null || cursor.isEmpty) {
      _hasMore = false;
      return;
    }

    _isLoadingMore = true;
    try {
      final page = await _fetchPage(cursor: cursor);
      _setCursor(page);

      final existingIds = current.map((e) => e.id).toSet();
      final merged = <NotificationModel>[
        ...current,
        ...page.notifications.where((n) => !existingIds.contains(n.id)),
      ];

      state = AsyncValue.data(merged);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Notifications loadMore failed: $e');
        debugPrintStack(stackTrace: st);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _fetchPage();
      _setCursor(page);
      return page.notifications;
    });
  }
}
