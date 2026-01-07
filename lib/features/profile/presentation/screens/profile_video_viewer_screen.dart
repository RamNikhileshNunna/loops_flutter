import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/models/video_model.dart';
import '../../../feed/presentation/widgets/video_player_widget.dart';
import '../controllers/profile_content_controllers.dart';

class ProfileVideoViewerScreen extends ConsumerStatefulWidget {
  const ProfileVideoViewerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
    required this.isMyVideos, // true for my videos, false for liked videos
  });

  final List<VideoModel> videos;
  final int initialIndex;
  final bool isMyVideos;

  @override
  ConsumerState<ProfileVideoViewerScreen> createState() =>
      _ProfileVideoViewerScreenState();
}

class _ProfileVideoViewerScreenState
    extends ConsumerState<ProfileVideoViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(
      widget.isMyVideos
          ? myVideosControllerProvider
          : myLikedVideosControllerProvider,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: videosState.when(
        data: (videos) {
          // Use videos from controller, fallback to initial videos if controller is empty
          final displayVideos = videos.isNotEmpty ? videos : widget.videos;

          if (displayVideos.isEmpty) {
            return const Center(
              child: Text(
                'No videos found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: displayVideos.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);

                  // Pre-fetch next page a couple items before the end.
                  if (index >= displayVideos.length - 3) {
                    if (widget.isMyVideos) {
                      ref.read(myVideosControllerProvider.notifier).loadMore();
                    } else {
                      ref
                          .read(myLikedVideosControllerProvider.notifier)
                          .loadMore();
                    }
                  }
                },
                itemBuilder: (context, index) {
                  if (index >= displayVideos.length) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  return VideoPlayerWidget(
                    video: displayVideos[index],
                    isActive: index == _currentIndex,
                  );
                },
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
