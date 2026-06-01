import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:video_player/video_player.dart';

/// True on the three desktop targets. video_player has no Linux/Windows
/// backend, so on desktop playback is delegated to media_kit (libmpv).
bool get isDesktopPlatform =>
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

/// A thin playback abstraction so the feed UI can stay identical across
/// platforms. Mobile/web use the official `video_player` plugin; desktop uses
/// `media_kit`. The widget tree only depends on this interface.
abstract class PlatformVideo {
  /// Picks the right backend for the current platform.
  factory PlatformVideo(String url, {required bool hls}) {
    if (isDesktopPlatform) return _MediaKitVideo(url);
    return _VideoPlayerVideo(url, hls: hls);
  }

  Future<void> initialize();
  void play();
  void pause();
  void setLooping(bool value);

  bool get isInitialized;
  bool get isPlaying;

  /// width / height of the decoded video (falls back to a 9:16 portrait guess).
  double get aspectRatio;
  Duration get position;
  Duration get duration;

  /// Notifies on playback ticks (position/state) so progress UI can rebuild.
  Listenable get listenable;

  /// The raw video surface, already cover-fitted to fill its parent.
  Widget buildSurface();

  void dispose();
}

// ─── Mobile / web: video_player ───────────────────────────────────────────────

class _VideoPlayerVideo implements PlatformVideo {
  _VideoPlayerVideo(this.url, {required this.hls});

  final String url;
  final bool hls;
  VideoPlayerController? _c;
  final ValueNotifier<int> _fallback = ValueNotifier<int>(0);

  @override
  Future<void> initialize() async {
    // formatHint: hls forces ExoPlayer to use HlsMediaSource for manifest URLs
    // that lack a .m3u8 extension (otherwise UnrecognizedInputFormatException).
    final c = hls
        // ignore: deprecated_member_use — networkUrl() has no formatHint param
        ? VideoPlayerController.network(url, formatHint: VideoFormat.hls)
        : VideoPlayerController.networkUrl(Uri.parse(url));
    await c.initialize();
    _c = c;
  }

  @override
  void play() {
    _c?.play();
  }

  @override
  void pause() {
    _c?.pause();
  }

  @override
  void setLooping(bool value) {
    _c?.setLooping(value);
  }

  @override
  bool get isInitialized => _c?.value.isInitialized ?? false;

  @override
  bool get isPlaying => _c?.value.isPlaying ?? false;

  @override
  double get aspectRatio {
    final s = _c?.value.size;
    if (s == null || s.width == 0 || s.height == 0) return 9 / 16;
    return s.width / s.height;
  }

  @override
  Duration get position => _c?.value.position ?? Duration.zero;

  @override
  Duration get duration => _c?.value.duration ?? Duration.zero;

  @override
  Listenable get listenable => _c ?? _fallback;

  @override
  Widget buildSurface() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    final w = c.value.size.width == 0 ? 9.0 : c.value.size.width;
    final h = c.value.size.height == 0 ? 16.0 : c.value.size.height;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: w, height: h, child: VideoPlayer(c)),
      ),
    );
  }

  @override
  void dispose() {
    _c?.dispose();
    _fallback.dispose();
  }
}

// ─── Desktop: media_kit (libmpv) ──────────────────────────────────────────────

class _MediaKitVideo extends ChangeNotifier implements PlatformVideo {
  _MediaKitVideo(this.url) {
    _player = mk.Player();
    // Force the software rendering texture path. media_kit's default H/W
    // (OpenGL) path produces a solid blue/garbled frame on many Linux
    // GPUs/drivers and virtual displays (audio plays, no picture). The
    // software path copies pixels reliably at a small CPU cost.
    _videoController = mkv.VideoController(
      _player,
      configuration: const mkv.VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );
  }

  final String url;
  late final mk.Player _player;
  late final mkv.VideoController _videoController;
  final List<StreamSubscription<dynamic>> _subs = [];

  bool _initialized = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _w = 0;
  int _h = 0;

  @override
  Future<void> initialize() async {
    _subs
      ..add(_player.stream.position.listen((p) {
        _position = p;
        notifyListeners();
      }))
      ..add(_player.stream.duration.listen((d) {
        _duration = d;
        notifyListeners();
      }))
      ..add(_player.stream.playing.listen((p) {
        _playing = p;
        notifyListeners();
      }))
      ..add(_player.stream.width.listen((w) {
        if (w != null && w > 0) {
          _w = w;
          notifyListeners();
        }
      }))
      ..add(_player.stream.height.listen((h) {
        if (h != null && h > 0) {
          _h = h;
          notifyListeners();
        }
      }));
    await _player.open(mk.Media(url), play: false);
    _initialized = true;
    notifyListeners();
  }

  @override
  void play() {
    _player.play();
  }

  @override
  void pause() {
    _player.pause();
  }

  @override
  void setLooping(bool value) {
    // PlaylistMode.single loops the current media indefinitely.
    _player.setPlaylistMode(
        value ? mk.PlaylistMode.single : mk.PlaylistMode.none);
  }

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isPlaying => _playing;

  @override
  double get aspectRatio => (_w > 0 && _h > 0) ? _w / _h : 9 / 16;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  Listenable get listenable => this;

  @override
  Widget buildSurface() => mkv.Video(
        controller: _videoController,
        controls: mkv.NoVideoControls,
        fit: BoxFit.cover,
        fill: Colors.black,
      );

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
