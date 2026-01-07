import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:loops_flutter/features/explore/presentation/widgets/explore_grid.dart';
import 'package:loops_flutter/features/explore/presentation/widgets/suggested_accounts_list.dart';
import 'package:loops_flutter/features/explore/presentation/widgets/trending_tags_filter.dart';
import 'package:loops_flutter/core/widgets/skeletons.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedTag;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_selectedTag != null && _selectedTag!.isNotEmpty) {
        ref.read(tagFeedControllerProvider(_selectedTag!).notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to trending tags to set default selection
    // Auto-select first tag if none selected
    ref.listen(trendingTagsProvider, (prev, next) {
      if (_selectedTag == null && next.hasValue && next.value!.isNotEmpty) {
        setState(() {
          _selectedTag = next.value!.first.name;
        });
      }
    });

    final trendingTagsState = ref.watch(trendingTagsProvider);
    // If we're loading tags initially and have no selection, show full skeleton
    if (trendingTagsState.isLoading && _selectedTag == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: ExploreSkeleton()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh everything
            ref.invalidate(suggestedAccountsProvider);
            ref.invalidate(trendingTagsProvider);
            if (_selectedTag != null) {
              ref.invalidate(tagFeedControllerProvider(_selectedTag!));
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                floating: true,
                title: const Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to search screen
                    },
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SuggestedAccountsList()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: TrendingTagsFilter(
                  selectedTag: _selectedTag,
                  onTagSelected: (tag) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (_selectedTag != null)
                ExploreGrid(tag: _selectedTag!)
              else
                // Fallback if tags loaded but empty or error
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No content found',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Bottom padding
              ),
            ],
          ),
        ),
      ),
    );
  }
}
