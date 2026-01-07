// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => _VideoModel(
  id: json['id'] as String,
  media: MediaModel.fromJson(json['media'] as Map<String, dynamic>),
  account: UserModel.fromJson(json['account'] as Map<String, dynamic>),
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  hasLiked: json['has_liked'] as bool? ?? false,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  shares: (json['shares'] as num?)?.toInt() ?? 0,
  caption: json['caption'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  permissions: json['permissions'] == null
      ? null
      : VideoPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  meta: json['meta'] == null
      ? null
      : VideoMeta.fromJson(json['meta'] as Map<String, dynamic>),
  isSensitive: json['is_sensitive'] as bool? ?? false,
);

Map<String, dynamic> _$VideoModelToJson(_VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media': instance.media,
      'account': instance.account,
      'likes': instance.likes,
      'has_liked': instance.hasLiked,
      'comments': instance.comments,
      'shares': instance.shares,
      'caption': instance.caption,
      'tags': instance.tags,
      'permissions': instance.permissions,
      'meta': instance.meta,
      'is_sensitive': instance.isSensitive,
    };

_MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => _MediaModel(
  srcUrl: _readSrcUrl(json, 'src_url') as String,
  thumbnailUrl: _readThumbnailUrl(json, 'thumbnail_url') as String?,
  altText: json['alt_text'] as String?,
);

Map<String, dynamic> _$MediaModelToJson(_MediaModel instance) =>
    <String, dynamic>{
      'src_url': instance.srcUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'alt_text': instance.altText,
    };

_VideoPermissions _$VideoPermissionsFromJson(Map<String, dynamic> json) =>
    _VideoPermissions(canComment: json['can_comment'] as bool? ?? true);

Map<String, dynamic> _$VideoPermissionsToJson(_VideoPermissions instance) =>
    <String, dynamic>{'can_comment': instance.canComment};

_VideoMeta _$VideoMetaFromJson(Map<String, dynamic> json) => _VideoMeta(
  containsAi: json['contains_ai'] as bool? ?? false,
  containsAd: json['contains_ad'] as bool? ?? false,
);

Map<String, dynamic> _$VideoMetaToJson(_VideoMeta instance) =>
    <String, dynamic>{
      'contains_ai': instance.containsAi,
      'contains_ad': instance.containsAd,
    };
