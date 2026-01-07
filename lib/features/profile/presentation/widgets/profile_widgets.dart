import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/screens/profile_video_viewer_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.onFollowingTap,
    this.onFollowersTap,
  });

  final UserModel user;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 46,
          backgroundColor: Colors.grey.shade900,
          backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? const Icon(Icons.person, size: 46, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          '@${user.username}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stat(
              label: 'Following',
              value: user.followingCount,
              onTap: onFollowingTap,
            ),
            _divider(),
            _Stat(
              label: 'Followers',
              value: user.followerCount,
              onTap: onFollowersTap,
            ),
            _divider(),
            _Stat(
              label: 'Likes',
              value: user.likesCount,
            ), // Likes usually not a list
          ],
        ),
        if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 14),
    child: SizedBox(
      height: 24,
      child: VerticalDivider(width: 1, color: Colors.white24),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.onTap});

  final String label;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            _format(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String _format(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

class ProfileVideoGrid extends StatelessWidget {
  const ProfileVideoGrid({
    super.key,
    required this.videos,
    this.emptyText = 'No videos yet',
    this.isMyVideos = true,
  });

  final List<VideoModel> videos;
  final String emptyText;
  final bool isMyVideos;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }

    // loops.video API (for this clone) only provides a video URL (`media.src_url`).
    // We show a simple placeholder tile and open the video on tap later if needed.
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final v = videos[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileVideoViewerScreen(
                  videos: videos,
                  initialIndex: index,
                  isMyVideos: isMyVideos,
                ),
              ),
            );
          },
          child: _VideoTile(video: v),
        );
      },
    );
  }
}

class _VideoTile extends ConsumerWidget {
  const _VideoTile({required this.video});

  final VideoModel video;

  String? _ensureAbsolute(String? url, StorageService storage) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final instance = storage.getInstance();
    if (instance == null || instance.isEmpty) return url;

    // Normalize leading slash to avoid double slashes.
    final normalized = url.startsWith('/') ? url.substring(1) : url;
    return 'https://$instance/$normalized';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final thumbnailUrl = _ensureAbsolute(video.media.thumbnailUrl, storage);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or placeholder
          thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white70,
                      size: 32,
                    ),
                  ),
                ),
          // Gradient overlay for better text visibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // Like count
          Positioned(
            left: 6,
            bottom: 6,
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${video.likes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
