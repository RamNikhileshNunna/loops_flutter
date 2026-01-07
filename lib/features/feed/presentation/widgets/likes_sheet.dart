import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/video_like_model.dart';
import '../../data/repositories/video_actions_repository_impl.dart';

class LikesSheet extends ConsumerStatefulWidget {
  final String videoId;

  const LikesSheet({super.key, required this.videoId});

  @override
  ConsumerState<LikesSheet> createState() => _LikesSheetState();
}

class _LikesSheetState extends ConsumerState<LikesSheet> {
  List<VideoLikeModel> _likes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final rawLikes = await repo.getVideoLikes(widget.videoId);

      if (mounted) {
        setState(() {
          _likes = rawLikes.map((e) => VideoLikeModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Likes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : _likes.isEmpty
                    ? const Center(
                        child: Text(
                          'No likes yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _likes.length,
                        itemBuilder: (context, index) {
                          final like = _likes[index];
                          // VideoLikeModel now directly matches the API user object
                          final username = like.username;
                          final avatarUrl = like.avatar;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? Text(username[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(
                              username,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              like.name,
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
