import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loops_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';

class ExploreGrid extends ConsumerWidget {
  final String tag;

  const ExploreGrid({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tag.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final feedState = ref.watch(tagFeedControllerProvider(tag));

    return feedState.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No videos found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childCount: videos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          FeedViewScreen(videos: videos, initialIndex: index),
                    ),
                  );
                },
                child: _ExploreGridItem(video: videos[index]),
              );
            },
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _ExploreGridItem extends StatelessWidget {
  final VideoModel video;
  const _ExploreGridItem({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.media.thumbnailUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio:
                9 / 16, // Assuming mostly portrait, or random for testing
            child: Container(
              color: Colors.grey[900],
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : const Icon(Icons.video_library, color: Colors.white24),
            ),
          ),
          // Caption or stats overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${video.likes}', // Just using likes as a metric
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
