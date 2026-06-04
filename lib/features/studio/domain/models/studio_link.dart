import 'package:loops_flutter/features/studio/domain/models/studio_json.dart';

/// A profile link as returned by `account/settings/links`.
class ProfileLink {
  const ProfileLink({
    required this.id,
    required this.url,
    required this.urlPretty,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String urlPretty;
  final DateTime? createdAt;

  factory ProfileLink.fromJson(Map<String, dynamic> json) {
    final url = asString(json['url']);
    return ProfileLink(
      id: asString(json['id']),
      url: url,
      urlPretty: asString(json['url_pretty'], url),
      createdAt: asDate(json['created_at']),
    );
  }
}

/// The links payload wrapper: slot accounting + the links themselves.
class ProfileLinksMeta {
  const ProfileLinksMeta({
    required this.minThreshold,
    required this.totalAllowed,
    required this.availableSlots,
    required this.canAdd,
    required this.links,
  });

  final int minThreshold;
  final int totalAllowed;
  final int availableSlots;
  final bool canAdd;
  final List<ProfileLink> links;

  factory ProfileLinksMeta.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : json;
    final rawLinks = map['links'];
    return ProfileLinksMeta(
      minThreshold: asInt(map['min_threshold']),
      totalAllowed: asInt(map['total_allowed']),
      availableSlots: asInt(map['available_slots']),
      canAdd: asBool(map['can_add']),
      links: rawLinks is List
          ? rawLinks
              .whereType<Map>()
              .map((e) => ProfileLink.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// A profile link joined with its click count + share of total clicks.
class MergedLink {
  const MergedLink({required this.link, required this.clicks, required this.pct});

  final ProfileLink link;
  final int clicks;
  final double pct;
}

/// The full, view-ready links result for the Links screen.
class ProfileLinksResult {
  const ProfileLinksResult({
    required this.meta,
    required this.links,
    required this.totalClicks,
  });

  final ProfileLinksMeta meta;
  final List<MergedLink> links;
  final int totalClicks;

  /// Links are locked behind a follower threshold when adding is disabled but
  /// slots would otherwise be available (mirrors the official client's logic).
  bool get isThresholdLocked =>
      !meta.canAdd && (meta.totalAllowed == 0 || meta.availableSlots > 0);
}
