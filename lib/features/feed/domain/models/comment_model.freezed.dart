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

 String get id; UserModel get account; String get caption;// Acts as the comment text
@JsonKey(name: 'created_at') String get createdAt; int get likes; bool get liked; int get replies;@JsonKey(name: 'is_owner') bool get isOwner;@JsonKey(name: 'p_id') String? get pId;
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentModelCopyWith<CommentModel> get copyWith => _$CommentModelCopyWithImpl<CommentModel>(this as CommentModel, _$identity);

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.account, account) || other.account == account)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.liked, liked) || other.liked == liked)&&(identical(other.replies, replies) || other.replies == replies)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.pId, pId) || other.pId == pId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,account,caption,createdAt,likes,liked,replies,isOwner,pId);

@override
String toString() {
  return 'CommentModel(id: $id, account: $account, caption: $caption, createdAt: $createdAt, likes: $likes, liked: $liked, replies: $replies, isOwner: $isOwner, pId: $pId)';
}


}

/// @nodoc
abstract mixin class $CommentModelCopyWith<$Res>  {
  factory $CommentModelCopyWith(CommentModel value, $Res Function(CommentModel) _then) = _$CommentModelCopyWithImpl;
@useResult
$Res call({
 String id, UserModel account, String caption,@JsonKey(name: 'created_at') String createdAt, int likes, bool liked, int replies,@JsonKey(name: 'is_owner') bool isOwner,@JsonKey(name: 'p_id') String? pId
});


$UserModelCopyWith<$Res> get account;

}
/// @nodoc
class _$CommentModelCopyWithImpl<$Res>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._self, this._then);

  final CommentModel _self;
  final $Res Function(CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? account = null,Object? caption = null,Object? createdAt = null,Object? likes = null,Object? liked = null,Object? replies = null,Object? isOwner = null,Object? pId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserModel,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,liked: null == liked ? _self.liked : liked // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as int,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,pId: freezed == pId ? _self.pId : pId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get account {
  
  return $UserModelCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserModel account,  String caption, @JsonKey(name: 'created_at')  String createdAt,  int likes,  bool liked,  int replies, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'p_id')  String? pId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.account,_that.caption,_that.createdAt,_that.likes,_that.liked,_that.replies,_that.isOwner,_that.pId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserModel account,  String caption, @JsonKey(name: 'created_at')  String createdAt,  int likes,  bool liked,  int replies, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'p_id')  String? pId)  $default,) {final _that = this;
switch (_that) {
case _CommentModel():
return $default(_that.id,_that.account,_that.caption,_that.createdAt,_that.likes,_that.liked,_that.replies,_that.isOwner,_that.pId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserModel account,  String caption, @JsonKey(name: 'created_at')  String createdAt,  int likes,  bool liked,  int replies, @JsonKey(name: 'is_owner')  bool isOwner, @JsonKey(name: 'p_id')  String? pId)?  $default,) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.account,_that.caption,_that.createdAt,_that.likes,_that.liked,_that.replies,_that.isOwner,_that.pId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentModel implements CommentModel {
  const _CommentModel({required this.id, required this.account, required this.caption, @JsonKey(name: 'created_at') required this.createdAt, this.likes = 0, this.liked = false, this.replies = 0, @JsonKey(name: 'is_owner') this.isOwner = false, @JsonKey(name: 'p_id') this.pId});
  factory _CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);

@override final  String id;
@override final  UserModel account;
@override final  String caption;
// Acts as the comment text
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey() final  int likes;
@override@JsonKey() final  bool liked;
@override@JsonKey() final  int replies;
@override@JsonKey(name: 'is_owner') final  bool isOwner;
@override@JsonKey(name: 'p_id') final  String? pId;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.account, account) || other.account == account)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.liked, liked) || other.liked == liked)&&(identical(other.replies, replies) || other.replies == replies)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.pId, pId) || other.pId == pId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,account,caption,createdAt,likes,liked,replies,isOwner,pId);

@override
String toString() {
  return 'CommentModel(id: $id, account: $account, caption: $caption, createdAt: $createdAt, likes: $likes, liked: $liked, replies: $replies, isOwner: $isOwner, pId: $pId)';
}


}

/// @nodoc
abstract mixin class _$CommentModelCopyWith<$Res> implements $CommentModelCopyWith<$Res> {
  factory _$CommentModelCopyWith(_CommentModel value, $Res Function(_CommentModel) _then) = __$CommentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, UserModel account, String caption,@JsonKey(name: 'created_at') String createdAt, int likes, bool liked, int replies,@JsonKey(name: 'is_owner') bool isOwner,@JsonKey(name: 'p_id') String? pId
});


@override $UserModelCopyWith<$Res> get account;

}
/// @nodoc
class __$CommentModelCopyWithImpl<$Res>
    implements _$CommentModelCopyWith<$Res> {
  __$CommentModelCopyWithImpl(this._self, this._then);

  final _CommentModel _self;
  final $Res Function(_CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? account = null,Object? caption = null,Object? createdAt = null,Object? likes = null,Object? liked = null,Object? replies = null,Object? isOwner = null,Object? pId = freezed,}) {
  return _then(_CommentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserModel,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,liked: null == liked ? _self.liked : liked // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as int,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,pId: freezed == pId ? _self.pId : pId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get account {
  
  return $UserModelCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
