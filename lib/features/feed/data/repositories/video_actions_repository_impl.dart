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
      final response = await _apiClient.get('api/v1/video/likes/$videoId');
      if (response.statusCode == 200 && response.data != null) {
        // Return raw data or map to models. Let's return the 'data' field usually
        // If data is list, return it.
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
      final response = await _apiClient.get('api/v1/video/comments/$videoId');
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
      // API: /v1/video/comments/{id}/replies?cr={commentId}
      // Assuming {id} is videoId based on likely REST structure for sub-resources
      final response = await _apiClient.get(
        'api/v1/video/comments/$videoId/replies',
        queryParameters: {'cr': commentId},
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
    return _postWithCsrf('api/v1/video/like/$videoId');
  }

  @override
  Future<bool> unlikeVideo(String videoId) async {
    // Assuming unlike follows similar pattern or like is toggle.
    // If explicit unlike exists:
    return _postWithCsrf('api/v1/video/unlike/$videoId');
  }

  @override
  Future<bool> commentVideo(
    String videoId,
    String comment, {
    String? parentId,
  }) async {
    final Map<String, dynamic> data = {'comment': comment};
    if (parentId != null) {
      final intParentId = int.tryParse(parentId);
      if (intParentId != null && intParentId != 0) {
        data['parent_id'] = intParentId;
      }
    }
    // POST /v1/video/comments/{vid}
    return _postWithCsrf('api/v1/video/comments/$videoId', data: data);
  }

  @override
  Future<bool> likeComment(String commentId) async {
    return _postWithCsrf('api/v1/video/comments/like/$commentId');
  }

  @override
  Future<bool> unlikeComment(String commentId) async {
    return _postWithCsrf('api/v1/video/comments/unlike/$commentId');
  }

  @override
  Future<void> deleteComment(String videoId, String commentId) async {
    try {
      await _apiClient.post('api/v1/video/comments/delete/$commentId');
    } catch (e) {
      // Ignore errors for delete
    }
  }
}
