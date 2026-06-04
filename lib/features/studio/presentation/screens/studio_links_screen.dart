import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_link.dart';
import 'package:loops_flutter/features/studio/presentation/controllers/studio_controllers.dart';
import 'package:loops_flutter/features/studio/utils/studio_format.dart';

class StudioLinksScreen extends ConsumerWidget {
  const StudioLinksScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    final ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(studioLinksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Links')),
      body: async.when(
        loading: () => AppLoading.centered(),
        error: (e, _) => _Message(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load links",
          subtitle: 'Pull down to try again, or check your connection.',
          onRetry: () => ref.invalidate(studioLinksProvider),
        ),
        data: (result) {
          if (result.links.isEmpty) {
            return _Message(
              icon: result.isThresholdLocked
                  ? Icons.lock_outline
                  : Icons.link_rounded,
              title: result.isThresholdLocked
                  ? 'Profile links are locked'
                  : 'No profile links yet',
              subtitle: result.isThresholdLocked
                  ? "You'll be able to add profile links and track their clicks once you reach ${result.meta.minThreshold} followers."
                  : 'Add up to ${result.meta.totalAllowed == 0 ? 5 : result.meta.totalAllowed} links to your profile and track how often each one gets clicked.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(studioLinksProvider),
            child: ListView(
              children: [
                _Header(result: result, cs: cs),
                ...result.links.map((m) => _LinkRow(
                      merged: m,
                      cs: cs,
                      onTap: () => _open(context, m.link.url),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: Text(
                      _footerLabel(result),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _footerLabel(ProfileLinksResult r) {
    if (r.meta.canAdd) {
      final n = r.meta.availableSlots;
      return '$n ${n == 1 ? 'slot' : 'slots'} available';
    }
    if (r.isThresholdLocked) {
      return 'Reach ${r.meta.minThreshold} followers to add more links';
    }
    return 'All slots used';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.result, required this.cs});
  final ProfileLinksResult result;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL CLICKS',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(formatCompact(result.totalClicks),
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
            ],
          ),
          Text(
            '${result.links.length} of ${result.meta.totalAllowed} slots used',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow(
      {required this.merged, required this.cs, required this.onTap});
  final MergedLink merged;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.link_rounded, size: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(merged.link.urlPretty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${formatCompact(merged.clicks)} ${merged.clicks == 1 ? 'click' : 'clicks'}',
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      Text('  ·  ',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant)),
                      Text('Added ${formatAddedRelative(merged.link.createdAt)}',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: merged.clicks > 0
                          ? merged.pct.clamp(0.04, 1.0)
                          : 0,
                      minHeight: 4,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest, shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
