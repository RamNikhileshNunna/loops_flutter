import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_link.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_summary.dart';

/// Read-only access to the Loops Studio (creator dashboard) endpoints.
abstract class StudioRepository {
  /// `studio/analytics/summary` — dashboard headline metrics + recents.
  Future<StudioSummary> getSummary();

  /// `studio/analytics/{metric}?range=N` — daily time series for one metric.
  Future<AnalyticsSeries> getAnalytics({required String metric, required int range});

  /// `studio/posts` — cursor-paginated list of the creator's videos.
  Future<StudioPostsPage> getPosts({
    String? cursor,
    String search = '',
    int limit = 20,
    String filter = 'all',
  });

  /// Profile links merged with their click analytics.
  Future<ProfileLinksResult> getProfileLinks();
}
