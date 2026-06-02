import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/video_model.dart';
import 'video_player_widget.dart';

class FeedView extends StatefulWidget {
  const FeedView({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.onLoadMore,
  });

  final List<VideoModel> videos;
  final int initialIndex;
  final VoidCallback? onLoadMore;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videos.isEmpty) return;

    // Distinguish a *replaced* feed (refresh / tab switch) from a *grown* one
    // (pagination appends a page to the end). loadMore emits a new list
    // instance with the same leading videos, so an identity check alone would
    // treat every append as a replacement and jump to the top — snapping the
    // user back to the first video each time they near the end, looping the
    // feed forever. Only reset when the leading video actually changes.
    final oldFirstId =
        oldWidget.videos.isNotEmpty ? oldWidget.videos.first.id : null;
    final newFirstId = widget.videos.first.id;
    if (oldFirstId != newFirstId) {
      _currentIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    } else if (_currentIndex > widget.videos.length - 1) {
      // List shrank under the current page (e.g. a shorter refresh); keep the
      // index in range so the PageView doesn't read past the end.
      _currentIndex = widget.videos.length - 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Desktop keyboard paging: arrows / PageUp-Down / j-k move between videos.
  void _step(int delta) {
    if (widget.videos.isEmpty) return;
    final target =
        (_currentIndex + delta).clamp(0, widget.videos.length - 1);
    if (target == _currentIndex) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown ||
        k == LogicalKeyboardKey.pageDown ||
        k == LogicalKeyboardKey.keyJ) {
      _step(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp ||
        k == LogicalKeyboardKey.pageUp ||
        k == LogicalKeyboardKey.keyK) {
      _step(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Build the adjacent pages ahead of time so the next video's controller
      // initialises and buffers before the user finishes swiping — giving
      // near-instant playback instead of a black-frame + spinner each time.
      allowImplicitScrolling: true,
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
        if (index >= widget.videos.length - 3) {
          widget.onLoadMore?.call();
        }
      },
      itemBuilder: (context, index) => VideoPlayerWidget(
        // Stable key keeps each page's controller bound to its video while
        // pages are recycled, preventing needless re-initialisation.
        key: ValueKey(widget.videos[index].id),
        video: widget.videos[index],
        isActive: index == _currentIndex,
      ),
      ),
    );
  }
}
