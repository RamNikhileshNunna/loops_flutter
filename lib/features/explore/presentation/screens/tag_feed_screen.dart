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
/// cursor-paginated tag feed the Explore tab uses. Tapping a tile opens the
/// immersive [FeedViewScreen] starting on that video.
class TagFeedScreen extends ConsumerStatefulWidget {
  const TagFeedScreen({super.key, required this.tag});

  /// The hashtag name without the leading '#'.
  final String tag;

  @override
  ConsumerState<TagFeedScreen> createState() => _TagFeedScreenState();
}

class _TagFeedScreenState extends ConsumerState<TagFeedScreen> {
  final ScrollController _scroll = ScrollController();

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

  /// Near the bottom → ask the controller for the next page.
  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(tagFeedControllerProvider(widget.tag).notifier).loadMore();
    }
  }

  static String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
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
          return GridView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(1.5),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 9 / 16,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final v = videos[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FeedViewScreen(videos: videos, initialIndex: index),
                  ),
                ),
                child: _GridTile(video: v, cs: cs),
              );
            },
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
                  _TagFeedScreenState._fmt(video.likes),
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
