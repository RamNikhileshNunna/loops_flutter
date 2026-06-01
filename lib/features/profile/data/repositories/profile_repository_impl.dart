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
  static const String _myLikesPath = 'api/v1/account/videos/likes';

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
        .expand<VideoModel>((e) { try { return [VideoModel.fromJson(Map<String, dynamic>.from(e))]; } catch (_) { return []; } })
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

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get('api/v1/account/info/$userId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return UserModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FeedPage> getUserVideos(String userId, {String? cursor}) async {
    // The path already contains the profile ID.
    // The optional "id" query param is a numeric pagination cursor, not the user ID.
    final params = <String, dynamic>{};
    if (cursor != null) params['id'] = cursor;
    final response = await _apiClient.get(
      'api/v1/feed/account/$userId/cursor',
      queryParameters: params.isEmpty ? null : params,
    );
    return _parsePage(response.data);
  }

  @override
  Future<bool> followUser(String userId) async {
    try {
      await _apiClient.ensureCsrfCookie();
      final response = await _apiClient.post('api/v1/account/follow/$userId');
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unfollowUser(String userId) async {
    try {
      await _apiClient.ensureCsrfCookie();
      final response = await _apiClient.post('api/v1/account/unfollow/$userId');
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
