import 'package:flutter/material.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/widgets/feed_view.dart';

class FeedViewScreen extends StatelessWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const FeedViewScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FeedView(videos: videos, initialIndex: initialIndex),
    );
  }
}
