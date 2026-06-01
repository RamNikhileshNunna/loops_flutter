import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../data/repositories/video_actions_repository_impl.dart';
import '../../domain/models/video_model.dart';
import 'comments_sheet.dart';
import 'likes_sheet.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  final VideoModel video;
  final bool isActive;

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage;

  // Like state
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  // Play/pause UI
  bool _showPlayIcon = false;
  Timer? _iconTimer;

  // Double-tap like animation
  late final AnimationController _heartAnim;
  bool _showHeartBurst = false;

  // Route awareness — pause when another screen is pushed on top
  bool _routeIsActive = true;
  // App-lifecycle awareness — pause when the app is backgrounded
  bool _appIsResumed = true;

  bool get _shouldPlay =>
      widget.isActive && _routeIsActive && _appIsResumed && _initialized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLiked = widget.video.hasLiked;
    _likeCount = widget.video.likes;
    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _appIsResumed) return;
    _appIsResumed = resumed;
    // Pause playback (and audio) whenever the app leaves the foreground.
    _shouldPlay ? _play() : _pause();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // isCurrent is false when another route is pushed on top of this one.
    final routeActive = ModalRoute.of(context)?.isCurrent ?? true;
    if (_routeIsActive == routeActive) return;
    _routeIsActive = routeActive;
    _shouldPlay ? _play() : _pause();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
      _controller?.dispose();
      _controller = null;
      _initialized = false;
      _errorMessage = null;
      _initVideo();
    }
    if (widget.isActive != oldWidget.isActive) {
      _shouldPlay ? _play() : _pause();
    }
  }

  String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final instance = ref.read(storageServiceProvider).getInstance();
    if (instance != null && instance.isNotEmpty) {
      final path = url.startsWith('/') ? url.substring(1) : url;
      return 'https://$instance/$path';
    }
    return url;
  }

  static bool _isHlsUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.m3u8') ||
        lower.contains('/hls/') ||
        lower.contains('manifest') ||
        lower.contains('playlist');
  }

  Future<void> _initVideo() async {
    String url = _absoluteUrl(widget.video.media.srcUrl);

    if (url.isEmpty) {
      try {
        final full =
            await ref.read(videoActionsRepositoryProvider).getVideo(widget.video.id);
        if (full != null && full.media.srcUrl.isNotEmpty) {
          url = _absoluteUrl(full.media.srcUrl);
        }
      } catch (_) {}
    }

    if (url.isEmpty) {
      if (mounted) setState(() => _errorMessage = 'No video URL');
      return;
    }

    try {
      // Use formatHint: hls when the URL looks like an HLS stream so ExoPlayer
      // always picks HlsMediaSource instead of ProgressiveMediaPeriod.
      // Without this hint, ExoPlayer falls back to progressive for URLs that
      // don't have a .m3u8 extension even though the content IS an HLS manifest,
      // causing UnrecognizedInputFormatException (dataType=1 = DATA_TYPE_MANIFEST).
      final ctrl = _isHlsUrl(url)
          // ignore: deprecated_member_use — networkUrl has no formatHint
          ? VideoPlayerController.network(url, formatHint: VideoFormat.hls)
          : VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      _controller = ctrl;
      setState(() {
        _initialized = true;
        _errorMessage = null;
      });
      if (_shouldPlay) _play();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to load video');
    }
  }

  void _play() {
    _controller?.play();
    _controller?.setLooping(true);
  }

  void _pause() => _controller?.pause();

  void _onTap() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _pause();
      _showIcon(Icons.pause_rounded);
    } else {
      _play();
      _showIcon(Icons.play_arrow_rounded);
    }
  }

  void _showIcon(IconData icon) {
    _iconTimer?.cancel();
    setState(() => _showPlayIcon = true);
    _iconTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showPlayIcon = false);
    });
  }

  void _onDoubleTap() {
    if (!_isLiked) _handleLike();
    setState(() => _showHeartBurst = true);
    _heartAnim.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeartBurst = false);
    });
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    // Snapshot state BEFORE optimistic update so we can restore exactly.
    final wasLiked = _isLiked;
    final countBefore = _likeCount;

    setState(() {
      _isLiking = true;
      _isLiked = !wasLiked;
      _likeCount = countBefore + (wasLiked ? -1 : 1);
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      // wasLiked == true means user is un-liking; false means liking.
      final ok = wasLiked
          ? await repo.unlikeVideo(widget.video.id)
          : await repo.likeVideo(widget.video.id);

      if (!ok && mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = countBefore;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = countBefore;
        });
      }
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  void _shareVideo() {
    final instance =
        ref.read(storageServiceProvider).getInstance() ?? 'loops.video';
    Clipboard.setData(ClipboardData(text: 'https://$instance/v/${widget.video.id}'));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _iconTimer?.cancel();
    _heartAnim.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Video / placeholder ──────────────────────────────────────
          // RepaintBoundary isolates the video texture so overlay state
          // changes (like, heart burst, play icon, progress) never repaint it.
          RepaintBoundary(child: _buildVideoLayer()),

          // ── 2. Bottom gradient ──────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Tap play/pause icon ──────────────────────────────────────
          if (_showPlayIcon)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller?.value.isPlaying ?? false
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
            ),

          // ── 4. Double-tap heart burst ───────────────────────────────────
          if (_showHeartBurst)
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _heartAnim,
                  curve: Curves.elasticOut,
                ).drive(Tween(begin: 0.0, end: 1.4)),
                child: FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _heartAnim,
                      curve: const Interval(0.5, 1.0),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ),

          // ── 5. Bottom-left: avatar + username + caption + tags ──────────
          Positioned(
            left: 16,
            right: 88,
            bottom: 24 + bottomPad,
            child: _buildInfoOverlay(),
          ),

          // ── 6. Right column: avatar + actions ───────────────────────────
          Positioned(
            right: 12,
            bottom: 24 + bottomPad,
            child: _buildActionColumn(),
          ),

          // ── 7. Video progress bar ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad,
            child: _buildProgressBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _initialized = false;
                });
                _controller?.dispose();
                _controller = null;
                _initVideo();
              },
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (!_initialized || _controller == null) {
      // Show thumbnail while loading
      final thumb = widget.video.media.thumbnailUrl;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (thumb != null)
            CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: Colors.black),
              errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
            )
          else
            const ColoredBox(color: Colors.black),
          const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ],
      );
    }

    // Full-screen cover video
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    final account = widget.video.account;
    final caption = widget.video.caption;
    final tags = widget.video.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: account.id),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _shadow(
                Text(
                  '@${account.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (caption != null && caption.isNotEmpty) ...[
          const SizedBox(height: 6),
          _shadow(
            Text(
              caption,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        if (tags.isNotEmpty) ...[
          const SizedBox(height: 6),
          _shadow(
            Text(
              tags.map((t) => '#$t').join('  '),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionColumn() {
    final account = widget.video.account;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: account.id),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: account.avatar != null
                    ? CachedNetworkImageProvider(account.avatar!)
                    : null,
                child: account.avatar == null
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF2D55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Like
        _ActionBtn(
          icon: _isLiking
              ? null
              : Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? const Color(0xFFFF2D55) : Colors.white,
                  size: 32,
                ),
          loading: _isLiking,
          label: _formatCount(_likeCount),
          onTap: _handleLike,
          onLongPress: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LikesSheet(videoId: widget.video.id),
          ),
        ),

        const SizedBox(height: 20),

        // Comment
        _ActionBtn(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
          label: _formatCount(widget.video.comments),
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CommentsSheet(videoId: widget.video.id),
          ),
        ),

        const SizedBox(height: 20),

        // Share
        _ActionBtn(
          icon: const Icon(Icons.reply, color: Colors.white, size: 30),
          label: _formatCount(widget.video.shares),
          onTap: _shareVideo,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    if (!_initialized || _controller == null) return const SizedBox.shrink();
    // The progress bar ticks many times per second; RepaintBoundary keeps
    // those repaints from invalidating the rest of the overlay.
    return RepaintBoundary(
      child: ValueListenableBuilder(
        valueListenable: _controller!,
        builder: (_, VideoPlayerValue v, __) {
          final total = v.duration.inMilliseconds;
          final pos = v.position.inMilliseconds;
          final progress = total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
          return LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          );
        },
      ),
    );
  }

  static Widget _shadow(Widget child) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        // Text shadow is handled per-widget, we just wrap
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 1)),
          ],
        ),
        child: child,
      ),
    );
  }

  static String _formatCount(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

// ─── Small action button ────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.loading = false,
  });

  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Center(child: icon),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
