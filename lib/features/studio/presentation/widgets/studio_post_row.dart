import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:loops_flutter/core/widgets/app_loading.dart';
import 'package:loops_flutter/features/studio/domain/models/studio_post.dart';
import 'package:loops_flutter/features/studio/utils/studio_format.dart';

const double _thumbW = 62;
const double _thumbH = 96;

/// A row in the Studio "My Posts" list: thumbnail + caption + status chip +
/// like/comment counts. Processing posts show a spinner and aren't tappable.
class StudioPostRow extends StatelessWidget {
  const StudioPostRow({super.key, required this.post, required this.onTap});

  final StudioPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final processing = post.isProcessing;

    return InkWell(
      onTap: processing ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumb(url: post.thumbnailUrl, processing: processing, cs: cs),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption.isEmpty ? 'Untitled video' : post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRelative(post.createdAt),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusChip(processing: processing, cs: cs),
                      if (post.pinned) ...[
                        const SizedBox(width: 8),
                        _PinnedChip(cs: cs),
                      ],
                      if (!processing) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.favorite_border_rounded,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(formatCompact(post.likes),
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                        const SizedBox(width: 10),
                        Icon(Icons.mode_comment_outlined,
                            size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(formatCompact(post.comments),
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!processing)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.processing, required this.cs});
  final String url;
  final bool processing;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _thumbW,
        height: _thumbH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: cs.surfaceContainerHighest),
                errorWidget: (_, _, _) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.videocam_outlined,
                      color: cs.onSurfaceVariant, size: 20),
                ),
              )
            else
              Container(
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.videocam_outlined,
                    color: cs.onSurfaceVariant, size: 20),
              ),
            if (processing)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const AppLoading.small(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.processing, required this.cs});
  final bool processing;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final bg = processing
        ? const Color(0x33FFC107)
        : const Color(0x3334C759);
    final fg = processing
        ? const Color(0xFFB7860B)
        : const Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        processing ? 'PROCESSING' : 'PUBLISHED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}

class _PinnedChip extends StatelessWidget {
  const _PinnedChip({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PINNED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: cs.primary,
        ),
      ),
    );
  }
}
