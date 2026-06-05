import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';

/// Full-screen grid of every video for a single hashtag.
///
/// Pushed when a trending tag is tapped (e.g. from the desktop sidebar). Backed
/// by the shared [tagFeedControllerProvider] family so it reuses the same
/// cursor-paginated tag feed the Explore tab uses (the API returns 10 per page
/// via `meta.next_cursor`). Tapping a tile opens the immersive [FeedViewScreen]
/// starting on that video.
///
/// Pagination here needs more than a scroll listener: this screen is *only* the
/// grid, so the first page of 10 often doesn't fill a wide desktop window — and
/// a non-scrollable list can never fire a scroll callback. So we both (a) listen
/// for scrolls near the bottom and (b) proactively fetch further pages until the
/// content overflows the viewport (or the feed runs out).
class TagFeedScreen extends ConsumerStatefulWidget {
  const TagFeedScreen({super.key, required this.tag});

  /// The hashtag name without the leading '#'.
  final String tag;

  @override
  ConsumerState<TagFeedScreen> createState() => _TagFeedScreenState();
}

class _TagFeedScreenState extends ConsumerState<TagFeedScreen> {
  final ScrollController _scroll = ScrollController();

  /// Guards against overlapping `loadMore` calls (scroll + viewport-fill can
  /// both fire) so we never request the same page twice.
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Near the bottom → pull the next page.
  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 600) {
      _maybeLoadMore();
    }
  }

  /// Fetch one more page if possible, then keep filling while the grid still
  /// isn't tall enough to scroll. Stops when the controller reports no more
  /// pages or a fetch adds nothing (e.g. a transient error), so it can't loop.
  Future<void> _maybeLoadMore() async {
    if (_fetching) return;
    final notifier = ref.read(tagFeedControllerProvider(widget.tag).notifier);
    if (!notifier.hasMore) return;

    final before = _count;
    setState(() => _fetching = true);
    await notifier.loadMore();
    if (!mounted) return;
    setState(() => _fetching = false);

    // Only continue auto-filling if this fetch actually made progress.
    if (_count > before) _fillViewportIfNeeded();
  }

  int get _count =>
      ref.read(tagFeedControllerProvider(widget.tag)).asData?.value.length ?? 0;

  /// After a frame, if the content still doesn't overflow the viewport, fetch
  /// another page. Scheduled post-frame so the just-added items are laid out
  /// before we measure `maxScrollExtent`.
  void _fillViewportIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (_scroll.position.maxScrollExtent <= 0) {
        _maybeLoadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tagFeedControllerProvider(widget.tag));

    return Scaffold(
      appBar: AppBar(title: Text('#${widget.tag}')),
      body: state.when(
        loading: () => AppLoading.centered(),
        error: (e, _) => Center(
          child: Text('Could not load #${widget.tag}',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Text('No videos for #${widget.tag}',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            );
          }

          // The first page may not fill a wide window — kick off proactive
          // paging so the user can keep scrolling.
          _fillViewportIfNeeded();

          final notifier =
              ref.read(tagFeedControllerProvider(widget.tag).notifier);
          final showFooter = _fetching || notifier.hasMore;

          return CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(1.5),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                    childAspectRatio: 9 / 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final v = videos[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FeedViewScreen(
                                videos: videos, initialIndex: index),
                          ),
                        ),
                        child: _GridTile(video: v, cs: cs),
                      );
                    },
                    childCount: videos.length,
                  ),
                ),
              ),
              // Footer: spinner while a page is loading, otherwise an "end"
              // marker once everything has been fetched.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: showFooter
                        ? const AppLoading(size: 22)
                        : Text("You've reached the end",
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A single video thumbnail with a like-count overlay. The white overlay text
/// is intentional — it sits on top of arbitrary video frames.
class _GridTile extends StatelessWidget {
  const _GridTile({required this.video, required this.cs});
  final VideoModel video;
  final ColorScheme cs;

  static String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final thumb = video.media.thumbnailUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        thumb != null
            ? CachedNetworkImage(
                imageUrl: thumb,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                placeholder: (_, _) =>
                    ColoredBox(color: cs.surfaceContainerHigh),
                errorWidget: (_, _, _) =>
                    ColoredBox(color: cs.surfaceContainerHighest),
              )
            : ColoredBox(
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.play_arrow_rounded,
                    color: cs.onSurfaceVariant, size: 28),
              ),
        // Bottom gradient + like count.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 11),
                const SizedBox(width: 3),
                Text(
                  _fmt(video.likes),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
