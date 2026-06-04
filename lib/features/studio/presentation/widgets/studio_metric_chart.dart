import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/utils/studio_format.dart';

/// The analytics line chart: a curved brand-coloured line with a soft gradient
/// fill, compact y-axis labels, sparse date labels, and a touch tooltip.
class StudioMetricChart extends StatelessWidget {
  const StudioMetricChart({super.key, required this.points});

  final List<AnalyticsPoint> points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];

    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    // A little headroom so the peak isn't flush with the top edge.
    final top = maxY <= 0 ? 1.0 : maxY * 1.2;

    // Show ~5 date labels across the range.
    final labelEvery = (points.length / 5).ceil().clamp(1, points.length);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: top,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: cs.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: top / 4,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  formatCompact(value),
                  style:
                      TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.round();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                if (i % labelEvery != 0 && i != points.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    formatShortDate(points[i].date),
                    style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => cs.inverseSurface,
            getTooltipItems: (touched) => [
              for (final t in touched)
                LineTooltipItem(
                  '${formatLongDate(points[t.x.round().clamp(0, points.length - 1)].date)}\n',
                  TextStyle(
                    color: cs.onInverseSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: formatCompact(t.y),
                      style: TextStyle(
                        color: cs.onInverseSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
