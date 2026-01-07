class NotificationModel {
  final String id;
  final String type;
  final String? actorName;
  final String? actorAvatarUrl;
  final String? targetTitle;
  final DateTime? createdAt;
  final String? videoThumbnailUrl;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    this.actorName,
    this.actorAvatarUrl,
    this.targetTitle,
    this.createdAt,
    this.videoThumbnailUrl,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    final createdAtRaw = json['created_at']?.toString();
    final readAtRaw = json['read_at']?.toString();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'notification',
      actorName:
          actor?['username']?.toString() ?? json['actor_name']?.toString(),
      actorAvatarUrl: actor?['avatar']?.toString(),
      targetTitle:
          json['target']?['title']?.toString() ??
          json['target_title']?.toString(),
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      videoThumbnailUrl: json['video_thumbnail']?.toString(),
      isRead: readAtRaw != null && readAtRaw.isNotEmpty,
    );
  }
}
