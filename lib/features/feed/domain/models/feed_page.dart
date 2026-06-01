import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

class FeedPage {
  final List<VideoModel> videos;
  final String? nextCursor;

  const FeedPage({required this.videos, required this.nextCursor});
}

/// Extracts the "next page" cursor from a Laravel-style paginated response.
///
/// Tries, in order:
///   1. `meta.next_cursor` / `meta.nextCursor`
///   2. The `id` or `cursor` query parameter embedded in `links.next`
///
/// Loops endpoints are inconsistent: the for-you/self feeds populate
/// `meta.next_cursor`, while `/feed/account/{id}/cursor` only fills the
/// `links.next` URL. Reading both keeps pagination working everywhere.
String? extractNextCursor(Map<String, dynamic> data) {
  // 1. meta.next_cursor
  final meta = data['meta'];
  if (meta is Map) {
    final v = meta['next_cursor'] ?? meta['nextCursor'];
    if (v != null) {
      final s = v.toString();
      if (s.isNotEmpty && s != 'null') return s;
    }
  }

  // 2. links.next → ?id= / ?cursor=
  final links = data['links'];
  if (links is Map) {
    final next = links['next']?.toString();
    if (next != null && next.isNotEmpty && next != 'null') {
      final uri = Uri.tryParse(next);
      final q = uri?.queryParameters;
      final c = q?['id'] ?? q?['cursor'];
      if (c != null && c.isNotEmpty) return c;
    }
  }

  return null;
}
