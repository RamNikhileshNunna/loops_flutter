import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';
import 'package:loops_flutter/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

final _userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.read(profileRepositoryProvider).getUserProfile(userId);
});

final _userVideosProvider =
    FutureProvider.family<List<VideoModel>, String>((ref, userId) async {
  final page = await ref.read(profileRepositoryProvider).getUserVideos(userId);
  return page.videos;
});

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool? _isFollowing;
  bool _isTogglingFollow = false;

  Future<void> _toggleFollow() async {
    if (_isTogglingFollow) return;
    setState(() => _isTogglingFollow = true);

    final repo = ref.read(profileRepositoryProvider);
    final wasFollowing = _isFollowing ?? false;

    setState(() => _isFollowing = !wasFollowing);

    final success = wasFollowing
        ? await repo.unfollowUser(widget.userId)
        : await repo.followUser(widget.userId);

    if (!success && mounted) {
      setState(() => _isFollowing = wasFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Please try again.')),
      );
    }

    if (mounted) setState(() => _isTogglingFollow = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_userProfileProvider(widget.userId));
    final videosAsync = ref.watch(_userVideosProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: profileAsync.maybeWhen(
          data: (user) => Text(
            user != null ? '@${user.username}' : 'Profile',
            style: const TextStyle(color: Colors.white),
          ),
          orElse: () => const Text('Profile', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                'User not found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          if (_isFollowing == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isFollowing = user.isOwner ? null : false);
              }
            });
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ProfileHeader(user: user)),
              if (!user.isOwner)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: _isTogglingFollow ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isFollowing ?? false)
                            ? Colors.transparent
                            : Colors.white,
                        foregroundColor: (_isFollowing ?? false)
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isTogglingFollow
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text((_isFollowing ?? false) ? 'Unfollow' : 'Follow'),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Videos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              videosAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error loading videos',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                data: (videos) {
                  if (videos.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No videos yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final v = videos[index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FeedViewScreen(
                                  videos: videos,
                                  initialIndex: index,
                                ),
                              ),
                            ),
                            child: _VideoTile(video: v),
                          );
                        },
                        childCount: videos.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 9 / 16,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final UserModel user;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

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
        if (user.name != null && user.name!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.name!,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stat(label: 'Videos', value: _fmt(user.postCount)),
            _vdiv(),
            _Stat(label: 'Followers', value: _fmt(user.followerCount)),
            _vdiv(),
            _Stat(label: 'Likes', value: _fmt(user.likesCount)),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _vdiv() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 14),
    child: SizedBox(
      height: 24,
      child: VerticalDivider(width: 1, color: Colors.white24),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video});
  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.media.thumbnailUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[900]),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey[900]),
                )
              : Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white30,
                    size: 28,
                  ),
                ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 12, color: Colors.white70),
                const SizedBox(width: 2),
                Text(
                  '${video.likes}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
