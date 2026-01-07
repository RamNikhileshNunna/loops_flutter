// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      id: json['id'] as String,
      account: UserModel.fromJson(json['account'] as Map<String, dynamic>),
      caption: json['caption'] as String,
      createdAt: json['created_at'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      liked: json['liked'] as bool? ?? false,
      replies: (json['replies'] as num?)?.toInt() ?? 0,
      isOwner: json['is_owner'] as bool? ?? false,
      pId: json['p_id'] as String?,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account': instance.account,
      'caption': instance.caption,
      'created_at': instance.createdAt,
      'likes': instance.likes,
      'liked': instance.liked,
      'replies': instance.replies,
      'is_owner': instance.isOwner,
      'p_id': instance.pId,
    };
