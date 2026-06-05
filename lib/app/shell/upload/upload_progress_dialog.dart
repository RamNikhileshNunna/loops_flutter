import 'package:flutter/material.dart';

/// A modal dialog that shows live upload progress (0–100%).
///
/// Driven by a [ValueNotifier] so the surrounding upload code can push progress
/// updates without this widget needing to be rebuilt by its parent — only the
/// inner [ValueListenableBuilder] repaints as bytes are sent. The dialog itself
/// is dismissed imperatively by the upload flow (via `Navigator.pop`) once the
/// request completes or fails; see `startVideoUpload`.
class UploadProgressDialog extends StatelessWidget {
  const UploadProgressDialog({super.key, required this.progress});

  /// Fraction sent so far, in the range 0.0–1.0.
  final ValueNotifier<double> progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      // Visual styling (shape, background) comes from the global dialogTheme.
      title: const Text(
        'Uploading…',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, value, _) {
          // Clamp so a slightly-over-1.0 final tick can't render as "101%".
          final pct = (value * 100).clamp(0.0, 100.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }
}
