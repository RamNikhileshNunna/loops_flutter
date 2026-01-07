import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

class FeedPage {
  final List<VideoModel> videos;
  final String? nextCursor;

  const FeedPage({required this.videos, required this.nextCursor});
}
