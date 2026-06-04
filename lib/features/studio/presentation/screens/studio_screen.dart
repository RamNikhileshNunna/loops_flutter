import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_summary.dart';
import 'package:loops_flutter/features/studio/presentation/controllers/studio_controllers.dart';
import 'package:loops_flutter/features/studio/presentation/screens/studio_analytics_screen.dart';
import 'package:loops_flutter/features/studio/presentation/screens/studio_links_screen.dart';
import 'package:loops_flutter/features/studio/presentation/screens/studio_posts_screen.dart';
import 'package:loops_flutter/features/studio/presentation/widgets/studio_stat_card.dart';
import 'package:loops_flutter/features/studio/utils/studio_format.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studioSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Loops Studio')),
      body: async.when(
        loading: () => AppLoading.centered(),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(studioSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(studioSummaryProvider),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  _AnalyticsSection(summary: summary, onTap: () => _push(context, const StudioAnalyticsScreen())),
                  const SizedBox(height: 20),
                  _LinksSection(summary: summary, onTap: () => _push(context, const StudioLinksScreen())),
                  const SizedBox(height: 20),
                  _PostsSection(summary: summary, onTap: () => _push(context, const StudioPostsScreen())),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap, this.showViewAll = true});
  final String title;
  final VoidCallback onTap;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            if (showViewAll)
              Row(
                children: [
                  Text('View all',
                      style:
                          TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: cs.onSurfaceVariant),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Analytics ─────────────────────────────────────────────────────────────────

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.summary, required this.onTap});
  final StudioSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final followers = summary.followers.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Analytics', onTap: onTap),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: StudioStatCard(
                    value: summary.views.total,
                    label: 'Post views',
                    changePct: summary.views.changePct,
                    loading: false)),
            const SizedBox(width: 8),
            Expanded(
                child: StudioStatCard(
                    value: followers,
                    label: followers == 1 ? 'Net follower' : 'Net followers',
                    changePct: summary.followers.changePct,
                    loading: false)),
            const SizedBox(width: 8),
            Expanded(
                child: StudioStatCard(
                    value: summary.likes.total,
                    label: 'Likes',
                    changePct: summary.likes.changePct,
                    loading: false)),
          ],
        ),
        if (summary.latestPost != null) ...[
          const SizedBox(height: 12),
          _LatestPost(post: summary.latestPost!),
        ],
      ],
    );
  }
}

class _LatestPost extends StatelessWidget {
  const _LatestPost({required this.post});
  final StudioPost post;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text('Your latest post',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const Spacer(),
          Icon(Icons.favorite_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text('${post.likes}',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(width: 14),
          Icon(Icons.mode_comment_outlined,
              size: 15, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text('${post.comments}',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─── Profile links ───────────────────────────────────────────────────────────

class _LinksSection extends StatelessWidget {
  const _LinksSection({required this.summary, required this.onTap});
  final StudioSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final links = summary.topLinks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Profile Links', onTap: onTap),
        const SizedBox(height: 8),
        if (links.isEmpty)
          _EmptyTile(
            icon: Icons.link_outlined,
            title: 'Add links to your profile',
            subtitle: 'Promote your work, socials, or shop',
            onTap: onTap,
          )
        else
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < links.length; i++) ...[
                  if (i > 0)
                    Divider(
                        height: 1,
                        indent: 60,
                        color: cs.outlineVariant.withValues(alpha: 0.4)),
                  InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.link_rounded,
                              size: 18, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (links[i].title != null &&
                                      links[i].title!.isNotEmpty &&
                                      links[i].title != links[i].url)
                                  ? links[i].title!
                                  : hostnameOf(links[i].url),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface),
                            ),
                          ),
                          Text('${formatCompact(links[i].clicks)} clicks',
                              style: TextStyle(
                                  fontSize: 13, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Posts ───────────────────────────────────────────────────────────────────

class _PostsSection extends StatelessWidget {
  const _PostsSection({required this.summary, required this.onTap});
  final StudioSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final posts = summary.recentPosts;
    final title = summary.totalPosts > 0
        ? 'Posts (${formatCompact(summary.totalPosts)})'
        : 'Posts';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            title: title, onTap: onTap, showViewAll: summary.totalPosts > 0),
        const SizedBox(height: 8),
        if (posts.isEmpty)
          _EmptyTile(
            icon: Icons.videocam_outlined,
            title: 'Share your first post',
            subtitle: 'Your videos will show up here',
            onTap: onTap,
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _PostThumb(post: posts[i], onTap: onTap),
            ),
          ),
      ],
    );
  }
}

class _PostThumb extends StatelessWidget {
  const _PostThumb({required this.post, required this.onTap});
  final StudioPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 96,
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (post.thumbnailUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: post.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: cs.surfaceContainerHighest),
                  errorWidget: (_, _, _) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.videocam,
                          color: cs.onSurfaceVariant, size: 20)),
                )
              else
                Container(
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.videocam,
                        color: cs.onSurfaceVariant, size: 20)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text('${formatCompact(post.views)} views',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared bits ───────────────────────────────────────────────────────────────

class _EmptyTile extends StatelessWidget {
  const _EmptyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Could not load Studio',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
