import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../domain/models/video_model.dart';
import '../../data/repositories/video_actions_repository_impl.dart';
import 'likes_sheet.dart';
import 'comments_sheet.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.hasLiked;
    _likeCount = widget.video.likes;
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize if video changed
    if (oldWidget.video.id != widget.video.id) {
      _controller?.dispose();
      _initialized = false;
      _errorMessage = null;
      _initializeController();
    }
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller?.play();
        _controller?.setLooping(true);
      } else {
        _controller?.pause();
      }
    }
  }

  String _ensureAbsoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final storage = ref.read(storageServiceProvider);
    final instance = storage.getInstance();

    if (instance != null && instance.isNotEmpty) {
      final normalized = url.startsWith('/') ? url.substring(1) : url;
      return 'https://$instance/$normalized';
    }

    return url;
  }

  Future<void> _initializeController() async {
    String videoUrl = _ensureAbsoluteUrl(widget.video.media.srcUrl);

    // If URL is empty or just the base URL, try to fetch full video details
    if (videoUrl.isEmpty || videoUrl == 'https://loops.video/') {
      debugPrint(
        'Video URL missing, fetching full video details for ${widget.video.id}...',
      );
      try {
        final repo = ref.read(videoActionsRepositoryProvider);
        final fullVideo = await repo.getVideo(widget.video.id);
        if (fullVideo != null && fullVideo.media.srcUrl.isNotEmpty) {
          videoUrl = _ensureAbsoluteUrl(fullVideo.media.srcUrl);
          debugPrint('Fetched full video URL: $videoUrl');
        } else {
          debugPrint('Failed to fetch full video URL or URL is still empty');
        }
      } catch (e) {
        debugPrint('Error fetching full video details: $e');
      }
    }

    debugPrint('Initializing video player with URL: $videoUrl');

    try {
      final uri = Uri.parse(videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _initialized = true;
          _errorMessage = null;
        });
        if (widget.isActive) {
          unawaited(_controller!.play());
          unawaited(_controller!.setLooping(true));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing video: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Video URL: $videoUrl');
      if (mounted) {
        setState(() {
          _initialized = false;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final success = _isLiked
          ? await repo.likeVideo(widget.video.id)
          : await repo.unlikeVideo(widget.video.id);

      if (!success && mounted) {
        // Revert on failure
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? -1 : 1;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update like')));
      }
    } catch (e) {
      if (mounted) {
        // Revert on error
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? -1 : 1;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  void _showLikesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LikesSheet(videoId: widget.video.id),
    );
  }

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(videoId: widget.video.id),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Layer
        Container(
          color: Colors.black,
          child: _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white70,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _initialized = false;
                          });
                          _controller?.dispose();
                          _initializeController();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _initialized && _controller != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),

        // Overlay Layer
        Positioned(
          bottom: 20,
          left: 16,
          right: 80, // Space for right actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '@${widget.video.account.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.video.caption != null)
                Text(
                  widget.video.caption!,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Right Actions (Like, Comment, etc.)
        Positioned(
          bottom: 40,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LikeButton(
                isLiked: _isLiked,
                likeCount: _likeCount,
                isLoading: _isLiking,
                onTap: _handleLike,
                onLongPress: () => _showLikesSheet(context),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${widget.video.comments}',
                onTap: () => _showCommentsSheet(context),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share,
                label: '${widget.video.shares}',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.isLoading,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: isLoading ? null : onTap,
          onLongPress: onLongPress, // Long press to see who liked
          icon: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 30,
                ),
        ),
        GestureDetector(
          onTap: onLongPress, // Tap on count to see who liked
          child: Text(
            '$likeCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 30),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
