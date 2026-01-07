import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    String? name,
    String? avatar,
    @Default(0) @JsonKey(name: 'post_count') int postCount,
    @Default(0) @JsonKey(name: 'follower_count') int followerCount,
    @Default(0) @JsonKey(name: 'following_count') int followingCount,
    @Default(0) @JsonKey(name: 'likes_count') int likesCount,
    String? bio,
    String? link,
    @Default(false) @JsonKey(name: 'is_owner') bool isOwner,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
