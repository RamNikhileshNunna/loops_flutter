import 'package:loops_flutter/features/studio/domain/models/studio_json.dart';

/// A single day's value on the analytics chart.
class AnalyticsPoint {
  const AnalyticsPoint({required this.date, required this.value});

  /// ISO date string (`yyyy-MM-dd`) as returned by the API.
  final String date;
  final double value;
}

/// Time-series response from `studio/analytics/{metric}?range=N`.
class AnalyticsSeries {
  const AnalyticsSeries({required this.points, required this.total});

  final List<AnalyticsPoint> points;
  final double total;

  /// `metric` is the active tab key (views/likes/comments/shares/followers).
  /// Each point may carry the value under the metric key or a generic fallback,
  /// matching the official client's `d[metric] ?? d.value ?? d.count ?? …`.
  factory AnalyticsSeries.fromJson(Map<String, dynamic> json, String metric) {
    final raw = json['data'];
    final items = raw is List ? raw : const [];
    final points = items.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      final value = m[metric] ??
          m['value'] ??
          m['count'] ??
          m['views'] ??
          m['followers'] ??
          0;
      return AnalyticsPoint(date: asString(m['date']), value: asDouble(value));
    }).toList();

    return AnalyticsSeries(points: points, total: asDouble(json['total']));
  }
}
