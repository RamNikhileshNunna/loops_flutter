import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/features/studio/data/repositories/studio_repository_impl.dart';
import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_link.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_summary.dart';

/// Dashboard summary. autoDispose so it refetches each time Studio is reopened.
final studioSummaryProvider = FutureProvider.autoDispose<StudioSummary>((ref) {
  return ref.watch(studioRepositoryProvider).getSummary();
});

/// Argument for the analytics time-series query.
typedef AnalyticsArgs = ({String metric, int range});

final studioAnalyticsProvider =
    FutureProvider.autoDispose.family<AnalyticsSeries, AnalyticsArgs>((ref, args) {
  return ref
      .watch(studioRepositoryProvider)
      .getAnalytics(metric: args.metric, range: args.range);
});

/// Profile links joined with their click analytics.
final studioLinksProvider =
    FutureProvider.autoDispose<ProfileLinksResult>((ref) {
  return ref.watch(studioRepositoryProvider).getProfileLinks();
});
