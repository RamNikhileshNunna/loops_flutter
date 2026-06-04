import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/controllers/relationship_controller.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';

class RelationshipScreen extends ConsumerWidget {
  final String userId;
  final int initialTabIndex; // 0 for Following, 1 for Followers

  const RelationshipScreen({
    super.key,
    required this.userId,
    required this.initialTabIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Following'),
              Tab(text: 'Followers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UserList(userId: userId, type: _ListType.following),
            _UserList(userId: userId, type: _ListType.followers),
          ],
        ),
      ),
    );
  }
}

enum _ListType { following, followers }

class _UserList extends ConsumerWidget {
  final String userId;
  final _ListType type;

  const _UserList({required this.userId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = type == _ListType.following
        ? followingProvider(userId)
        : followersProvider(userId);

    final asyncValue = ref.watch(provider);

    return asyncValue.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text(
              type == _ListType.following
                  ? 'Not following anyone yet'
                  : 'No followers yet',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) {
            return _UserTile(user: users[index]);
          },
        );
      },
      loading: () =>
          AppLoading.centered(),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }
}

class _UserTile extends ConsumerStatefulWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  ConsumerState<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends ConsumerState<_UserTile> {
  bool _isFollowing = false;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    final repo = ref.read(profileRepositoryProvider);
    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !wasFollowing);
    final success = wasFollowing
        ? await repo.unfollowUser(widget.user.id)
        : await repo.followUser(widget.user.id);
    if (!success && mounted) setState(() => _isFollowing = wasFollowing);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: widget.user.id),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.surfaceContainerHighest,
            backgroundImage: widget.user.avatar != null
                ? CachedNetworkImageProvider(widget.user.avatar!)
                : null,
            child: widget.user.avatar == null
                ? Icon(Icons.person, color: cs.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.username,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.user.bio != null)
                  Text(
                    widget.user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!widget.user.isOwner)
            _isFollowing
                ? OutlinedButton(
                    onPressed: _busy ? null : _toggle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _busy
                        ? const AppLoading.small()
                        : const Text('Unfollow'),
                  )
                : FilledButton(
                    onPressed: _busy ? null : _toggle,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _busy
                        ? AppLoading.small(color: cs.onPrimary)
                        : const Text('Follow'),
                  ),
        ],
      ),
    );
  }
}
