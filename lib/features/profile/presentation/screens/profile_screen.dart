import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_content_controllers.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/profile_widgets.dart';

import 'package:loops_flutter/features/profile/presentation/screens/relationship_screen.dart';

import 'package:loops_flutter/core/widgets/skeletons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(currentUserControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(currentUserControllerProvider.notifier).refresh();
              ref.read(myVideosControllerProvider.notifier).refresh();
              ref.read(myLikedVideosControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: currentUserState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login'),
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileHeader(
                        user: user,
                        onFollowingTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RelationshipScreen(
                                userId: user.id,
                                initialTabIndex: 0,
                              ),
                            ),
                          );
                        },
                        onFollowersTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RelationshipScreen(
                                userId: user.id,
                                initialTabIndex: 1, // Followers tab
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text('Settings'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'Videos'),
                        Tab(text: 'Likes'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ],
              body: TabBarView(
                children: [
                  _VideosTab(userId: user.id),
                  const _LikesTab(),
                ],
              ),
            ),
          );
        },
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const ProfileSkeleton(),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _VideosTab extends ConsumerWidget {
  const _VideosTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myVideosControllerProvider);

    return state.when(
      data: (videos) => ProfileVideoGrid(
        videos: videos,
        emptyText: 'No videos posted yet',
        isMyVideos: true,
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Failed to load your videos.\n\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LikesTab extends ConsumerWidget {
  const _LikesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLikedVideosControllerProvider);

    return state.when(
      data: (videos) => ProfileVideoGrid(
        videos: videos,
        emptyText: 'No liked videos yet',
        isMyVideos: false,
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Failed to load liked videos.\n\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
