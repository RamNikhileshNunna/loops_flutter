import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

abstract class ProfileRepository {
  Future<FeedPage> getMyVideos({String? cursor});
  Future<FeedPage> getMyLikedVideos({String? cursor});
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);
  Future<UserModel?> getUserProfile(String userId);
  Future<FeedPage> getUserVideos(String userId, {String? cursor});
  Future<bool> followUser(String userId);
  Future<bool> unfollowUser(String userId);
}
