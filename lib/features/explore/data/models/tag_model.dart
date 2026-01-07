import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
abstract class TagModel with _$TagModel {
  const factory TagModel({
    required String name,
    @Default(0) @JsonKey(name: 'views') int views,
    @Default(0) @JsonKey(name: 'count') int count,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}
