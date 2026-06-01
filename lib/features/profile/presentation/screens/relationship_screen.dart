import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Connect', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
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
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, index) {
            return _UserTile(user: users[index]);
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
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
            backgroundColor: Colors.grey[800],
            backgroundImage: widget.user.avatar != null
                ? CachedNetworkImageProvider(widget.user.avatar!)
                : null,
            child: widget.user.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.user.bio != null)
                  Text(
                    widget.user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!widget.user.isOwner)
            ElevatedButton(
              onPressed: _busy ? null : _toggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.transparent : Colors.white,
                foregroundColor: _isFollowing ? Colors.white : Colors.black,
                side: const BorderSide(color: Colors.white30),
                minimumSize: const Size(80, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isFollowing ? 'Unfollow' : 'Follow'),
            ),
        ],
      ),
    );
  }
}
