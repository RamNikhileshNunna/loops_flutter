import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepositoryImpl(apiClient);
});

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  static const String _myVideosPath = 'api/v1/feed/account/self';
  static const String _myLikesPath = 'api/v1/account/videos/liked';

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

  @override
  Future<FeedPage> getMyVideos({String? cursor}) async {
    final response = await _apiClient.get(
      _myVideosPath,
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    return _parsePage(response.data);
  }

  @override
  Future<FeedPage> getMyLikedVideos({String? cursor}) async {
    final response = await _apiClient.get(
      _myLikesPath,
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    return _parsePage(response.data);
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final response = await _apiClient.get('api/v1/account/followers/$userId');
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
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final response = await _apiClient.get('api/v1/account/following/$userId');
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
}
