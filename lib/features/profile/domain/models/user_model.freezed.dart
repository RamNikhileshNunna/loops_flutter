// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get username; String? get name; String? get avatar;@JsonKey(name: 'post_count') int get postCount;@JsonKey(name: 'follower_count') int get followerCount;@JsonKey(name: 'following_count') int get followingCount;@JsonKey(name: 'likes_count') int get likesCount; String? get bio; String? get link;@JsonKey(name: 'is_owner') bool get isOwner;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.link, link) || other.link == link)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,avatar,postCount,followerCount,followingCount,likesCount,bio,link,isOwner);

@override
String toString() {
  return 'UserModel(id: $id, username: $username, name: $name, avatar: $avatar, postCount: $postCount, followerCount: $followerCount, followingCount: $followingCount, likesCount: $likesCount, bio: $bio, link: $link, isOwner: $isOwner)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? name, String? avatar,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'follower_count') int followerCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'likes_count') int likesCount, String? bio, String? link,@JsonKey(name: 'is_owner') bool isOwner
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? avatar = freezed,Object? postCount = null,Object? followerCount = null,Object? followingCount = null,Object? likesCount = null,Object? bio = freezed,Object? link = freezed,Object? isOwner = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? avatar, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'follower_count')  int followerCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'likes_count')  int likesCount,  String? bio,  String? link, @JsonKey(name: 'is_owner')  bool isOwner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.avatar,_that.postCount,_that.followerCount,_that.followingCount,_that.likesCount,_that.bio,_that.link,_that.isOwner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? name,  String? avatar, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'follower_count')  int followerCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'likes_count')  int likesCount,  String? bio,  String? link, @JsonKey(name: 'is_owner')  bool isOwner)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.username,_that.name,_that.avatar,_that.postCount,_that.followerCount,_that.followingCount,_that.likesCount,_that.bio,_that.link,_that.isOwner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? name,  String? avatar, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'follower_count')  int followerCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'likes_count')  int likesCount,  String? bio,  String? link, @JsonKey(name: 'is_owner')  bool isOwner)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.avatar,_that.postCount,_that.followerCount,_that.followingCount,_that.likesCount,_that.bio,_that.link,_that.isOwner);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.username, this.name, this.avatar, @JsonKey(name: 'post_count') this.postCount = 0, @JsonKey(name: 'follower_count') this.followerCount = 0, @JsonKey(name: 'following_count') this.followingCount = 0, @JsonKey(name: 'likes_count') this.likesCount = 0, this.bio, this.link, @JsonKey(name: 'is_owner') this.isOwner = false});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? name;
@override final  String? avatar;
@override@JsonKey(name: 'post_count') final  int postCount;
@override@JsonKey(name: 'follower_count') final  int followerCount;
@override@JsonKey(name: 'following_count') final  int followingCount;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override final  String? bio;
@override final  String? link;
@override@JsonKey(name: 'is_owner') final  bool isOwner;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.link, link) || other.link == link)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,avatar,postCount,followerCount,followingCount,likesCount,bio,link,isOwner);

@override
String toString() {
  return 'UserModel(id: $id, username: $username, name: $name, avatar: $avatar, postCount: $postCount, followerCount: $followerCount, followingCount: $followingCount, likesCount: $likesCount, bio: $bio, link: $link, isOwner: $isOwner)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? name, String? avatar,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'follower_count') int followerCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'likes_count') int likesCount, String? bio, String? link,@JsonKey(name: 'is_owner') bool isOwner
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? avatar = freezed,Object? postCount = null,Object? followerCount = null,Object? followingCount = null,Object? likesCount = null,Object? bio = freezed,Object? link = freezed,Object? isOwner = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
