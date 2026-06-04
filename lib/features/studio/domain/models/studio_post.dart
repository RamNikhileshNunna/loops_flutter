import 'package:loops_flutter/features/studio/domain/models/studio_json.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart'
    show extractNextCursor;

/// A single video as surfaced inside Loops Studio.
///
/// The same shape is returned (with slightly different fields populated) by the
/// summary endpoint's `latest_post`/`recent_posts` and by the paginated
/// `studio/posts` list, so this one model tolerantly reads whichever keys are
/// present.
class StudioPost {
  const StudioPost({
    required this.id,
    required this.hid,
    required this.profileId,
    required this.caption,
    required this.status,
    required this.thumbnailUrl,
    required this.likes,
    required this.views,
    required this.comments,
    required this.shares,
    required this.bookmarks,
    required this.pinned,
    required this.createdAt,
  });

  final String id;
  final String hid;
  final String profileId;
  final String caption;

  /// 'published' | 'processing' (defaults to 'published' when absent).
  final String status;
  final String thumbnailUrl;

  final int likes;
  final int views;
  final int comments;
  final int shares;
  final int bookmarks;
  final bool pinned;
  final DateTime? createdAt;

  bool get isProcessing => status == 'processing';

  factory StudioPost.fromJson(Map<String, dynamic> json) {
    final media = json['media'];
    final thumb = media is Map ? asString(media['thumbnail']) : '';
    return StudioPost(
      id: asString(json['id']),
      hid: asString(json['hid'], asString(json['id'])),
      profileId: asString(json['profile_id']),
      caption: asString(json['caption']),
      status: asString(json['status'], 'published'),
      thumbnailUrl: thumb,
      likes: asInt(json['likes']),
      views: asInt(json['views']),
      comments: asInt(json['comments']),
      shares: asInt(json['shares']),
      bookmarks: asInt(json['bookmarks']),
      pinned: asBool(json['pinned']),
      createdAt: asDate(json['created_at']),
    );
  }
}

/// One page of the paginated `studio/posts` list.
class StudioPostsPage {
  const StudioPostsPage({
    required this.posts,
    required this.nextCursor,
    required this.totalVideos,
  });

  final List<StudioPost> posts;
  final String? nextCursor;
  final int totalVideos;

  factory StudioPostsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final items = raw is List ? raw : const [];
    final meta = json['meta'];
    return StudioPostsPage(
      posts: items
          .whereType<Map>()
          .map((e) => StudioPost.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      nextCursor: extractNextCursor(json),
      totalVideos: meta is Map ? asInt(meta['total_videos']) : items.length,
    );
  }
}
