import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/video_model.dart';
import '../../domain/repositories/video_actions_repository.dart';

final videoActionsRepositoryProvider = Provider<VideoActionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoActionsRepositoryImpl(apiClient);
});

class VideoActionsRepositoryImpl implements VideoActionsRepository {
  final ApiClient _apiClient;

  VideoActionsRepositoryImpl(this._apiClient);

  Future<bool> _postWithCsrf(String path, {dynamic data}) async {
    try {
      await _apiClient.ensureCsrfCookie();
      final response = await _apiClient.post(path, data: data);
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<VideoModel?> getVideo(String videoId) async {
    try {
      final response = await _apiClient.get('api/v1/video/$videoId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return VideoModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // GET /api/v1/video/showVideoLikes  (video id passed as query param)
  @override
  Future<List<dynamic>> getVideoLikes(String videoId) async {
    try {
      final response = await _apiClient.get(
        'api/v1/video/showVideoLikes',
        queryParameters: {'id': videoId},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // GET /api/v1/video/comments/{vid}
  @override
  Future<List<dynamic>> getVideoComments(String videoId) async {
    try {
      final response =
          await _apiClient.get('api/v1/video/comments/$videoId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // GET /api/v1/video/comments/reply/{vid}/{pid}
  @override
  Future<List<dynamic>> getCommentReplies(
      String videoId, String commentId) async {
    try {
      final response = await _apiClient.get(
        'api/v1/video/comments/reply/$videoId/$commentId',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // POST /api/v1/video/like/{vid}
  @override
  Future<bool> likeVideo(String videoId) =>
      _postWithCsrf('api/v1/video/like/$videoId');

  // POST /api/v1/video/unlike/{vid}
  @override
  Future<bool> unlikeVideo(String videoId) =>
      _postWithCsrf('api/v1/video/unlike/$videoId');

  // POST /api/v1/video/comments/{vid}  or  POST /api/v1/video/comments/reply/{vid}
  @override
  Future<bool> commentVideo(
    String videoId,
    String comment, {
    String? parentId,
  }) async {
    if (parentId != null) {
      return _postWithCsrf(
        'api/v1/video/comments/reply/$videoId',
        data: {'comment': comment, 'parent_id': parentId},
      );
    }
    return _postWithCsrf(
      'api/v1/video/comments/$videoId',
      data: {'comment': comment},
    );
  }

  // POST /api/v1/comments/like/{vid}/{id}
  @override
  Future<bool> likeComment(String videoId, String commentId) =>
      _postWithCsrf('api/v1/comments/like/$videoId/$commentId');

  // POST /api/v1/comments/unlike/{vid}/{id}
  @override
  Future<bool> unlikeComment(String videoId, String commentId) =>
      _postWithCsrf('api/v1/comments/unlike/$videoId/$commentId');

  // POST /api/v1/comments/delete/{vid}/{id}
  @override
  Future<void> deleteComment(String videoId, String commentId) async {
    try {
      await _apiClient.ensureCsrfCookie();
      await _apiClient.post('api/v1/comments/delete/$videoId/$commentId');
    } catch (_) {}
  }
}
