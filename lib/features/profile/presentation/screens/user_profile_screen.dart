import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';
import 'package:loops_flutter/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.read(profileRepositoryProvider).getUserProfile(userId);
});

// Paginating video controller for a specific user
final userVideosControllerProvider =
    AsyncNotifierProviderFamily<UserVideosController, List<VideoModel>, String>(
  UserVideosController.new,
);

class UserVideosController
    extends FamilyAsyncNotifier<List<VideoModel>, String> {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  FutureOr<List<VideoModel>> build(String userId) async {
    final page = await _fetchPage();
    _setCursor(page);
    return page.videos;
  }

  Future<FeedPage> _fetchPage({String? cursor}) {
    return ref
        .read(profileRepositoryProvider)
        .getUserVideos(arg, cursor: cursor);
  }

  void _setCursor(FeedPage page) {
    _nextCursor = page.nextCursor;
    _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;
    final current = state.asData?.value ?? const [];
    _isLoadingMore = true;
    try {
      final page = await _fetchPage(cursor: _nextCursor);
      _setCursor(page);
      final seen = current.map((v) => v.id).toSet();
      state = AsyncValue.data([
        ...current,
        ...page.videos.where((v) => !seen.contains(v.id)),
      ]);
    } catch (_) {
      // keep existing items on pagination failure
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _nextCursor = null;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _fetchPage();
      _setCursor(page);
      return page.videos;
    });
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool? _isFollowing;
  bool _isToggling = false;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 400) {
      ref
          .read(userVideosControllerProvider(widget.userId).notifier)
          .loadMore();
    }
  }

  Future<void> _toggleFollow() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    final wasFollowing = _isFollowing ?? false;
    setState(() => _isFollowing = !wasFollowing);

    final repo = ref.read(profileRepositoryProvider);
    final ok = wasFollowing
        ? await repo.unfollowUser(widget.userId)
        : await repo.followUser(widget.userId);

    if (!ok && mounted) {
      setState(() => _isFollowing = wasFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Please try again.')),
      );
    }
    if (mounted) setState(() => _isToggling = false);
  }

  void _refresh() {
    ref.invalidate(_userProfileProvider(widget.userId));
    ref
        .read(userVideosControllerProvider(widget.userId).notifier)
        .refresh();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_userProfileProvider(widget.userId));
    final videosAsync = ref.watch(userVideosControllerProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: profileAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: 'Could not load profile'),
        data: (user) {
          if (user == null) return _ErrorView(message: 'User not found');

          if (_isFollowing == null && !user.isOwner) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isFollowing = false);
            });
          }

          return CustomScrollView(
            controller: _scroll,
            slivers: [
              // ── Top bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _TopBar(
                  username: user.username,
                  onRefresh: _refresh,
                ),
              ),

              // ── Profile header ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  user: user,
                  isFollowing: _isFollowing,
                  isToggling: _isToggling,
                  onFollowTap: user.isOwner ? null : _toggleFollow,
                ),
              ),

              // ── Section divider ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08)),
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_on_rounded,
                            color: Colors.white, size: 17),
                        SizedBox(width: 6),
                        Text(
                          'Videos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Video grid ────────────────────────────────────────────────
              videosAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => SliverToBoxAdapter(
                  child: _RetryVideos(onRetry: _refresh),
                ),
                data: (videos) {
                  if (videos.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _RetryVideos(onRetry: _refresh),
                    );
                  }
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => GestureDetector(
                        onTap: () => Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => FeedViewScreen(
                              videos: videos,
                              initialIndex: i,
                            ),
                          ),
                        ),
                        child: _GridTile(video: videos[i]),
                      ),
                      childCount: videos.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1.5,
                      mainAxisSpacing: 1.5,
                      childAspectRatio: 9 / 16,
                    ),
                  );
                },
              ),

              // ── Loading-more indicator ────────────────────────────────────
              if (videosAsync.hasValue &&
                  (videosAsync.asData?.value.isNotEmpty ?? false))
                const SliverToBoxAdapter(
                  child: _LoadMoreIndicator(),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.username, required this.onRefresh});
  final String username;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
            Expanded(
              child: Text(
                '@$username',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white54, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.isFollowing,
    required this.isToggling,
    required this.onFollowTap,
  });

  final UserModel user;
  final bool? isFollowing;
  final bool isToggling;
  final VoidCallback? onFollowTap;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final hasBio = user.bio != null && user.bio!.trim().isNotEmpty;
    final hasName = user.name != null && user.name!.trim().isNotEmpty;
    final following = isFollowing ?? false;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Avatar
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFF2A2A2A),
          backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? const Icon(Icons.person_rounded,
                  size: 48, color: Colors.white38)
              : null,
        ),

        const SizedBox(height: 12),

        // Username
        Text(
          '@${user.username}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Display name
        if (hasName) ...[
          const SizedBox(height: 3),
          Text(
            user.name!,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],

        // Bio
        if (hasBio) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(value: _fmt(user.postCount), label: 'Videos'),
              _StatDivider(),
              _Stat(value: _fmt(user.followerCount), label: 'Followers'),
              _StatDivider(),
              _Stat(value: _fmt(user.followingCount), label: 'Following'),
              _StatDivider(),
              _Stat(value: _fmt(user.likesCount), label: 'Likes'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Follow button
        if (onFollowTap != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: GestureDetector(
                onTap: isToggling ? null : onFollowTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: following
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: following
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.20))
                        : null,
                  ),
                  child: Center(
                    child: isToggling
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: following ? Colors.white : Colors.black,
                            ),
                          )
                        : Text(
                            following ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color: following ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Stat widgets ─────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white12);
}

// ─── Grid tile ────────────────────────────────────────────────────────────────

class _GridTile extends StatelessWidget {
  const _GridTile({required this.video});
  final VideoModel video;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final thumb = video.media.thumbnailUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        thumb != null
            ? CachedNetworkImage(
                imageUrl: thumb,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: Color(0xFF111111)),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF1A1A1A)),
              )
            : const ColoredBox(
                color: Color(0xFF1A1A1A),
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white24, size: 28),
              ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 11),
                const SizedBox(width: 3),
                Text(
                  _fmt(video.likes),
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
}

// ─── Loading more indicator ───────────────────────────────────────────────────

class _LoadMoreIndicator extends ConsumerWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a spinner only while actively loading more
    return const SizedBox(
      height: 48,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white38),
        ),
      ),
    );
  }
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _RetryVideos extends StatelessWidget {
  const _RetryVideos({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          const Icon(Icons.videocam_off_outlined,
              color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No videos found',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'This account may have no public videos',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
            color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined,
                color: Colors.white38, size: 52),
            const SizedBox(height: 12),
            Text(message,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Go back',
                  style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
