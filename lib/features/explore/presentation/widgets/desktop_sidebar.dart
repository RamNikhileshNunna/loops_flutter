import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../controllers/explore_controller.dart';
import 'package:loops_flutter/features/explore/presentation/screens/tag_feed_screen.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:loops_flutter/features/search/presentation/screens/search_screen.dart';

/// Right-hand column shown on wide desktop windows: search entry, suggested
/// accounts, and trending tags. Reuses the existing explore providers.
class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        left: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SidebarSearch(),
              SizedBox(height: 24),
              _SidebarSuggested(),
              SizedBox(height: 28),
              _SidebarTrending(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSearch extends StatelessWidget {
  const _SidebarSearch();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 10),
            Text(
              'Search',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSuggested extends ConsumerWidget {
  const _SidebarSuggested();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(suggestedAccountsProvider);

    return state.when(
      loading: () => const _SectionShell(
        title: 'Suggested for you',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: AppLoading(size: 18, strokeWidth: 2)),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        final shown = users.take(6).toList();
        return _SectionShell(
          title: 'Suggested for you',
          child: Column(
            children: [
              for (final u in shown) _SidebarAccountRow(user: u),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarAccountRow extends ConsumerStatefulWidget {
  const _SidebarAccountRow({required this.user});
  final UserModel user;

  @override
  ConsumerState<_SidebarAccountRow> createState() => _SidebarAccountRowState();
}

class _SidebarAccountRowState extends ConsumerState<_SidebarAccountRow> {
  bool _following = false;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    final next = !_following;
    setState(() {
      _busy = true;
      _following = next;
    });
    try {
      final repo = ref.read(exploreRepositoryProvider);
      if (next) {
        await repo.followUser(widget.user.id);
      } else {
        await repo.unfollowUser(widget.user.id);
      }
    } catch (_) {
      if (mounted) setState(() => _following = !next);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = widget.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userId: user.id)),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage: user.avatar != null
                  ? CachedNetworkImageProvider(user.avatar!)
                  : null,
              child: user.avatar == null
                  ? Icon(Icons.person, color: cs.onSurfaceVariant, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: user.id)),
              ),
              child: Text(
                user.username,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggle,
            child: Text(
              _following ? 'Following' : 'Follow',
              style: TextStyle(
                color: _following ? cs.onSurfaceVariant : cs.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTrending extends ConsumerWidget {
  const _SidebarTrending();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(trendingTagsProvider);

    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return _SectionShell(
          title: 'Trending',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in tags.take(12))
                // Each chip opens that hashtag's full video feed.
                Material(
                  color: cs.surfaceContainerHighest,
                  shape: StadiumBorder(
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TagFeedScreen(tag: t.name),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      child: Text(
                        '#${t.name}',
                        style: TextStyle(color: cs.onSurface, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
