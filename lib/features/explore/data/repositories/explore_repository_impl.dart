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
    await _apiClient.post('api/v1/account/follow/$userId');
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await _apiClient.post('api/v1/account/unfollow/$userId');
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _apiClient.post(
        'api/v1/search/users',
        data: {'q': query},
      );
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
  Future<FeedPage> searchVideos(String query, {String? cursor}) async {
    try {
      final params = <String, dynamic>{'query': query};
      if (cursor != null) params['cursor'] = cursor;
      final response = await _apiClient.get(
        'api/v1/search/videos',
        queryParameters: params,
      );
      return _parsePage(response.data);
    } catch (e) {
      return const FeedPage(videos: [], nextCursor: null);
    }
  }

  @override
  Future<List<TagModel>> searchHashtags(String query) async {
    // Confirmed endpoint (from the official Loops app): autocomplete tags.
    final clean = query.replaceAll('#', '').trim();
    if (clean.isEmpty) return [];
    try {
      final response = await _apiClient.get(
        'api/v1/autocomplete/tags',
        queryParameters: {'q': clean},
      );
      // The payload may be a bare list or wrapped in {data: [...]}; each item
      // may be a {name,count,...} object or a plain tag string.
      final body = response.data;
      final raw = body is Map ? body['data'] : body;
      if (raw is! List) return [];
      return raw
          .map<TagModel?>((e) {
            if (e is Map) {
              return TagModel.fromJson(Map<String, dynamic>.from(e));
            }
            if (e is String) return TagModel(name: e);
            return null;
          })
          .whereType<TagModel>()
          .where((t) => t.name.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  FeedPage _parsePage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const FeedPage(videos: [], nextCursor: null);
    }

    final raw = data['data'];
    final List<dynamic> items = raw is List ? raw : const [];

    final nextCursor = extractNextCursor(data);

    final videos = items
        .whereType<Map>()
        .expand<VideoModel>((e) { try { return [VideoModel.fromJson(Map<String, dynamic>.from(e))]; } catch (_) { return []; } })
        .toList();

    return FeedPage(videos: videos, nextCursor: nextCursor);
  }
}
