import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/activity_controller.dart';
import '../../domain/models/notification_model.dart';

// ─── Filter tabs ──────────────────────────────────────────────────────────────

enum _Filter { all, likes, follows, comments }

extension _FilterLabel on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.likes:
        return 'Likes';
      case _Filter.follows:
        return 'Follows';
      case _Filter.comments:
        return 'Comments';
    }
  }

  bool matches(NotificationModel n) {
    switch (this) {
      case _Filter.all:
        return true;
      case _Filter.likes:
        return n.type.contains('like');
      case _Filter.follows:
        return n.type.contains('follow');
      case _Filter.comments:
        return n.type.contains('comment');
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final ScrollController _scroll = ScrollController();
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityControllerProvider.notifier).refresh();
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(activityControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(activityControllerProvider);

    final unreadCount = state.asData?.value
            .where((n) => !n.isRead)
            .length ??
        0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _Header(
              unreadCount: unreadCount,
              onRefresh: () =>
                  ref.read(activityControllerProvider.notifier).refresh(),
            ),

            // ── Filter chips ─────────────────────────────────────────────
            _FilterRow(
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),

            const SizedBox(height: 4),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: state.when(
                loading: () => _buildSkeletons(),
                error: (e, _) => _ErrorView(
                  onRetry: () =>
                      ref.read(activityControllerProvider.notifier).refresh(),
                ),
                data: (items) {
                  final filtered =
                      items.where(_filter.matches).toList();
                  if (filtered.isEmpty) {
                    return _EmptyView(filter: _filter);
                  }
                  return RefreshIndicator(
                    color: cs.primary,
                    backgroundColor: cs.surfaceContainerHighest,
                    onRefresh: () =>
                        ref.read(activityControllerProvider.notifier).refresh(),
                    child: _GroupedList(
                      items: filtered,
                      scrollController: _scroll,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const _NotifSkeleton(),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.unreadCount, required this.onRefresh});
  final int unreadCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Activity',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Filter row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});
  final _Filter selected;
  final void Function(_Filter) onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _Filter.values.map((f) {
          final active = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: active
                      ? null
                      : Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    color: active ? cs.onPrimary : cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Grouped list ─────────────────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList(
      {required this.items, required this.scrollController});
  final List<NotificationModel> items;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort(
        (a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()),
      );

    final now = DateTime.now();
    final Map<String, List<NotificationModel>> groups = {
      'New': [],
      'Yesterday': [],
      'This week': [],
      'Earlier': [],
    };

    for (final n in sorted) {
      final dt = (n.createdAt ?? now).toLocal();
      final diff = now.difference(dt);
      if (diff.inHours < 24) {
        groups['New']!.add(n);
      } else if (diff.inDays < 2) {
        groups['Yesterday']!.add(n);
      } else if (diff.inDays < 7) {
        groups['This week']!.add(n);
      } else {
        groups['Earlier']!.add(n);
      }
    }

    final children = <Widget>[];
    for (final entry in groups.entries) {
      if (entry.value.isEmpty) continue;
      children.add(_GroupHeader(title: entry.key));
      for (final n in entry.value) {
        children.add(_NotifTile(notification: n));
      }
    }
    children.add(const SizedBox(height: 80));

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: children,
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final n = notification;
    final isLike = n.type.contains('like');
    final isFollow = n.type.contains('follow');
    final isComment = n.type.contains('comment');

    // Badge — like uses the brand accent; follow/comment keep semantic hues.
    final (IconData badgeIcon, Color badgeColor) = isLike
        ? (Icons.favorite_rounded, cs.primary)
        : isFollow
            ? (Icons.person_add_rounded, const Color(0xFF3B82F6))
            : isComment
                ? (Icons.chat_bubble_rounded, const Color(0xFF10B981))
                : (Icons.notifications_rounded, cs.onSurfaceVariant);

    // Action text
    final action = isLike
        ? 'liked your video'
        : isFollow
            ? 'started following you'
            : isComment
                ? 'commented on your video'
                : (n.targetTitle ?? 'sent a notification');

    final actor = n.actorName ?? 'Someone';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: n.isRead
            ? Colors.transparent
            : cs.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Unread accent bar
          Container(
            width: 3,
            height: 56,
            decoration: BoxDecoration(
              color: n.isRead ? Colors.transparent : badgeColor,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12)),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar + badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: n.actorAvatarUrl != null
                    ? CachedNetworkImageProvider(n.actorAvatarUrl!)
                    : null,
                child: n.actorAvatarUrl == null
                    ? Text(
                        actor.isNotEmpty ? actor[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                  child: Icon(badgeIcon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: cs.onSurface, fontSize: 13.5),
                      children: [
                        TextSpan(
                          text: actor,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: action,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _timeAgo(n.createdAt),
                    style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Video thumbnail
          if (n.videoThumbnailUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: n.videoThumbnailUrl!,
                width: 40,
                height: 58,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                    width: 40, height: 58, color: cs.surfaceContainerHighest),
                errorWidget: (_, _, _) => Container(
                    width: 40, height: 58, color: cs.surfaceContainerHighest),
              ),
            ),
          ],

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ─── Empty / error / skeleton ─────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.filter});
  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAll = filter == _Filter.all;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAll ? Icons.notifications_none_rounded : Icons.inbox_outlined,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isAll ? 'All caught up!' : 'No ${filter.label.toLowerCase()}',
            style: TextStyle(
                color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            isAll
                ? 'Your notifications will appear here'
                : 'Nothing to show for this filter',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: cs.onSurfaceVariant, size: 48),
          const SizedBox(height: 12),
          Text('Could not load notifications',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NotifSkeleton extends StatelessWidget {
  const _NotifSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 13,
                width: 160,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 11,
                width: 100,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Time helper ─────────────────────────────────────────────────────────────

String _timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
