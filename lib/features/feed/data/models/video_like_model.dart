import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_like_model.freezed.dart';
part 'video_like_model.g.dart';

@freezed
abstract class VideoLikeModel with _$VideoLikeModel {
  const factory VideoLikeModel({
    required String id,
    required String name,
    required String username,
    String? avatar,
    @Default(false) @JsonKey(name: 'is_following') bool isFollowing,
  }) = _VideoLikeModel;

  factory VideoLikeModel.fromJson(Map<String, dynamic> json) =>
      _$VideoLikeModelFromJson(json);
}
