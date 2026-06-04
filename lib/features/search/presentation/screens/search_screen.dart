import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/explore/data/repositories/explore_repository_impl.dart';
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
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    ]);

    if (mounted) {
      setState(() {
        _users = results[0] as List<UserModel>;
        _videos = (results[1] as dynamic).videos as List<VideoModel>;
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
            hintText: 'Search users or videos...',
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
          tabs: const [Tab(text: 'People'), Tab(text: 'Videos')],
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
