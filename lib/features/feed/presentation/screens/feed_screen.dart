import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/theme/app_theme.dart';
import 'package:loops_flutter/core/widgets/app_loading.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_view.dart';

enum _Tab { forYou, following }

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  _Tab _tab = _Tab.forYou;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _switchTab(_Tab tab) {
    if (_tab == tab) return;
    setState(() => _tab = tab);
    if (tab == _Tab.following) {
      final state = ref.read(followingFeedControllerProvider);
      if (!state.isLoading && (state.hasError || state.value?.isEmpty == true)) {
        ref.read(followingFeedControllerProvider.notifier).refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final forYouState = ref.watch(feedControllerProvider);
    final followingState = ref.watch(followingFeedControllerProvider);
    final activeState = _tab == _Tab.forYou ? forYouState : followingState;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Main feed area ────────────────────────────────────────────────
          activeState.when(
            loading: () => _loadingView(),
            error: (e, _) => _errorView(e),
            data: (videos) {
              if (videos.isEmpty) return _emptyView();
              return FeedView(
                // Use a ValueKey so Flutter replaces the widget (and its
                // PageController) when the tab changes, giving a clean start.
                key: ValueKey(_tab),
                videos: videos,
                onLoadMore: _tab == _Tab.forYou
                    ? () => ref.read(feedControllerProvider.notifier).loadMore()
                    : () => ref
                          .read(followingFeedControllerProvider.notifier)
                          .loadMore(),
              );
            },
          ),

          // ── Top header overlay ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              tab: _tab,
              isRefreshing: activeState.isRefreshing,
              onTabChanged: _switchTab,
              onRefresh: () {
                _tab == _Tab.forYou
                    ? ref.read(feedControllerProvider.notifier).refresh()
                    : ref
                        .read(followingFeedControllerProvider.notifier)
                        .refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppLoading(size: 28, color: Colors.white),
        const SizedBox(height: 16),
        Text(
          _tab == _Tab.forYou ? 'Loading your feed…' : 'Loading following…',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _errorView(Object e) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Could not load feed',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          e.toString(),
          style: const TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            _tab == _Tab.forYou
                ? ref.read(feedControllerProvider.notifier).refresh()
                : ref.read(followingFeedControllerProvider.notifier).refresh();
          },
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.video_library_outlined, color: Colors.white38, size: 56),
        const SizedBox(height: 16),
        Text(
          _tab == _Tab.forYou
              ? 'No videos found'
              : 'Follow people to see their videos here',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            _tab == _Tab.forYou
                ? ref.read(feedControllerProvider.notifier).refresh()
                : ref.read(followingFeedControllerProvider.notifier).refresh();
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
          child: const Text('Refresh'),
        ),
      ],
    ),
  );
}

// ─── Top overlay bar ─────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tab,
    required this.isRefreshing,
    required this.onTabChanged,
    required this.onRefresh,
  });

  final _Tab tab;
  final bool isRefreshing;
  final void Function(_Tab) onTabChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Loops logo mark
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.loop_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Tab switcher
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TabItem(
                      label: 'For You',
                      active: tab == _Tab.forYou,
                      onTap: () => onTabChanged(_Tab.forYou),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 14,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 8),
                    _TabItem(
                      label: 'Following',
                      active: tab == _Tab.following,
                      onTap: () => onTabChanged(_Tab.following),
                    ),
                  ],
                ),
              ),

              // Refresh
              SizedBox(
                width: 36,
                height: 36,
                child: isRefreshing
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: onRefresh,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontSize: active ? 16 : 15,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 2.5,
              width: active ? 28 : 0,
              decoration: BoxDecoration(
                color: AppTheme.brand,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
