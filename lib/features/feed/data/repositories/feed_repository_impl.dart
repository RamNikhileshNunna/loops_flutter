import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/feed_page.dart';
import '../../domain/models/video_model.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedRepositoryImpl(apiClient);
});

class FeedRepositoryImpl implements FeedRepository {
  final ApiClient _apiClient;

  FeedRepositoryImpl(this._apiClient);

  FeedPage _parsePage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const FeedPage(videos: [], nextCursor: null);
    }

    final raw = data['data'];
    final List<dynamic> items = raw is List ? raw : const [];

    final nextCursor = extractNextCursor(data);

    final videos = items
        .whereType<Map>()
        .expand<VideoModel>((e) { try { return [VideoModel.fromJson(Map<String, dynamic>.from(e))]; } catch (_) { return []; } })
        .toList();

    return FeedPage(videos: videos, nextCursor: nextCursor);
  }

  @override
  Future<FeedPage> getForYouFeed({String? cursor}) async {
    final response = await _apiClient.get(
      'api/v1/feed/for-you',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    return _parsePage(response.data);
  }

  @override
  Future<FeedPage> getFollowingFeed({String? cursor}) async {
    final response = await _apiClient.get(
      'api/v1/feed/following',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    return _parsePage(response.data);
  }
}
