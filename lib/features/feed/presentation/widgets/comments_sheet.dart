import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/comment_model.dart';
import 'dart:async';
import '../../data/repositories/video_actions_repository_impl.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String videoId;

  const CommentsSheet({super.key, required this.videoId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _commentController = TextEditingController();
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final rawComments = await repo.getVideoComments(widget.videoId);

      if (mounted) {
        setState(() {
          _comments = rawComments.map((e) => CommentModel.fromJson(e)).toList();
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

  Future<void> _likeComment(CommentModel comment) async {
    // Optimistic update
    final isLiked = comment.isLiked;
    final newLikeCount = isLiked
        ? comment.likeCount - 1
        : comment.likeCount + 1;
    final updatedComment = comment.copyWith(
      isLiked: !isLiked,
      likeCount: newLikeCount,
    );

    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final success = isLiked
          ? await repo.unlikeComment(comment.id)
          : await repo.likeComment(comment.id);

      if (!success) {
        // Revert
        if (mounted) {
          setState(() {
            final index = _comments.indexWhere((c) => c.id == comment.id);
            if (index != -1) {
              _comments[index] = comment;
            }
          });
        }
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          final index = _comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            _comments[index] = comment;
          }
        });
      }
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Optimistic update could be added here
    _commentController.clear();
    final parentId = _replyingTo?.id;
    setState(() {
      _replyingTo = null; // Reset reply state
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final success = await repo.commentVideo(
        widget.videoId,
        text,
        parentId: parentId,
      );

      if (success) {
        // Refresh comments
        unawaited(_fetchComments());
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post comment')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle and Title
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
                  'Comments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Comments List
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
                    : _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _CommentItem(
                            comment: _comments[index],
                            videoId: widget.videoId,
                            onReply: (comment) {
                              setState(() {
                                _replyingTo = comment;
                              });
                            },
                            onLike: _likeComment,
                          );
                        },
                      ),
              ),

              // Input Area
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_replyingTo != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'Replying to ${_replyingTo?.account?['username'] ?? 'User'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _replyingTo = null),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _postComment,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentItem extends ConsumerStatefulWidget {
  final CommentModel comment;
  final String videoId;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onLike;

  const _CommentItem({
    required this.comment,
    required this.videoId,
    required this.onReply,
    required this.onLike,
  });

  @override
  ConsumerState<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<_CommentItem> {
  bool _showReplies = false;
  List<CommentModel> _replies = [];
  bool _isLoadingReplies = false;

  Future<void> _fetchReplies() async {
    if (_replies.isNotEmpty) {
      setState(() => _showReplies = !_showReplies);
      return;
    }

    setState(() {
      _isLoadingReplies = true;
      _showReplies = true;
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final rawReplies = await repo.getCommentReplies(
        widget.videoId,
        widget.comment.id,
      );

      if (mounted) {
        setState(() {
          _replies = rawReplies.map((e) => CommentModel.fromJson(e)).toList();
          _isLoadingReplies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReplies = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.comment.account?['username'] ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[800],
                child: Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.comment.comment,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timeago.format(widget.comment.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => widget.onReply(widget.comment),
                          child: const Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => widget.onLike(widget.comment),
                    child: Icon(
                      widget.comment.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: widget.comment.isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                  Text(
                    '${widget.comment.likeCount}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (widget.comment.replyCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: GestureDetector(
                onTap: _fetchReplies,
                child: Row(
                  children: [
                    Container(width: 24, height: 1, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _showReplies
                          ? 'Hide replies'
                          : 'View ${widget.comment.replyCount} replies',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (_isLoadingReplies)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_showReplies && _replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _replies.length,
                itemBuilder: (context, index) {
                  final reply = _replies[index];
                  // Render simpler reply item
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[800],
                          child: Text(
                            (reply.account?['username'] ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply.account?['username'] ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                reply.comment,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
