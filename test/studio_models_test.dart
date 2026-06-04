import 'package:flutter_test/flutter_test.dart';
import 'package:loops_flutter/features/studio/domain/models/analytics_series.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_summary.dart';

void main() {
  group('StudioSummary.fromJson', () {
    test('parses metrics, latest post, links and totals', () {
      final s = StudioSummary.fromJson({
        'range': 7,
        'views': {'total': 12345, 'change_pct': 8.2},
        'followers': {'total': 1, 'change_pct': -3},
        'likes': {'total': 0, 'change_pct': 0},
        'latest_post': {
          'id': '99',
          'hid': 'abc',
          'profile_id': '7',
          'likes': 5,
          'comments': 2,
          'media': {'thumbnail': 'https://cdn/x_thumb_100.jpg'},
        },
        'top_links': [
          {'id': '1', 'url': 'https://example.com', 'title': null, 'clicks': 10},
        ],
        'recent_posts': [
          {'id': '1', 'media': {'thumbnail': 'https://cdn/a.jpg'}, 'views': 300},
        ],
        'total_posts': 42,
      });

      expect(s.views.total, 12345);
      expect(s.views.changePct, 8.2);
      expect(s.followers.total, 1);
      expect(s.latestPost?.hid, 'abc');
      expect(s.latestPost?.thumbnailUrl, 'https://cdn/x_thumb_100.jpg');
      expect(s.topLinks.single.clicks, 10);
      expect(s.recentPosts.single.views, 300);
      expect(s.totalPosts, 42);
    });

    test('degrades gracefully on missing fields', () {
      final s = StudioSummary.fromJson({});
      expect(s.views.total, 0);
      expect(s.latestPost, isNull);
      expect(s.topLinks, isEmpty);
      expect(s.recentPosts, isEmpty);
      expect(s.totalPosts, 0);
    });
  });

  group('StudioPostsPage.fromJson', () {
    test('reads posts + cursor + total from a paginated payload', () {
      final page = StudioPostsPage.fromJson({
        'data': [
          {
            'id': 1,
            'hid': 'h1',
            'caption': 'Hello',
            'status': 'published',
            'created_at': '2026-01-01T00:00:00Z',
            'likes': '3',
            'comments': 1,
            'pinned': true,
            'media': {'thumbnail': 'https://cdn/1.jpg'},
          },
          {'id': 2, 'status': 'processing'},
        ],
        'meta': {'next_cursor': 'CURSOR2', 'total_videos': 17},
      });

      expect(page.posts.length, 2);
      expect(page.posts.first.id, '1');
      expect(page.posts.first.likes, 3); // numeric string coerced
      expect(page.posts.first.pinned, isTrue);
      expect(page.posts[1].isProcessing, isTrue);
      expect(page.nextCursor, 'CURSOR2');
      expect(page.totalVideos, 17);
    });
  });

  group('AnalyticsSeries.fromJson', () {
    test('reads the value under the active metric key', () {
      final series = AnalyticsSeries.fromJson({
        'data': [
          {'date': '2026-01-01', 'views': 10},
          {'date': '2026-01-02', 'views': 25},
        ],
        'total': 35,
      }, 'views');

      expect(series.points.length, 2);
      expect(series.points.first.date, '2026-01-01');
      expect(series.points[1].value, 25);
      expect(series.total, 35);
    });

    test('falls back to generic value/count keys', () {
      final series = AnalyticsSeries.fromJson({
        'data': [
          {'date': '2026-01-01', 'value': 4},
          {'date': '2026-01-02', 'count': 6},
        ],
        'total': 10,
      }, 'shares');

      expect(series.points.first.value, 4);
      expect(series.points[1].value, 6);
    });
  });
}
