import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/models/comment_model.dart';
import '../../data/repositories/video_actions_repository_impl.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  const CommentsSheet({super.key, required this.videoId});
  final String videoId;

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  List<CommentModel> _comments = [];
  bool _loading = true;
  String? _error;
  bool _posting = false;

  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Data ─────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ref
          .read(videoActionsRepositoryProvider)
          .getVideoComments(widget.videoId);

      final parsed = raw.whereType<Map>().expand<CommentModel>((e) {
        try {
          return [CommentModel.fromJson(Map<String, dynamic>.from(e))];
        } catch (_) {
          return [];
        }
      }).toList();

      if (mounted) setState(() {
        _comments = parsed;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _post() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _posting) return;

    final parentId = _replyingTo?.id;
    _textCtrl.clear();
    _focusNode.unfocus();
    setState(() {
      _replyingTo = null;
      _posting = true;
    });

    try {
      final ok = await ref
          .read(videoActionsRepositoryProvider)
          .commentVideo(widget.videoId, text, parentId: parentId);

      if (ok) unawaited(_load());
      if (!ok && mounted) {
        _showError('Failed to post comment');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  void _toggleLike(CommentModel c) async {
    final idx = _comments.indexWhere((x) => x.id == c.id);
    if (idx == -1) return;

    final wasLiked = c.isLiked;
    final countBefore = c.likeCount;

    setState(() {
      _comments[idx] = c.copyWith(
        isLiked: !wasLiked,
        likeCount: countBefore + (wasLiked ? -1 : 1),
      );
    });

    try {
      final repo = ref.read(videoActionsRepositoryProvider);
      final ok = wasLiked
          ? await repo.unlikeComment(widget.videoId, c.id)
          : await repo.likeComment(widget.videoId, c.id);

      if (!ok && mounted) {
        setState(() {
          _comments[idx] = c.copyWith(isLiked: wasLiked, likeCount: countBefore);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _comments[idx] = c.copyWith(isLiked: wasLiked, likeCount: countBefore);
        });
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.65, 0.95],
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(
                count: _comments.length,
                onRefresh: _load,
              ),
              Expanded(child: _buildBody(scrollCtrl)),
              _InputBar(
                ctrl: _textCtrl,
                focusNode: _focusNode,
                replyingTo: _replyingTo,
                posting: _posting,
                onCancelReply: () => setState(() => _replyingTo = null),
                onSend: _post,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ScrollController scrollCtrl) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white38, size: 40),
            const SizedBox(height: 10),
            Text('Could not load comments',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load,
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
    }
    if (_comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text('No comments yet',
                style: TextStyle(color: Colors.white54, fontSize: 15)),
            SizedBox(height: 4),
            Text('Be the first to comment',
                style: TextStyle(color: Colors.white24, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _comments.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.white10, indent: 60),
      itemBuilder: (_, i) => _CommentTile(
        comment: _comments[i],
        videoId: widget.videoId,
        onReply: (c) {
          setState(() => _replyingTo = c);
          _focusNode.requestFocus();
        },
        onLike: _toggleLike,
      ),
    );
  }
}

// ─── Sheet chrome ─────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.count, required this.onRefresh});
  final int count;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            count > 0 ? '$count Comments' : 'Comments',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white38, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.ctrl,
    required this.focusNode,
    required this.replyingTo,
    required this.posting,
    required this.onCancelReply,
    required this.onSend,
  });

  final TextEditingController ctrl;
  final FocusNode focusNode;
  final CommentModel? replyingTo;
  final bool posting;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: Colors.white.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded,
                        size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Replying to ${_username(replyingTo!.account)}',
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: ctrl,
                        focusNode: focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: replyingTo != null
                              ? 'Write a reply…'
                              : 'Add a comment…',
                          hintStyle:
                              const TextStyle(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: posting ? null : onSend,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: posting ? Colors.white24 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: posting
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded,
                              color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends ConsumerStatefulWidget {
  const _CommentTile({
    required this.comment,
    required this.videoId,
    required this.onReply,
    required this.onLike,
  });

  final CommentModel comment;
  final String videoId;
  final void Function(CommentModel) onReply;
  final void Function(CommentModel) onLike;

  @override
  ConsumerState<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<_CommentTile> {
  List<CommentModel> _replies = [];
  bool _showReplies = false;
  bool _loadingReplies = false;

  Future<void> _toggleReplies() async {
    if (_showReplies && _replies.isNotEmpty) {
      setState(() => _showReplies = false);
      return;
    }
    if (_replies.isNotEmpty) {
      setState(() => _showReplies = true);
      return;
    }
    setState(() {
      _loadingReplies = true;
      _showReplies = true;
    });
    try {
      final raw = await ref
          .read(videoActionsRepositoryProvider)
          .getCommentReplies(widget.videoId, widget.comment.id);

      final replies = raw.whereType<Map>().expand<CommentModel>((e) {
        try {
          return [CommentModel.fromJson(Map<String, dynamic>.from(e))];
        } catch (_) {
          return [];
        }
      }).toList();

      if (mounted) setState(() {
        _replies = replies;
        _loadingReplies = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingReplies = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final username = _username(c.account);
    final avatarUrl = c.account?['avatar']?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _Avatar(url: avatarUrl, name: username, radius: 18),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + time
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(c.createdAt),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),

                // Comment body
                const SizedBox(height: 4),
                Text(
                  c.comment,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),

                // Actions row
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => widget.onReply(c),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (c.replyCount > 0) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _toggleReplies,
                        child: Row(
                          children: [
                            if (_loadingReplies)
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5, color: Colors.white38),
                              )
                            else
                              Icon(
                                _showReplies
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: Colors.white54,
                              ),
                            const SizedBox(width: 2),
                            Text(
                              _showReplies
                                  ? 'Hide replies'
                                  : '${c.replyCount} ${c.replyCount == 1 ? 'reply' : 'replies'}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Replies
                if (_showReplies && _replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...(_replies.map((r) => _ReplyTile(reply: r))),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Like button
          GestureDetector(
            onTap: () => widget.onLike(c),
            child: Column(
              children: [
                Icon(
                  c.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: c.isLiked ? const Color(0xFFFF2D55) : Colors.white38,
                ),
                const SizedBox(height: 2),
                Text(
                  _fmt(c.likeCount),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reply tile ───────────────────────────────────────────────────────────────

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply});
  final CommentModel reply;

  @override
  Widget build(BuildContext context) {
    final username = _username(reply.account);
    final avatarUrl = reply.account?['avatar']?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: avatarUrl, name: username, radius: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeago.format(reply.createdAt),
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.comment,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar widget ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, required this.radius});
  final String? url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      backgroundImage:
          url != null && url!.isNotEmpty ? CachedNetworkImageProvider(url!) : null,
      child: (url == null || url!.isEmpty)
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _username(Map<String, dynamic>? account) {
  if (account == null) return 'User';
  return account['username']?.toString() ??
      account['name']?.toString() ??
      'User';
}

String _fmt(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return '$v';
}
