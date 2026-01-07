// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      id: json['id'] as String,
      videoId: json['v_id'] as String,
      parentId: json['parent_id'] as String?,
      comment: json['caption'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      account: json['account'] as Map<String, dynamic>?,
      likeCount: (json['likes'] as num?)?.toInt() ?? 0,
      replyCount: (json['replies'] as num?)?.toInt() ?? 0,
      isLiked: json['liked'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v_id': instance.videoId,
      'parent_id': instance.parentId,
      'caption': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'account': instance.account,
      'likes': instance.likeCount,
      'replies': instance.replyCount,
      'liked': instance.isLiked,
    };
