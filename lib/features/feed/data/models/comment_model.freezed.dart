// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentModel {

 String get id;@JsonKey(name: 'v_id') String get videoId;@JsonKey(name: 'parent_id') String? get parentId;@JsonKey(name: 'caption') String get comment;@JsonKey(name: 'created_at') DateTime get createdAt; Map<String, dynamic>? get account;@JsonKey(name: 'likes') int get likeCount;@JsonKey(name: 'replies') int get replyCount;@JsonKey(name: 'liked') bool get isLiked;
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentModelCopyWith<CommentModel> get copyWith => _$CommentModelCopyWithImpl<CommentModel>(this as CommentModel, _$identity);

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.account, account)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,videoId,parentId,comment,createdAt,const DeepCollectionEquality().hash(account),likeCount,replyCount,isLiked);

@override
String toString() {
  return 'CommentModel(id: $id, videoId: $videoId, parentId: $parentId, comment: $comment, createdAt: $createdAt, account: $account, likeCount: $likeCount, replyCount: $replyCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class $CommentModelCopyWith<$Res>  {
  factory $CommentModelCopyWith(CommentModel value, $Res Function(CommentModel) _then) = _$CommentModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'v_id') String videoId,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'caption') String comment,@JsonKey(name: 'created_at') DateTime createdAt, Map<String, dynamic>? account,@JsonKey(name: 'likes') int likeCount,@JsonKey(name: 'replies') int replyCount,@JsonKey(name: 'liked') bool isLiked
});




}
/// @nodoc
class _$CommentModelCopyWithImpl<$Res>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._self, this._then);

  final CommentModel _self;
  final $Res Function(CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? videoId = null,Object? parentId = freezed,Object? comment = null,Object? createdAt = null,Object? account = freezed,Object? likeCount = null,Object? replyCount = null,Object? isLiked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentModel].
extension CommentModelPatterns on CommentModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentModel value)  $default,){
final _that = this;
switch (_that) {
case _CommentModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'v_id')  String videoId, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'caption')  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? account, @JsonKey(name: 'likes')  int likeCount, @JsonKey(name: 'replies')  int replyCount, @JsonKey(name: 'liked')  bool isLiked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.videoId,_that.parentId,_that.comment,_that.createdAt,_that.account,_that.likeCount,_that.replyCount,_that.isLiked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'v_id')  String videoId, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'caption')  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? account, @JsonKey(name: 'likes')  int likeCount, @JsonKey(name: 'replies')  int replyCount, @JsonKey(name: 'liked')  bool isLiked)  $default,) {final _that = this;
switch (_that) {
case _CommentModel():
return $default(_that.id,_that.videoId,_that.parentId,_that.comment,_that.createdAt,_that.account,_that.likeCount,_that.replyCount,_that.isLiked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'v_id')  String videoId, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'caption')  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? account, @JsonKey(name: 'likes')  int likeCount, @JsonKey(name: 'replies')  int replyCount, @JsonKey(name: 'liked')  bool isLiked)?  $default,) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.videoId,_that.parentId,_that.comment,_that.createdAt,_that.account,_that.likeCount,_that.replyCount,_that.isLiked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentModel implements CommentModel {
  const _CommentModel({required this.id, @JsonKey(name: 'v_id') required this.videoId, @JsonKey(name: 'parent_id') this.parentId, @JsonKey(name: 'caption') required this.comment, @JsonKey(name: 'created_at') required this.createdAt, final  Map<String, dynamic>? account, @JsonKey(name: 'likes') this.likeCount = 0, @JsonKey(name: 'replies') this.replyCount = 0, @JsonKey(name: 'liked') this.isLiked = false}): _account = account;
  factory _CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'v_id') final  String videoId;
@override@JsonKey(name: 'parent_id') final  String? parentId;
@override@JsonKey(name: 'caption') final  String comment;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
 final  Map<String, dynamic>? _account;
@override Map<String, dynamic>? get account {
  final value = _account;
  if (value == null) return null;
  if (_account is EqualUnmodifiableMapView) return _account;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'likes') final  int likeCount;
@override@JsonKey(name: 'replies') final  int replyCount;
@override@JsonKey(name: 'liked') final  bool isLiked;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentModelCopyWith<_CommentModel> get copyWith => __$CommentModelCopyWithImpl<_CommentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._account, _account)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,videoId,parentId,comment,createdAt,const DeepCollectionEquality().hash(_account),likeCount,replyCount,isLiked);

@override
String toString() {
  return 'CommentModel(id: $id, videoId: $videoId, parentId: $parentId, comment: $comment, createdAt: $createdAt, account: $account, likeCount: $likeCount, replyCount: $replyCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class _$CommentModelCopyWith<$Res> implements $CommentModelCopyWith<$Res> {
  factory _$CommentModelCopyWith(_CommentModel value, $Res Function(_CommentModel) _then) = __$CommentModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'v_id') String videoId,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'caption') String comment,@JsonKey(name: 'created_at') DateTime createdAt, Map<String, dynamic>? account,@JsonKey(name: 'likes') int likeCount,@JsonKey(name: 'replies') int replyCount,@JsonKey(name: 'liked') bool isLiked
});




}
/// @nodoc
class __$CommentModelCopyWithImpl<$Res>
    implements _$CommentModelCopyWith<$Res> {
  __$CommentModelCopyWithImpl(this._self, this._then);

  final _CommentModel _self;
  final $Res Function(_CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? videoId = null,Object? parentId = freezed,Object? comment = null,Object? createdAt = null,Object? account = freezed,Object? likeCount = null,Object? replyCount = null,Object? isLiked = null,}) {
  return _then(_CommentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: freezed == account ? _self._account : account // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
