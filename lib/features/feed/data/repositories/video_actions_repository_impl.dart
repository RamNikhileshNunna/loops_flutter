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
        final data = response.data['data'];
        if (data != null) {
          return VideoModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<dynamic>> getVideoLikes(String videoId) async {
    try {
      final response = await _apiClient.get('api/v1/video/$videoId/likes');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<dynamic>> getVideoComments(String videoId) async {
    try {
      final response = await _apiClient.get('api/v1/video/$videoId/comments');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<dynamic>> getCommentReplies(
    String videoId,
    String commentId,
  ) async {
    try {
      final response = await _apiClient.get(
        'api/v1/comments/$commentId/replies',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> likeVideo(String videoId) async {
    return _postWithCsrf('api/v1/video/$videoId/like');
  }

  @override
  Future<bool> unlikeVideo(String videoId) async {
    return _postWithCsrf('api/v1/video/$videoId/unlike');
  }

  @override
  Future<bool> commentVideo(
    String videoId,
    String comment, {
    String? parentId,
  }) async {
    if (parentId != null) {
      return _postWithCsrf(
        'api/v1/comments/$parentId/reply',
        data: {'comment': comment},
      );
    }
    return _postWithCsrf(
      'api/v1/video/$videoId/comments',
      data: {'comment': comment},
    );
  }

  @override
  Future<bool> likeComment(String commentId) async {
    return _postWithCsrf('api/v1/comments/$commentId/like');
  }

  @override
  Future<bool> unlikeComment(String commentId) async {
    return _postWithCsrf('api/v1/comments/$commentId/unlike');
  }

  @override
  Future<void> deleteComment(String videoId, String commentId) async {
    try {
      await _apiClient.post('api/v1/comments/$commentId/delete');
    } catch (e) {
      // Ignore errors for delete
    }
  }
}
