// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_like_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoLikeModel {

 String get id; String get name; String get username; String? get avatar;@JsonKey(name: 'is_following') bool get isFollowing;
/// Create a copy of VideoLikeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoLikeModelCopyWith<VideoLikeModel> get copyWith => _$VideoLikeModelCopyWithImpl<VideoLikeModel>(this as VideoLikeModel, _$identity);

  /// Serializes this VideoLikeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoLikeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatar,isFollowing);

@override
String toString() {
  return 'VideoLikeModel(id: $id, name: $name, username: $username, avatar: $avatar, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $VideoLikeModelCopyWith<$Res>  {
  factory $VideoLikeModelCopyWith(VideoLikeModel value, $Res Function(VideoLikeModel) _then) = _$VideoLikeModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username, String? avatar,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class _$VideoLikeModelCopyWithImpl<$Res>
    implements $VideoLikeModelCopyWith<$Res> {
  _$VideoLikeModelCopyWithImpl(this._self, this._then);

  final VideoLikeModel _self;
  final $Res Function(VideoLikeModel) _then;

/// Create a copy of VideoLikeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = null,Object? avatar = freezed,Object? isFollowing = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoLikeModel].
extension VideoLikeModelPatterns on VideoLikeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoLikeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoLikeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoLikeModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoLikeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoLikeModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoLikeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String? avatar, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoLikeModel() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.avatar,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String? avatar, @JsonKey(name: 'is_following')  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _VideoLikeModel():
return $default(_that.id,_that.name,_that.username,_that.avatar,_that.isFollowing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username,  String? avatar, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _VideoLikeModel() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.avatar,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoLikeModel implements VideoLikeModel {
  const _VideoLikeModel({required this.id, required this.name, required this.username, this.avatar, @JsonKey(name: 'is_following') this.isFollowing = false});
  factory _VideoLikeModel.fromJson(Map<String, dynamic> json) => _$VideoLikeModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String username;
@override final  String? avatar;
@override@JsonKey(name: 'is_following') final  bool isFollowing;

/// Create a copy of VideoLikeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoLikeModelCopyWith<_VideoLikeModel> get copyWith => __$VideoLikeModelCopyWithImpl<_VideoLikeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoLikeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoLikeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatar,isFollowing);

@override
String toString() {
  return 'VideoLikeModel(id: $id, name: $name, username: $username, avatar: $avatar, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$VideoLikeModelCopyWith<$Res> implements $VideoLikeModelCopyWith<$Res> {
  factory _$VideoLikeModelCopyWith(_VideoLikeModel value, $Res Function(_VideoLikeModel) _then) = __$VideoLikeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username, String? avatar,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class __$VideoLikeModelCopyWithImpl<$Res>
    implements _$VideoLikeModelCopyWith<$Res> {
  __$VideoLikeModelCopyWithImpl(this._self, this._then);

  final _VideoLikeModel _self;
  final $Res Function(_VideoLikeModel) _then;

/// Create a copy of VideoLikeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? avatar = freezed,Object? isFollowing = null,}) {
  return _then(_VideoLikeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
