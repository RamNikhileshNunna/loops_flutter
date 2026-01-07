import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/controllers/relationship_controller.dart';

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

class _UserTile extends StatelessWidget {
  final UserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[800],
          backgroundImage: user.avatar != null
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: user.avatar == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.bio != null)
                Text(
                  user.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
        if (!user.isOwner)
          ElevatedButton(
            onPressed: () {
              // TODO: Implement follow/unfollow logic from list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Follow'),
          ),
      ],
    );
  }
}
