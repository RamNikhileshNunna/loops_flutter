import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/features/explore/data/models/tag_model.dart';
import 'package:loops_flutter/features/explore/domain/repositories/explore_repository.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExploreRepositoryImpl(apiClient);
});

class ExploreRepositoryImpl implements ExploreRepository {
  final ApiClient _apiClient;

  ExploreRepositoryImpl(this._apiClient);

  @override
  Future<List<UserModel>> getSuggestedAccounts() async {
    // Confirmed endpoint: api/v1/accounts/suggested
    try {
      final response = await _apiClient.get('api/v1/accounts/suggested');
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => UserModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TagModel>> getTrendingTags() async {
    // Confirmed endpoint: api/v1/explore/tags
    try {
      final response = await _apiClient.get('api/v1/explore/tags');
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => TagModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FeedPage> getTagFeed(String tag, {String? cursor}) async {
    // Confirmed endpoint: api/v1/explore/tag-feed/{tag}
    final cleanTag = tag.replaceAll('#', '');
    try {
      final response = await _apiClient.get(
        'api/v1/explore/tag-feed/$cleanTag',
        queryParameters: cursor != null ? {'cursor': cursor} : null,
      );
      return _parsePage(response.data);
    } catch (e) {
      return const FeedPage(videos: [], nextCursor: null);
    }
  }

  @override
  Future<void> followUser(String userId) async {
    // Guessed endpoint: api/v1/account/follow/{id}
    await _apiClient.post('api/v1/account/follow/$userId');
  }

  FeedPage _parsePage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const FeedPage(videos: [], nextCursor: null);
    }

    final raw = data['data'];
    final List<dynamic> items = raw is List ? raw : const [];

    String? nextCursor;
    final meta = data['meta'];
    if (meta is Map) {
      final v = meta['next_cursor'] ?? meta['nextCursor'];
      if (v != null) {
        final s = v.toString();
        if (s.isNotEmpty && s != 'null') nextCursor = s;
      }
    }

    final videos = items
        .whereType<Map>()
        .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return FeedPage(videos: videos, nextCursor: nextCursor);
  }
}
