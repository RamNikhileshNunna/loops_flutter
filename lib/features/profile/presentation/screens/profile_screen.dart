import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_content_controllers.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../studio/presentation/screens/studio_screen.dart';
import '../screens/relationship_screen.dart';
import '../screens/profile_video_viewer_screen.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final userState = ref.watch(currentUserControllerProvider);

    return userState.when(
      loading: () => Scaffold(
        backgroundColor: cs.surface,
        body: AppLoading.centered(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: Text('Error: $e', style: TextStyle(color: cs.onSurface)),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      color: cs.onSurfaceVariant, size: 64),
                  const SizedBox(height: 16),
                  Text('Not signed in',
                      style: TextStyle(color: cs.onSurface, fontSize: 18)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/login'),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
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
    final cs = Theme.of(context).colorScheme;
    final hasName = user.name != null && user.name!.trim().isNotEmpty;
    final hasBio = user.bio != null && user.bio!.trim().isNotEmpty;

    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasName ? user.name! : user.username,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
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
                  icon: Icon(Icons.refresh_rounded,
                      color: cs.onSurfaceVariant, size: 22),
                ),
                IconButton(
                  tooltip: 'Loops Studio',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StudioScreen()),
                  ),
                  icon: Icon(Icons.insights_rounded,
                      color: cs.onSurface, size: 22),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: Icon(Icons.settings_outlined,
                      color: cs.onSurface, size: 22),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Avatar (centered) ─────────────────────────────────────────────
        CircleAvatar(
          radius: 48,
          backgroundColor: cs.surfaceContainerHighest,
          backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: user.avatar == null || user.avatar!.isEmpty
              ? Icon(Icons.person_rounded,
                  size: 48, color: cs.onSurfaceVariant)
              : null,
        ),

        const SizedBox(height: 12),

        // ── Username ──────────────────────────────────────────────────────
        Text(
          '@${user.username}',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ── Bio ───────────────────────────────────────────────────────────
        if (hasBio) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // ── Stats row ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(value: _fmt(user.postCount), label: 'Videos'),
              _StatDivider(),
              _Stat(
                value: _fmt(user.followingCount),
                label: 'Following',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      RelationshipScreen(userId: user.id, initialTabIndex: 0),
                )),
              ),
              _StatDivider(),
              _Stat(
                value: _fmt(user.followerCount),
                label: 'Followers',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      RelationshipScreen(userId: user.id, initialTabIndex: 1),
                )),
              ),
              _StatDivider(),
              _Stat(value: _fmt(user.likesCount), label: 'Likes'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Action buttons ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  filled: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.ios_share_rounded,
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: 'https://loops.video/@${user.username}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile link copied')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),
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
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant),
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: TabBar(
        labelColor: cs.onSurface,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
        indicatorColor: cs.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_on_rounded, size: 17),
                SizedBox(width: 6),
                Text('Videos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 17),
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
          AppLoading.centered(),
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
          AppLoading.centered(),
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
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
    final cs = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                // Decode at grid-tile resolution, not full source — a 3-col
                // grid never needs more than ~400px wide, saving lots of RAM.
                memCacheWidth: 400,
                placeholder: (_, _) =>
                    Container(color: cs.surfaceContainerHigh),
                errorWidget: (_, _, _) => _placeholder(context),
              )
            : _placeholder(context),
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

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.play_arrow_rounded,
          color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 28),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.label,
    required this.icon,
    this.filled = false,
    required this.onTap,
  });
  final String? label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasLabel = label != null && label!.isNotEmpty;
    final fg = filled ? cs.onPrimary : cs.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(
          horizontal: hasLabel ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: filled ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: fg,
              size: 16,
            ),
            if (hasLabel) ...[
              const SizedBox(width: 7),
              Text(
                label!,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 56),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
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
      child: Text(message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
