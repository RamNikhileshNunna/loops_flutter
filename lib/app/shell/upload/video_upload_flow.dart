import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:loops_flutter/app/shell/upload/upload_progress_dialog.dart';
import 'package:loops_flutter/features/feed/data/repositories/video_upload_repository_impl.dart';

/// Runs the end-to-end "upload a video" flow, invoked from the upload buttons
/// in the bottom nav (phone) and the side rail (desktop).
///
/// Steps:
///   1. Pick a video from the gallery (no-op if the user cancels).
///   2. Prompt for an optional caption.
///   3. Show a non-blocking [UploadProgressDialog] and stream progress into it.
///   4. Pop the dialog and surface a success / failure SnackBar.
///
/// Takes [context] and [ref] from the caller (the shell's [ConsumerState]) so
/// the flow can live outside the widget and keep the shell lean. Every step
/// re-checks `context.mounted` because each `await` yields control and the
/// widget could be disposed in between (e.g. the user navigates away).
Future<void> startVideoUpload(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  // Capture the messenger up front: it stays valid across awaits even if the
  // originating BuildContext is later unmounted.
  final messenger = ScaffoldMessenger.of(context);

  // 1. Pick a video.
  final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
  if (picked == null) return; // user cancelled the picker
  if (!context.mounted) return;

  // 2. Ask for an optional caption (null/"" => upload without one).
  final String? caption = await showDialog<String>(
    context: context,
    builder: (ctx) {
      final ctrl = TextEditingController();
      return AlertDialog(
        title: const Text('Add a caption'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Say something about your video…',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Skip => null caption
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;

  final repo = ref.read(videoUploadRepositoryProvider);
  // Progress is shared between the upload callback and the dialog.
  final progress = ValueNotifier<double>(0.0);

  // 3. Show the progress dialog without awaiting it — the upload runs in
  // parallel and we dismiss the dialog ourselves once it's done.
  unawaited(
    showDialog(
      context: context,
      barrierDismissible: false, // can't be dismissed mid-upload
      builder: (_) => UploadProgressDialog(progress: progress),
    ),
  );

  // 4. Perform the upload, then close the dialog and report the outcome.
  try {
    await repo.uploadVideo(
      file: picked,
      caption: caption,
      onProgress: (sent, total) {
        if (total > 0) progress.value = sent / total;
      },
    );
    if (context.mounted) {
      Navigator.of(context).pop(); // dismiss progress dialog
      messenger.showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      // Prefer the server's message when the failure is an HTTP error.
      String msg = 'Upload failed';
      if (e is DioException) {
        msg += ': ${e.response?.data?['message'] ?? e.message}';
      } else {
        msg += ': $e';
      }
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
