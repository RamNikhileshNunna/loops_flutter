import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_content_controllers.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../screens/relationship_screen.dart';
import '../screens/profile_video_viewer_screen.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserControllerProvider);

    return userState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  const Text('Not signed in',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          );
        }
        return _ProfileBody(user: user);
      },
    );
  }
}

// ─── Main body with NestedScrollView ─────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            _ProfileSliverHeader(user: user),
            SliverPersistentHeader(delegate: _StickyTabBar(), pinned: true),
          ],
          body: const TabBarView(
            children: [
              _VideosTab(),
              _LikesTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sliver header ────────────────────────────────────────────────────────────

class _ProfileSliverHeader extends ConsumerWidget {
  const _ProfileSliverHeader({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: _ProfileHeaderContent(user: user, ref: ref),
    );
  }
}

class _ProfileHeaderContent extends StatelessWidget {
  const _ProfileHeaderContent({required this.user, required this.ref});
  final UserModel user;
  final WidgetRef ref;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name?.isNotEmpty == true
                        ? user.name!
                        : '@${user.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(currentUserControllerProvider.notifier).refresh();
                    ref.read(myVideosControllerProvider.notifier).refresh();
                    ref.read(myLikedVideosControllerProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // ── Avatar + stats row ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade900,
                    backgroundImage:
                        user.avatar != null && user.avatar!.isNotEmpty
                            ? CachedNetworkImageProvider(user.avatar!)
                            : null,
                    child: user.avatar == null || user.avatar!.isEmpty
                        ? const Icon(Icons.person,
                            size: 44, color: Colors.white54)
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                      value: _fmt(user.postCount),
                      label: 'Videos',
                    ),
                    _Stat(
                      value: _fmt(user.followingCount),
                      label: 'Following',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RelationshipScreen(
                              userId: user.id, initialTabIndex: 0),
                        ),
                      ),
                    ),
                    _Stat(
                      value: _fmt(user.followerCount),
                      label: 'Followers',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RelationshipScreen(
                              userId: user.id, initialTabIndex: 1),
                        ),
                      ),
                    ),
                    _Stat(
                      value: _fmt(user.likesCount),
                      label: 'Likes',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Name + bio ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${user.username}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.bio!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Action buttons ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _OutlineBtn(
                  label: 'Edit Profile',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _OutlineBtn(
                label: '',
                icon: Icons.share_outlined,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'https://loops.video/@${user.username}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile link copied')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

// ─── Sticky tab bar ───────────────────────────────────────────────────────────

class _StickyTabBar extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_on_rounded, size: 18),
                SizedBox(width: 6),
                Text('Videos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 18),
                SizedBox(width: 6),
                Text('Liked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
}

// ─── Tabs ─────────────────────────────────────────────────────────────────────

class _VideosTab extends ConsumerWidget {
  const _VideosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myVideosControllerProvider);
    return state.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => _TabError(message: 'Could not load videos'),
      data: (videos) => videos.isEmpty
          ? _TabEmpty(
              icon: Icons.videocam_off_outlined,
              message: 'No videos yet',
              sub: 'Upload your first video',
            )
          : _VideoGrid(videos: videos, isMyVideos: true),
    );
  }
}

class _LikesTab extends ConsumerWidget {
  const _LikesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLikedVideosControllerProvider);
    return state.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => _TabError(message: 'Could not load liked videos'),
      data: (videos) => videos.isEmpty
          ? _TabEmpty(
              icon: Icons.favorite_border_rounded,
              message: 'No liked videos',
              sub: 'Videos you like will appear here',
            )
          : _VideoGrid(videos: videos, isMyVideos: false),
    );
  }
}

// ─── Video grid ───────────────────────────────────────────────────────────────

class _VideoGrid extends ConsumerWidget {
  const _VideoGrid({required this.videos, required this.isMyVideos});
  final List<VideoModel> videos;
  final bool isMyVideos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final v = videos[index];
        final thumb = _abs(v.media.thumbnailUrl, storage);
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileVideoViewerScreen(
                videos: videos,
                initialIndex: index,
                isMyVideos: isMyVideos,
              ),
            ),
          ),
          child: _GridTile(thumbnailUrl: thumb, likes: v.likes),
        );
      },
    );
  }

  String? _abs(String? url, StorageService s) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    final inst = s.getInstance();
    if (inst == null) return url;
    return 'https://$inst/${url.startsWith('/') ? url.substring(1) : url}';
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.thumbnailUrl, required this.likes});
  final String? thumbnailUrl;
  final int likes;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF111111)),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
        // Bottom gradient + like count
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 11),
                const SizedBox(width: 3),
                Text(
                  _fmt(likes),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1A1A1A),
        child:
            const Icon(Icons.play_arrow_rounded, color: Colors.white24, size: 28),
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (icon != null && label.isNotEmpty) const SizedBox(width: 6),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabEmpty extends StatelessWidget {
  const _TabEmpty(
      {required this.icon, required this.message, required this.sub});
  final IconData icon;
  final String message;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 56),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

class _TabError extends StatelessWidget {
  const _TabError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.white38)),
    );
  }
}
