import 'package:flutter/material.dart';

/// A quiet, on-brand placeholder shown in place of Flutter's default red
/// "error" screen.
///
/// Installed globally in `main()` via `ErrorWidget.builder`. Without this, a
/// single render exception on one widget (e.g. a malformed image or a layout
/// overflow inside a video overlay) would paint the jarring yellow-and-black
/// error box over the UI. Swapping in a small muted icon keeps an isolated
/// failure from looking like a full crash to the user.
class SafeErrorWidget extends StatelessWidget {
  const SafeErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Deliberately theme-independent (pure black): this can render *before* or
    // *outside* a valid Theme/MediaQuery (that's often why the original widget
    // failed), so it must not depend on `Theme.of(context)`.
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 32,
        ),
      ),
    );
  }
}
