import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/core/widgets/skeletons.dart';

import '../controllers/activity_controller.dart';
import '../../domain/models/notification_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityControllerProvider.notifier).refresh();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: state.when(
        data: (items) => RefreshIndicator(
          backgroundColor: Colors.black,
          color: Colors.white,
          onRefresh: () =>
              ref.read(activityControllerProvider.notifier).refresh(),
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : _buildGroupedList(items),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        loading: () => const ActivitySkeleton(),
      ),
    );
  }

  Widget _buildGroupedList(List<NotificationModel> items) {
    // Sort newest first
    final sorted = [...items]
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

    final now = DateTime.now();
    final Map<String, List<NotificationModel>> groups = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final n in sorted) {
      final dt = n.createdAt ?? now;
      final local = dt.toLocal();
      final diffDays = now.difference(local).inDays;
      if (diffDays == 0) {
        groups['Today']!.add(n);
      } else if (diffDays == 1) {
        groups['Yesterday']!.add(n);
      } else {
        groups['Earlier']!.add(n);
      }
    }

    final List<Widget> children = [];

    void addSection(String title, List<NotificationModel> list) {
      if (list.isEmpty) return;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      for (final n in list) {
        children.add(_NotificationTile(notification: n));
      }
    }

    addSection('Today', groups['Today']!);
    addSection('Yesterday', groups['Yesterday']!);
    addSection('Earlier', groups['Earlier']!);

    return ListView(controller: _scrollController, children: children);
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLike = notification.type == 'video.like';
    final isFollow = notification.type == 'new_follower';

    final primaryText = notification.actorName ?? 'Someone';

    String actionText;
    if (isLike) {
      actionText = 'liked your video';
    } else if (isFollow) {
      actionText = 'started following you';
    } else {
      actionText = notification.targetTitle ?? 'sent you a notification';
    }

    final timeText = _formatTimeAgo(notification.createdAt);

    IconData badgeIcon;
    Color badgeColor;
    if (isLike) {
      badgeIcon = Icons.favorite;
      badgeColor = Colors.redAccent;
    } else if (isFollow) {
      badgeIcon = Icons.person_add;
      badgeColor = Colors.blueAccent;
    } else {
      badgeIcon = Icons.notifications;
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: notification.actorAvatarUrl != null
                    ? NetworkImage(notification.actorAvatarUrl!)
                    : null,
                child: notification.actorAvatarUrl == null
                    ? Text(
                        primaryText.isNotEmpty
                            ? primaryText[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(badgeIcon, size: 12, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: primaryText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: actionText,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (notification.videoThumbnailUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                notification.videoThumbnailUrl!,
                width: 44,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dateTime.toLocal());

  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '${weeks}w';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo';
  final years = (diff.inDays / 365).floor();
  return '${years}y';
}
