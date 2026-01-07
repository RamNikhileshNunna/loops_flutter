import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

// ignore_for_file: invalid_annotation_target

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    required UserModel account,
    required String caption, // Acts as the comment text
    @JsonKey(name: 'created_at') required String createdAt,
    @Default(0) int likes,
    @Default(false) bool liked,
    @Default(0) int replies,
    @Default(false) @JsonKey(name: 'is_owner') bool isOwner,
    @JsonKey(name: 'p_id') String? pId, // Parent ID if it's a reply
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
