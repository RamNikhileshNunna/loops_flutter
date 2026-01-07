import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/explore/data/models/tag_model.dart';

abstract class ExploreRepository {
  Future<List<UserModel>> getSuggestedAccounts();
  Future<List<TagModel>> getTrendingTags();
  Future<FeedPage> getTagFeed(String tag, {String? cursor});
  Future<void> followUser(String userId);
}
