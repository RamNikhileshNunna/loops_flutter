import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

import 'dart:io';
import 'package:video_compress/video_compress.dart';

final videoUploadRepositoryProvider = Provider<VideoUploadRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoUploadRepository(apiClient);
});

class VideoUploadRepository {
  VideoUploadRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Uploads a video file to loops.video. Returns true if server accepts it.
  Future<bool> uploadVideo({
    required XFile file,
    String? caption,
    void Function(int sent, int total)? onProgress,
  }) async {
    File fileToUpload = File(file.path);
    String mimeType = _detectSubtype(file.path);
    bool isCompressed = false;

    try {
      // Compress video to avoid 413 Payload Too Large
      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        fileToUpload = info.file!;
        mimeType = 'mp4'; // video_compress outputs mp4
        isCompressed = true;
      }
    } catch (e) {
      // If compression fails, try uploading original
      AppLogger.error('Compression failed', e);
    }

    try {
      final multipartFile = await MultipartFile.fromFile(
        fileToUpload.path,
        filename: 'video.mp4', // Loops likely expects a filename
        contentType: MediaType('video', mimeType),
      );

      // API expects 'video' and 'description'.
      final form = FormData.fromMap({
        'description': caption ?? '',
        'video': multipartFile,
      });

      await _apiClient.ensureCsrfCookie();
      final res = await _apiClient.post(
        'api/v1/studio/upload',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
          followRedirects: true,
        ),
        onSendProgress: onProgress,
      );

      if (res.statusCode == null ||
          res.statusCode! < 200 ||
          res.statusCode! >= 300) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Upload failed with status ${res.statusCode}',
        );
      }

      return true;
    } finally {
      // Clean up compressed file if we created one
      if (isCompressed) {
        // VideoCompress cleans up its own cache when asked,
        // or we can just leave it to the lib's cache management.
        // But explicitly deleting the file we obtained is safer for storage.
        // However, VideoCompress doc says `deleteAllCache`.
        // We will just leave it effectively cached for now or call deleteAllCache rarely.
        // Actually, let's call deleteAllCache to be safe and clean.
        await VideoCompress.deleteAllCache();
      }
    }
  }

  String _detectSubtype(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.mp4')) return 'mp4';
    if (ext.endsWith('.mov')) return 'quicktime';
    if (ext.endsWith('.mkv')) return 'x-matroska';
    if (ext.endsWith('.avi')) return 'x-msvideo';
    return 'mp4';
  }
}
