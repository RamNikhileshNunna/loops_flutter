class NotificationModel {
  final String id;
  final String type;
  final String? actorId;
  final String? actorName;
  final String? actorAvatarUrl;
  final String? targetTitle;
  final String? videoId;
  final DateTime? createdAt;
  final String? videoThumbnailUrl;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    this.actorId,
    this.actorName,
    this.actorAvatarUrl,
    this.targetTitle,
    this.videoId,
    this.createdAt,
    this.videoThumbnailUrl,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    final target = json['target'] as Map<String, dynamic>?;
    final createdAtRaw = json['created_at']?.toString();
    final readAtRaw = json['read_at']?.toString();

    String? str(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty || s == 'null') ? null : s;
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'notification',
      actorId: str(actor?['id']) ?? str(json['actor_id']),
      actorName:
          actor?['username']?.toString() ?? json['actor_name']?.toString(),
      actorAvatarUrl: actor?['avatar']?.toString(),
      targetTitle:
          target?['title']?.toString() ?? json['target_title']?.toString(),
      videoId: str(json['video_id']) ??
          str(target?['id']) ??
          str(json['target_id']),
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      videoThumbnailUrl: json['video_thumbnail']?.toString(),
      isRead: readAtRaw != null && readAtRaw.isNotEmpty,
    );
  }
}
