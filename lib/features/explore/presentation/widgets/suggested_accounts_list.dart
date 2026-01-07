import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:loops_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

class SuggestedAccountsList extends ConsumerWidget {
  const SuggestedAccountsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(suggestedAccountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Suggested for you',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 240, // Height for the cards
          child: suggestionsAsync.when(
            data: (users) {
              if (users.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _SuggestedUserCard(user: users[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _SuggestedUserCard extends ConsumerWidget {
  final UserModel user;
  const _SuggestedUserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {}, // Dismiss suggestion
              child: const Icon(Icons.close, color: Colors.grey, size: 18),
            ),
          ),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[800],
            backgroundImage: user.avatar != null
                ? CachedNetworkImageProvider(user.avatar!)
                : null,
            child: user.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.bio ?? 'No bio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.postCount} videos • ${user.followerCount} followers',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Optimistic UI or simple refresh
                await ref.read(exploreRepositoryProvider).followUser(user.id);
                // Refresh list to remove followed user or update state
                ref.invalidate(suggestedAccountsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Follow'),
            ),
          ),
        ],
      ),
    );
  }
}
