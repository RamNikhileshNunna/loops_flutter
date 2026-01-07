// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  username: json['username'] as String,
  name: json['name'] as String?,
  avatar: json['avatar'] as String?,
  postCount: (json['post_count'] as num?)?.toInt() ?? 0,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  bio: json['bio'] as String?,
  link: json['link'] as String?,
  isOwner: json['is_owner'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar': instance.avatar,
      'post_count': instance.postCount,
      'follower_count': instance.followerCount,
      'following_count': instance.followingCount,
      'likes_count': instance.likesCount,
      'bio': instance.bio,
      'link': instance.link,
      'is_owner': instance.isOwner,
    };
