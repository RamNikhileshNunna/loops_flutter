import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/presentation/controllers/studio_controllers.dart';
import 'package:loops_flutter/features/studio/presentation/widgets/studio_metric_chart.dart';
import 'package:loops_flutter/features/studio/presentation/widgets/studio_pills.dart';
import 'package:loops_flutter/features/studio/utils/studio_format.dart';

class StudioAnalyticsScreen extends ConsumerStatefulWidget {
  const StudioAnalyticsScreen({super.key});

  @override
  ConsumerState<StudioAnalyticsScreen> createState() =>
      _StudioAnalyticsScreenState();
}

class _StudioAnalyticsScreenState extends ConsumerState<StudioAnalyticsScreen> {
  static const _metrics = <StudioPillItem<String>>[
    StudioPillItem(
        value: 'views',
        label: 'Video views',
        icon: Icons.play_arrow_outlined,
        activeIcon: Icons.play_arrow),
    StudioPillItem(
        value: 'likes',
        label: 'Likes',
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite),
    StudioPillItem(
        value: 'comments',
        label: 'Comments',
        icon: Icons.mode_comment_outlined,
        activeIcon: Icons.mode_comment),
    StudioPillItem(
        value: 'shares',
        label: 'Shares',
        icon: Icons.ios_share_outlined,
        activeIcon: Icons.ios_share),
    StudioPillItem(
        value: 'followers',
        label: 'Followers',
        icon: Icons.person_add_alt,
        activeIcon: Icons.person_add_alt_1),
  ];

  static const _ranges = <StudioPillItem<int>>[
    StudioPillItem(value: 7, label: '7d'),
    StudioPillItem(value: 30, label: '30d'),
    StudioPillItem(value: 60, label: '60d'),
  ];

  String _metric = 'views';
  int _range = 30;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async =
        ref.watch(studioAnalyticsProvider((metric: _metric, range: _range)));
    final metricLabel =
        _metrics.firstWhere((m) => m.value == _metric).label;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        children: [
          StudioPillBar<String>(
            items: _metrics,
            selected: _metric,
            onSelected: (m) => setState(() => _metric = m),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StudioSegmented<int>(
                items: _ranges,
                selected: _range,
                onSelected: (r) => setState(() => _range = r),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: async.when(
              loading: () => const SizedBox(
                  height: 360, child: AppLoading(size: 32)),
              error: (e, _) => _error(cs),
              data: (series) => _content(cs, series, metricLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(ColorScheme cs, AnalyticsSeries series, String metricLabel) {
    final hasData = series.points.isNotEmpty;
    final headline = formatCompact(series.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metricLabel.toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                headline,
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                hasData ? 'Last ${series.points.length} days' : '',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: hasData
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: StudioMetricChart(points: series.points),
                )
              : _empty(cs),
        ),
        if (hasData) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Daily breakdown',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
          ),
          ...series.points.reversed.take(14).map(
                (p) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4))),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatLongDate(p.date),
                          style: TextStyle(
                              fontSize: 14, color: cs.onSurfaceVariant)),
                      Text(p.value.round().toString(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface)),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _empty(ColorScheme cs) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined, size: 32, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('No data yet for this range.',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );

  Widget _error(ColorScheme cs) => SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 32, color: cs.onSurfaceVariant),
              const SizedBox(height: 8),
              Text('Could not load analytics.',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(studioAnalyticsProvider(
                    (metric: _metric, range: _range))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}
