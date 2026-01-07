// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoLikeModel _$VideoLikeModelFromJson(Map<String, dynamic> json) =>
    _VideoLikeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
    );

Map<String, dynamic> _$VideoLikeModelToJson(_VideoLikeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'avatar': instance.avatar,
      'is_following': instance.isFollowing,
    };
