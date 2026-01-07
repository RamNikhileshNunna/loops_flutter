import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import '../../domain/models/video_model.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_view.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _retriedForYou = false;
  bool _retriedFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Ensure feed loads on first entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forYouNotifier().refresh();
      _followingNotifier().refresh();
    });
    _tabController.addListener(() {
      setState(() {});
      // Trigger load for following feed when switched the first time
      if (_tabController.index == 1) {
        final following = ref.read(followingFeedControllerProvider);
        if (following.hasError ||
            following.isLoading ||
            following.value?.isNotEmpty == true) {
          return;
        }
        _followingNotifier().refresh();
      }
    });
  }

  FeedController _forYouNotifier() => ref.read(feedControllerProvider.notifier);

  FollowingFeedController _followingNotifier() =>
      ref.read(followingFeedControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    // Fullscreen immersive like TikTok
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final isForYou = _tabController.index == 0;
    final feedState = isForYou
        ? ref.watch(feedControllerProvider)
        : ref.watch(followingFeedControllerProvider);

    // Check if we need to retry empty feed automatically
    final isRetrying = _maybeRetryIfEmpty(isForYou, feedState);

    return Scaffold(
      backgroundColor: Colors.black,
      body: feedState.when(
        data: (videos) =>
            _buildFeedBody(context, feedState, videos, isForYou, isRetrying),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  bool _maybeRetryIfEmpty(
    bool isForYou,
    AsyncValue<List<VideoModel>> feedState,
  ) {
    final hasData = feedState.asData?.value.isNotEmpty == true;
    final alreadyRetried = isForYou ? _retriedForYou : _retriedFollowing;

    if (hasData ||
        feedState.isLoading ||
        feedState.isRefreshing ||
        alreadyRetried) {
      return false;
    }

    // Schedule retry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isForYou) {
        _forYouNotifier().refresh();
      } else {
        _followingNotifier().refresh();
      }
    });

    // Mark as retried
    if (isForYou) {
      _retriedForYou = true;
    } else {
      _retriedFollowing = true;
    }
    return true;
  }

  Widget _buildFeedBody(
    BuildContext context,
    AsyncValue<List<VideoModel>> feedState,
    List<VideoModel> videos,
    bool isForYou,
    bool isRetrying,
  ) {
    // Show loading if state says so OR if we just triggered an auto-retry
    final isLoading =
        feedState.isLoading || feedState.isRefreshing || isRetrying;

    if (videos.isEmpty) {
      return Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No videos found',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (isForYou) {
                        await _forYouNotifier().refresh();
                      } else {
                        await _followingNotifier().refresh();
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.black,
      color: Colors.white,
      onRefresh: () async {
        if (isForYou) {
          await _forYouNotifier().refresh();
        } else {
          await _followingNotifier().refresh();
        }
      },
      child: Stack(
        children: [
          FeedView(
            videos: videos,
            onLoadMore: () {
              if (isForYou) {
                ref.read(feedControllerProvider.notifier).loadMore();
              } else {
                ref.read(followingFeedControllerProvider.notifier).loadMore();
              }
            },
          ),
          // Top overlay with tabs similar to Reels
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.video_collection_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(color: Colors.white, width: 3),
                          insets: EdgeInsets.symmetric(horizontal: 18),
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        tabs: const [
                          Tab(text: 'For You'),
                          Tab(text: 'Following'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_tabController.index == 0) {
                          _forYouNotifier().refresh();
                        } else {
                          _followingNotifier().refresh();
                        }
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
