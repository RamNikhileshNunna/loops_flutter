import 'package:flutter/material.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/widgets/video_player_widget.dart';

class FeedView extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;
  final VoidCallback? onLoadMore;

  const FeedView({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.onLoadMore,
  });

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
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
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);

        // Pre-fetch next page a couple items before the end.
        if (index >= widget.videos.length - 3) {
          widget.onLoadMore?.call();
        }
      },
      itemBuilder: (context, index) {
        return VideoPlayerWidget(
          video: widget.videos[index],
          isActive: index == _currentIndex,
        );
      },
    );
  }
}
