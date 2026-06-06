import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/explore/data/models/tag_model.dart';
import 'package:loops_flutter/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:loops_flutter/features/explore/presentation/screens/tag_feed_screen.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/presentation/screens/feed_view_screen.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/presentation/screens/user_profile_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final TabController _tabController;

  List<UserModel> _users = [];
  List<VideoModel> _videos = [];
  List<TagModel> _tags = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty || q == _lastQuery) return;
    _lastQuery = q;

    setState(() => _isLoading = true);

    final repo = ref.read(exploreRepositoryProvider);
    final results = await Future.wait([
      repo.searchUsers(q),
      repo.searchVideos(q),
      repo.searchHashtags(q),
    ]);

    if (mounted) {
      setState(() {
        _users = results[0] as List<UserModel>;
        _videos = (results[1] as dynamic).videos as List<VideoModel>;
        _tags = results[2] as List<TagModel>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Search users, videos, or #tags...',
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _users = [];
                        _videos = [];
                        _tags = [];
                        _lastQuery = '';
                      });
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          onChanged: (val) {
            setState(() {});
            if (val.trim().length >= 2) {
              _search(val);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'People'),
            Tab(text: 'Videos'),
            Tab(text: 'Tags'),
          ],
        ),
      ),
      body: _isLoading
          ? AppLoading.centered()
          : TabBarView(
              controller: _tabController,
              children: [
                _UserResults(
                  users: _users,
                  onTap: (u) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(userId: u.id),
                    ),
                  ),
                ),
                _VideoResults(videos: _videos),
                _TagResults(tags: _tags, query: _lastQuery),
              ],
            ),
    );
  }
}

class _UserResults extends StatelessWidget {
  const _UserResults({required this.users, required this.onTap});
  final List<UserModel> users;
  final void Function(UserModel) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (users.isEmpty) {
      return Center(
        child: Text('No users found',
            style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (_, i) {
        final u = users[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: cs.surfaceContainerHighest,
            backgroundImage: u.avatar != null
                ? CachedNetworkImageProvider(u.avatar!)
                : null,
            child: u.avatar == null
                ? Icon(Icons.person, color: cs.onSurfaceVariant)
                : null,
          ),
          title: Text(
            '@${u.username}',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: u.bio != null
              ? Text(
                  u.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant),
                )
              : null,
          trailing: Text(
            '${u.followerCount} followers',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          onTap: () => onTap(u),
        );
      },
    );
  }
}

/// Hashtag search results. Each row opens the full-screen [TagFeedScreen].
///
/// When autocomplete returns nothing for a non-empty query we still offer a
/// direct "Go to #query" row — the tag-feed endpoint resolves any tag name, so
/// the user can always jump straight to a hashtag they typed.
class _TagResults extends StatelessWidget {
  const _TagResults({required this.tags, required this.query});
  final List<TagModel> tags;
  final String query;

  static String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  void _open(BuildContext context, String tag) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TagFeedScreen(tag: tag)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cleanQuery = query.replaceAll('#', '').trim();

    if (tags.isEmpty) {
      if (cleanQuery.isEmpty) {
        return Center(
          child: Text('Search for hashtags',
              style: TextStyle(color: cs.onSurfaceVariant)),
        );
      }
      // No suggestions, but let the user jump straight to the typed tag.
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _TagTile(
            name: cleanQuery,
            subtitle: 'Open hashtag',
            cs: cs,
            onTap: () => _open(context, cleanQuery),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tags.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: cs.outlineVariant),
      itemBuilder: (_, i) {
        final t = tags[i];
        final count = t.count > 0 ? t.count : t.views;
        return _TagTile(
          name: t.name,
          subtitle: count > 0 ? '${_fmt(count)} posts' : null,
          cs: cs,
          onTap: () => _open(context, t.name),
        );
      },
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.name,
    required this.cs,
    required this.onTap,
    this.subtitle,
  });
  final String name;
  final String? subtitle;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.surfaceContainerHighest,
        child: Text('#',
            style: TextStyle(
                color: cs.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      title: Text('#$name',
          style:
              TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _VideoResults extends StatelessWidget {
  const _VideoResults({required this.videos});
  final List<VideoModel> videos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (videos.isEmpty) {
      return Center(
        child: Text('No videos found',
            style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final v = videos[index];
        final thumbnail = v.media.thumbnailUrl;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  FeedViewScreen(videos: videos, initialIndex: index),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        memCacheWidth: 400,
                        placeholder: (_, _) =>
                            Container(color: cs.surfaceContainerHighest),
                        errorWidget: (_, _, _) =>
                            Container(color: cs.surfaceContainerHighest),
                      )
                    : Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.play_arrow,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Text(
                    '@${v.account.username}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
