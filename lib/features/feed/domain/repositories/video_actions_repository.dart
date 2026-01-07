import '../models/video_model.dart';

abstract class VideoActionsRepository {
  Future<VideoModel?> getVideo(String videoId);
  Future<List<dynamic>> getVideoLikes(String videoId);
  Future<List<dynamic>> getVideoComments(
    String videoId,
  ); // Using dynamic for now, should be CommentModel
  Future<List<dynamic>> getCommentReplies(String videoId, String commentId);
  Future<bool> likeVideo(String videoId);
  Future<bool> unlikeVideo(String videoId);
  Future<bool> commentVideo(String videoId, String comment, {String? parentId});
  Future<bool> likeComment(String commentId);
  Future<bool> unlikeComment(String commentId);
  Future<void> deleteComment(String videoId, String commentId);
}
