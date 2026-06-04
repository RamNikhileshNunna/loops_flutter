import 'package:flutter/material.dart';

import 'package:loops_flutter/features/studio/utils/studio_format.dart';

/// A single headline metric tile on the Studio dashboard (Views / Followers /
/// Likes), showing the total and its signed 7-day change.
class StudioStatCard extends StatelessWidget {
  const StudioStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.changePct,
    required this.loading,
  });

  final int value;
  final String label;
  final double changePct;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color changeColor = changePct > 0
        ? const Color(0xFF34C759)
        : changePct < 0
            ? cs.error
            : cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loading ? '—' : formatCompact(value),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                loading ? '—' : formatChangePct(changePct),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: loading ? cs.onSurface : changeColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '7d',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
