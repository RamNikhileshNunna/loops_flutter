import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/models/video_model.dart';
import '../../../feed/presentation/widgets/video_player_widget.dart';

class ExploreViewerScreen extends ConsumerStatefulWidget {
  const ExploreViewerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  final List<VideoModel> videos;
  final int initialIndex;

  @override
  ConsumerState<ExploreViewerScreen> createState() =>
      _ExploreViewerScreenState();
}

class _ExploreViewerScreenState extends ConsumerState<ExploreViewerScreen> {
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
    final videos = widget.videos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                video: videos[index],
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
      ),
    );
  }
}
