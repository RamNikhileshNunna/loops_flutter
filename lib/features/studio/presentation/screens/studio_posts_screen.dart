import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/studio/data/repositories/studio_repository_impl.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/presentation/widgets/studio_pills.dart';
import 'package:loops_flutter/features/studio/presentation/widgets/studio_post_row.dart';

class StudioPostsScreen extends ConsumerStatefulWidget {
  const StudioPostsScreen({super.key});

  @override
  ConsumerState<StudioPostsScreen> createState() => _StudioPostsScreenState();
}

class _StudioPostsScreenState extends ConsumerState<StudioPostsScreen> {
  static const _filters = <StudioPillItem<String>>[
    StudioPillItem(
        value: 'all',
        label: 'All Posts',
        icon: Icons.play_arrow_outlined,
        activeIcon: Icons.play_arrow),
    StudioPillItem(
        value: 'pinned',
        label: 'Pinned',
        icon: Icons.push_pin_outlined,
        activeIcon: Icons.push_pin),
    StudioPillItem(
        value: 'processing',
        label: 'Processing',
        icon: Icons.timer_outlined,
        activeIcon: Icons.timer),
  ];

  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  String _filter = 'all';
  String _search = '';

  final List<StudioPost> _posts = [];
  int _total = 0;
  String? _cursor;
  bool _hasMore = true;
  bool _loading = false;
  bool _loadingMore = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 400) {
      _load();
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final t = v.trim();
      if (t == _search) return;
      _search = t;
      _load(reset: true);
    });
  }

  void _setFilter(String f) {
    if (f == _filter) return;
    setState(() => _filter = f);
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _cursor = null;
      _hasMore = true;
      _error = false;
    } else if (_loadingMore || _loading || !_hasMore) {
      return;
    }

    setState(() {
      if (reset) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final page = await ref.read(studioRepositoryProvider).getPosts(
            cursor: reset ? null : _cursor,
            search: _search,
            filter: _filter,
          );
      if (!mounted) return;
      setState(() {
        if (reset) _posts.clear();
        final existing = _posts.map((p) => p.id).toSet();
        _posts.addAll(page.posts.where((p) => !existing.contains(p.id)));
        _total = page.totalVideos;
        _cursor = page.nextCursor;
        _hasMore = _cursor != null && _cursor!.isNotEmpty;
      });
    } catch (_) {
      if (mounted && reset) setState(() => _error = true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body: Column(
        children: [
          StudioPillBar<String>(
            items: _filters,
            selected: _filter,
            onSelected: _setFilter,
          ),
          if (_filter == 'all')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search by caption',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: _body(cs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(ColorScheme cs) {
    if (_loading) return AppLoading.centered();
    if (_error) {
      return _empty(cs,
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load posts",
          subtitle: 'Pull down to try again, or check your connection.');
    }
    if (_posts.isEmpty) {
      return _empty(cs,
          icon: Icons.videocam_outlined,
          title: _search.isNotEmpty ? 'No matches' : 'No posts yet',
          subtitle: _search.isNotEmpty
              ? 'Nothing matches "$_search".'
              : 'Your published and processing videos will appear here.');
    }

    return ListView.separated(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _posts.length + 1,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 90,
        color: cs.outlineVariant.withValues(alpha: 0.4),
      ),
      itemBuilder: (context, i) {
        if (i == _posts.length) return _footer(cs);
        return StudioPostRow(
          post: _posts[i],
          onTap: () {}, // Detail/edit view is out of scope; read-only here.
        );
      },
    );
  }

  Widget _footer(ColorScheme cs) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: AppLoading(size: 24),
      );
    }
    if (!_hasMore && _posts.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            _total > 0
                ? "You've reached the end · $_total ${_total == 1 ? 'post' : 'posts'}"
                : "You've reached the end",
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

  Widget _empty(ColorScheme cs,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 48, color: cs.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
        ),
      ],
    );
  }
}
