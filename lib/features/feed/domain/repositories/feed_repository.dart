import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';

abstract class FeedRepository {
  Future<FeedPage> getForYouFeed({String? cursor});
  Future<FeedPage> getFollowingFeed({String? cursor});
}
