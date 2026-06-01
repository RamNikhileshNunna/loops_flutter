import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search users or videos...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
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
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'People'), Tab(text: 'Videos')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
    if (users.isEmpty) {
      return const Center(
        child: Text('No users found', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (_, i) {
        final u = users[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage: u.avatar != null
                ? CachedNetworkImageProvider(u.avatar!)
                : null,
            child: u.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            '@${u.username}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: u.bio != null
              ? Text(
                  u.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                )
              : null,
          trailing: Text(
            '${u.followerCount} followers',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
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
    if (videos.isEmpty) {
      return const Center(
        child: Text('No videos found', style: TextStyle(color: Colors.white54)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
                        placeholder: (_, __) =>
                            Container(color: Colors.grey[900]),
                        errorWidget: (_, __, ___) =>
                            Container(color: Colors.grey[900]),
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white30,
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
