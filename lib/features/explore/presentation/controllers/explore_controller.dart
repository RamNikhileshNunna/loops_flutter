import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:loops_flutter/features/explore/data/models/tag_model.dart';
import 'package:loops_flutter/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

part 'explore_controller.g.dart';

@riverpod
Future<List<UserModel>> suggestedAccounts(Ref ref) {
  return ref.watch(exploreRepositoryProvider).getSuggestedAccounts();
}

@riverpod
Future<List<TagModel>> trendingTags(Ref ref) {
  return ref.watch(exploreRepositoryProvider).getTrendingTags();
}

@riverpod
class TagFeedController extends _$TagFeedController {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  FutureOr<List<VideoModel>> build(String tag) async {
    final page = await _fetchPage(tag: tag);
    _setCursor(page);
    return page.videos;
  }

  Future<FeedPage> _fetchPage({required String tag, String? cursor}) async {
    final repository = ref.read(exploreRepositoryProvider);
    return repository.getTagFeed(tag, cursor: cursor);
  }

  void _setCursor(FeedPage page) {
    _nextCursor = page.nextCursor;
    _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final current = state.asData?.value ?? const <VideoModel>[];
    final cursor = _nextCursor;
    if (cursor == null || cursor.isEmpty) {
      _hasMore = false;
      return;
    }

    _isLoadingMore = true;
    try {
      final page = await _fetchPage(tag: tag, cursor: cursor);
      _setCursor(page);

      final existingIds = current.map((e) => e.id).toSet();
      final merged = <VideoModel>[
        ...current,
        ...page.videos.where((v) => !existingIds.contains(v.id)),
      ];

      state = AsyncValue.data(merged);
    } catch (e) {
      // Handle error silent
    } finally {
      _isLoadingMore = false;
    }
  }
}
