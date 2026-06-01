import 'package:flutter/material.dart';
import '../../domain/models/video_model.dart';
import 'video_player_widget.dart';

class FeedView extends StatefulWidget {
  const FeedView({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.onLoadMore,
  });

  final List<VideoModel> videos;
  final int initialIndex;
  final VoidCallback? onLoadMore;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the video list is replaced (tab switch / refresh), jump back to top.
    if (!identical(oldWidget.videos, widget.videos) &&
        widget.videos.isNotEmpty) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
    }
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
        if (index >= widget.videos.length - 3) {
          widget.onLoadMore?.call();
        }
      },
      itemBuilder: (context, index) => VideoPlayerWidget(
        video: widget.videos[index],
        isActive: index == _currentIndex,
      ),
    );
  }
}
