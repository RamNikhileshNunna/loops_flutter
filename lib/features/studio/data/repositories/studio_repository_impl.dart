import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_json.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_link.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_summary.dart';
import 'package:loops_flutter/features/studio/domain/repositories/studio_repository.dart';

final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  return StudioRepositoryImpl(ref.watch(apiClientProvider));
});

class StudioRepositoryImpl implements StudioRepository {
  StudioRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  Map<String, dynamic> _asMap(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};

  @override
  Future<StudioSummary> getSummary() async {
    final res = await _apiClient.get('api/v1/studio/analytics/summary');
    return StudioSummary.fromJson(_asMap(res.data));
  }

  @override
  Future<AnalyticsSeries> getAnalytics({
    required String metric,
    required int range,
  }) async {
    final res = await _apiClient.get(
      'api/v1/studio/analytics/$metric',
      queryParameters: {'range': range},
    );
    return AnalyticsSeries.fromJson(_asMap(res.data), metric);
  }

  @override
  Future<StudioPostsPage> getPosts({
    String? cursor,
    String search = '',
    int limit = 20,
    String filter = 'all',
  }) async {
    final res = await _apiClient.get(
      'api/v1/studio/posts',
      queryParameters: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
        'search': search,
        'sort_field': 'created_at',
        'sort_direction': 'desc',
        'filter': filter,
      },
    );
    return StudioPostsPage.fromJson(_asMap(res.data));
  }

  @override
  Future<ProfileLinksResult> getProfileLinks() async {
    // Two calls: the links themselves + their per-URL click counts.
    final results = await Future.wait([
      _apiClient.get('api/v1/account/settings/links'),
      _apiClient.get('api/v1/studio/analytics/links'),
    ]);

    final meta = ProfileLinksMeta.fromJson(_asMap(results[0].data));

    // url -> clicks
    final clickData = _asMap(results[1].data)['data'];
    final clickMap = <String, int>{};
    if (clickData is List) {
      for (final e in clickData.whereType<Map>()) {
        clickMap[asString(e['url'])] = asInt(e['clicks']);
      }
    }

    final totalClicks =
        meta.links.fold<int>(0, (sum, l) => sum + (clickMap[l.url] ?? 0));

    final merged = meta.links
        .map((l) {
          final clicks = clickMap[l.url] ?? 0;
          return MergedLink(
            link: l,
            clicks: clicks,
            pct: totalClicks > 0 ? clicks / totalClicks : 0,
          );
        })
        .toList()
      ..sort((a, b) => b.clicks.compareTo(a.clicks));

    return ProfileLinksResult(
      meta: meta,
      links: merged,
      totalClicks: totalClicks,
    );
  }
}
