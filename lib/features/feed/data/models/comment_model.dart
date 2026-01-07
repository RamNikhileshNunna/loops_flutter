import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,

    @JsonKey(name: 'v_id') required String videoId,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'caption') required String comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    Map<String, dynamic>? account,
    @Default(0) @JsonKey(name: 'likes') int likeCount,
    @Default(0) @JsonKey(name: 'replies') int replyCount,
    @Default(false) @JsonKey(name: 'liked') bool isLiked,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
