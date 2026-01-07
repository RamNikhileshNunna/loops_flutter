// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagModel _$TagModelFromJson(Map<String, dynamic> json) => _TagModel(
  name: json['name'] as String,
  views: (json['views'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TagModelToJson(_TagModel instance) => <String, dynamic>{
  'name': instance.name,
  'views': instance.views,
  'count': instance.count,
};
