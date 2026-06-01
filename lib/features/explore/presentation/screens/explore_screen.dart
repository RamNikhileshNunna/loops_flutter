import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/explore_controller.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/explore_repository_impl.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:loops_flutter/features/search/presentation/screens/search_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedTag;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      if (_selectedTag != null) {
        ref
            .read(tagFeedControllerProvider(_selectedTag!).notifier)
            .loadMore();
      }
    }
  }

  void _refresh() {
    ref.invalidate(suggestedAccountsProvider);
    ref.invalidate(trendingTagsProvider);
    if (_selectedTag != null) {
      ref.invalidate(tagFeedControllerProvider(_selectedTag!));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-select first tag
    ref.listen(trendingTagsProvider, (_, next) {
      if (_selectedTag == null && next.hasValue && next.value!.isNotEmpty) {
        setState(() => _selectedTag = next.value!.first.name);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0xFF1A1A1A),
          onRefresh: () async => _refresh(),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              // ── Search bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SearchBar(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SearchScreen()),
                  ),
                ),
              ),

              // ── Suggested accounts ──────────────────────────────────────
              SliverToBoxAdapter(
                child: _SuggestedSection(),
              ),

              // ── Trending tags ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: _TagsSection(
                  selectedTag: _selectedTag,
                  onTagSelected: (t) => setState(() => _selectedTag = t),
                ),
              ),

              // ── Divider ─────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
              ),

              // ── Video grid ──────────────────────────────────────────────
              if (_selectedTag != null)
                _TagFeedGrid(tag: _selectedTag!)
              else
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
            const SizedBox(width: 10),
            Text(
              'Search videos, people…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Suggested accounts ───────────────────────────────────────────────────────

class _SuggestedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(suggestedAccountsProvider);

    return state.when(
      loading: () => const SizedBox(height: 90, child: _SuggestedSkeleton()),
      error: (_, __) => const SizedBox.shrink(),
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Suggested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (_, i) => _SuggestedAccount(user: users[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _SuggestedAccount extends ConsumerWidget {
  const _SuggestedAccount({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: user.id)),
      ),
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade900,
                  backgroundImage: user.avatar != null
                      ? CachedNetworkImageProvider(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? const Icon(Icons.person,
                          color: Colors.white54, size: 28)
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () async {
                      await ref
                          .read(exploreRepositoryProvider)
                          .followUser(user.id);
                      ref.invalidate(suggestedAccountsProvider);
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2D55),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.add, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              user.username,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedSkeleton extends StatelessWidget {
  const _SuggestedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(width: 20),
      itemBuilder: (_, __) => Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tags section ─────────────────────────────────────────────────────────────

class _TagsSection extends ConsumerWidget {
  const _TagsSection(
      {required this.selectedTag, required this.onTagSelected});
  final String? selectedTag;
  final void Function(String) onTagSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trendingTagsProvider);

    return state.when(
      loading: () => const SizedBox(height: 40, child: _TagSkeleton()),
      error: (_, __) => const SizedBox.shrink(),
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Trending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _TagChip(
                  tag: tags[i],
                  selected: selectedTag == tags[i].name,
                  onTap: () => onTagSelected(tags[i].name),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(
      {required this.tag, required this.selected, required this.onTap});
  final TagModel tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(17),
          border: selected ? null : Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          '#${tag.name}',
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TagSkeleton extends StatelessWidget {
  const _TagSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => Container(
        width: 70 + (i % 3) * 14.0,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(17),
        ),
      ),
    );
  }
}

// ─── Tag feed grid ─────────────────────────────────────────────────────────────

class _TagFeedGrid extends ConsumerWidget {
  const _TagFeedGrid({required this.tag});
  final String tag;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tagFeedControllerProvider(tag));

    return state.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.white54)),
          ),
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No videos for #$tag',
                  style: const TextStyle(color: Colors.white38),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final v = videos[index];
                return GestureDetector(
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FeedViewScreen(videos: videos, initialIndex: index),
                    ),
                  ),
                  child: _GridTile(video: v, fmt: _fmt),
                );
              },
              childCount: videos.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 9 / 16,
            ),
          ),
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.video, required this.fmt});
  final VideoModel video;
  final String Function(int) fmt;

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
                    Container(color: const Color(0xFF111111)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A)),
              )
            : Container(
                color: const Color(0xFF1A1A1A),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white12, size: 32),
              ),
        // Gradient + like count
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
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
            child: Row(
              children: [
                const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Text(
                  fmt(video.likes),
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
