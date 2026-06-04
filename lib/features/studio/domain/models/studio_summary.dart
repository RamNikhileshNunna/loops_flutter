import 'package:loops_flutter/features/studio/domain/models/studio_json.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';

/// A headline metric with its 7-day change percentage.
class Metric {
  const Metric({required this.total, required this.changePct});

  final int total;
  final double changePct;

  factory Metric.fromJson(dynamic json) {
    if (json is! Map) return const Metric(total: 0, changePct: 0);
    return Metric(
      total: asInt(json['total']),
      changePct: asDouble(json['change_pct']),
    );
  }
}

/// A profile link with its click count, as embedded in the summary's
/// `top_links` (a lighter shape than the full Links-screen payload).
class SummaryLink {
  const SummaryLink({
    required this.id,
    required this.url,
    required this.title,
    required this.clicks,
  });

  final String id;
  final String url;
  final String? title;
  final int clicks;

  factory SummaryLink.fromJson(Map<String, dynamic> json) {
    final Object? title = json['title'];
    return SummaryLink(
      id: asString(json['id']),
      url: asString(json['url']),
      title: title?.toString(),
      clicks: asInt(json['clicks']),
    );
  }
}

/// The Studio dashboard summary (`studio/analytics/summary`).
class StudioSummary {
  const StudioSummary({
    required this.range,
    required this.views,
    required this.followers,
    required this.likes,
    required this.latestPost,
    required this.topLinks,
    required this.recentPosts,
    required this.totalPosts,
  });

  final int range;
  final Metric views;
  final Metric followers;
  final Metric likes;
  final StudioPost? latestPost;
  final List<SummaryLink> topLinks;
  final List<StudioPost> recentPosts;
  final int totalPosts;

  factory StudioSummary.fromJson(Map<String, dynamic> json) {
    List<StudioPost> posts(dynamic v) => v is List
        ? v
            .whereType<Map>()
            .map((e) => StudioPost.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const [];

    final latest = json['latest_post'];
    final links = json['top_links'];

    return StudioSummary(
      range: asInt(json['range'], 7),
      views: Metric.fromJson(json['views']),
      followers: Metric.fromJson(json['followers']),
      likes: Metric.fromJson(json['likes']),
      latestPost: latest is Map
          ? StudioPost.fromJson(Map<String, dynamic>.from(latest))
          : null,
      topLinks: links is List
          ? links
              .whereType<Map>()
              .map((e) => SummaryLink.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      recentPosts: posts(json['recent_posts']),
      totalPosts: asInt(json['total_posts']),
    );
  }
}
