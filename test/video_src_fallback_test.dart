import 'package:flutter_test/flutter_test.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

void main() {
  group('MediaModel src_url resolution', () {
    test('uses src_url when present (home feed shape)', () {
      final m = MediaModel.fromJson({
        'src_url':
            'https://loopsusercontent.com/videos/79/288/ABCDEF.720p.mp4',
        'hls_url': null,
        'thumbnail':
            'https://loopsusercontent.com/videos/79/288/ABCDEF_thumb_xy.jpg',
      });
      expect(m.srcUrl, endsWith('ABCDEF.720p.mp4'));
    });

    test('prefers hls_url over src_url', () {
      final m = MediaModel.fromJson({
        'hls_url': 'https://example.com/stream.m3u8',
        'src_url': 'https://example.com/file.mp4',
      });
      expect(m.srcUrl, 'https://example.com/stream.m3u8');
    });

    test('derives mp4 from thumbnail when no playback url (tag-feed shape)',
        () {
      // Real shape returned by api/v1/explore/tag-feed/{tag}: media carries
      // only dimensions + a thumbnail, no src_url/hls_url.
      final m = MediaModel.fromJson({
        'duration': 7,
        'width': 720,
        'height': 1280,
        'thumbnail':
            'https://loopsusercontent.com/videos/219304269097685897/251614262408127468/jSuHQOLE1sbskbU6mOB8M3SbC0gTmyXAL5upvBSl.jpg',
      });
      expect(
        m.srcUrl,
        'https://loopsusercontent.com/videos/219304269097685897/251614262408127468/jSuHQOLE1sbskbU6mOB8M3SbC0gTmyXAL5upvBSl.720p.mp4',
      );
    });

    test('strips _thumb_ suffix when deriving from thumbnail', () {
      final m = MediaModel.fromJson({
        'thumbnail':
            'https://cdn.test/videos/1/2/HASH_thumb_Ay8oo30I.jpg',
      });
      expect(m.srcUrl, 'https://cdn.test/videos/1/2/HASH.720p.mp4');
    });

    test('empty when neither url nor thumbnail present', () {
      final m = MediaModel.fromJson({'duration': 5});
      expect(m.srcUrl, '');
    });
  });
}
