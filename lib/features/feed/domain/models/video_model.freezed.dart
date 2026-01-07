// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoModel {

 String get id; MediaModel get media; UserModel get account; int get likes;@JsonKey(name: 'has_liked') bool get hasLiked; int get comments; int get shares; String? get caption; List<String> get tags;// Mentions can be added later if structure is complex
 VideoPermissions? get permissions; VideoMeta? get meta;@JsonKey(name: 'is_sensitive') bool get isSensitive;
/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoModelCopyWith<VideoModel> get copyWith => _$VideoModelCopyWithImpl<VideoModel>(this as VideoModel, _$identity);

  /// Serializes this VideoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.media, media) || other.media == media)&&(identical(other.account, account) || other.account == account)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.hasLiked, hasLiked) || other.hasLiked == hasLiked)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,media,account,likes,hasLiked,comments,shares,caption,const DeepCollectionEquality().hash(tags),permissions,meta,isSensitive);

@override
String toString() {
  return 'VideoModel(id: $id, media: $media, account: $account, likes: $likes, hasLiked: $hasLiked, comments: $comments, shares: $shares, caption: $caption, tags: $tags, permissions: $permissions, meta: $meta, isSensitive: $isSensitive)';
}


}

/// @nodoc
abstract mixin class $VideoModelCopyWith<$Res>  {
  factory $VideoModelCopyWith(VideoModel value, $Res Function(VideoModel) _then) = _$VideoModelCopyWithImpl;
@useResult
$Res call({
 String id, MediaModel media, UserModel account, int likes,@JsonKey(name: 'has_liked') bool hasLiked, int comments, int shares, String? caption, List<String> tags, VideoPermissions? permissions, VideoMeta? meta,@JsonKey(name: 'is_sensitive') bool isSensitive
});


$MediaModelCopyWith<$Res> get media;$UserModelCopyWith<$Res> get account;$VideoPermissionsCopyWith<$Res>? get permissions;$VideoMetaCopyWith<$Res>? get meta;

}
/// @nodoc
class _$VideoModelCopyWithImpl<$Res>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._self, this._then);

  final VideoModel _self;
  final $Res Function(VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? media = null,Object? account = null,Object? likes = null,Object? hasLiked = null,Object? comments = null,Object? shares = null,Object? caption = freezed,Object? tags = null,Object? permissions = freezed,Object? meta = freezed,Object? isSensitive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaModel,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserModel,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,hasLiked: null == hasLiked ? _self.hasLiked : hasLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as VideoPermissions?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as VideoMeta?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaModelCopyWith<$Res> get media {
  
  return $MediaModelCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get account {
  
  return $UserModelCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoPermissionsCopyWith<$Res>? get permissions {
    if (_self.permissions == null) {
    return null;
  }

  return $VideoPermissionsCopyWith<$Res>(_self.permissions!, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoMetaCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $VideoMetaCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoModel].
extension VideoModelPatterns on VideoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MediaModel media,  UserModel account,  int likes, @JsonKey(name: 'has_liked')  bool hasLiked,  int comments,  int shares,  String? caption,  List<String> tags,  VideoPermissions? permissions,  VideoMeta? meta, @JsonKey(name: 'is_sensitive')  bool isSensitive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.media,_that.account,_that.likes,_that.hasLiked,_that.comments,_that.shares,_that.caption,_that.tags,_that.permissions,_that.meta,_that.isSensitive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MediaModel media,  UserModel account,  int likes, @JsonKey(name: 'has_liked')  bool hasLiked,  int comments,  int shares,  String? caption,  List<String> tags,  VideoPermissions? permissions,  VideoMeta? meta, @JsonKey(name: 'is_sensitive')  bool isSensitive)  $default,) {final _that = this;
switch (_that) {
case _VideoModel():
return $default(_that.id,_that.media,_that.account,_that.likes,_that.hasLiked,_that.comments,_that.shares,_that.caption,_that.tags,_that.permissions,_that.meta,_that.isSensitive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MediaModel media,  UserModel account,  int likes, @JsonKey(name: 'has_liked')  bool hasLiked,  int comments,  int shares,  String? caption,  List<String> tags,  VideoPermissions? permissions,  VideoMeta? meta, @JsonKey(name: 'is_sensitive')  bool isSensitive)?  $default,) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.media,_that.account,_that.likes,_that.hasLiked,_that.comments,_that.shares,_that.caption,_that.tags,_that.permissions,_that.meta,_that.isSensitive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoModel implements VideoModel {
  const _VideoModel({required this.id, required this.media, required this.account, this.likes = 0, @JsonKey(name: 'has_liked') this.hasLiked = false, this.comments = 0, this.shares = 0, this.caption, final  List<String> tags = const [], this.permissions, this.meta, @JsonKey(name: 'is_sensitive') this.isSensitive = false}): _tags = tags;
  factory _VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

@override final  String id;
@override final  MediaModel media;
@override final  UserModel account;
@override@JsonKey() final  int likes;
@override@JsonKey(name: 'has_liked') final  bool hasLiked;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int shares;
@override final  String? caption;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// Mentions can be added later if structure is complex
@override final  VideoPermissions? permissions;
@override final  VideoMeta? meta;
@override@JsonKey(name: 'is_sensitive') final  bool isSensitive;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoModelCopyWith<_VideoModel> get copyWith => __$VideoModelCopyWithImpl<_VideoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.media, media) || other.media == media)&&(identical(other.account, account) || other.account == account)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.hasLiked, hasLiked) || other.hasLiked == hasLiked)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,media,account,likes,hasLiked,comments,shares,caption,const DeepCollectionEquality().hash(_tags),permissions,meta,isSensitive);

@override
String toString() {
  return 'VideoModel(id: $id, media: $media, account: $account, likes: $likes, hasLiked: $hasLiked, comments: $comments, shares: $shares, caption: $caption, tags: $tags, permissions: $permissions, meta: $meta, isSensitive: $isSensitive)';
}


}

/// @nodoc
abstract mixin class _$VideoModelCopyWith<$Res> implements $VideoModelCopyWith<$Res> {
  factory _$VideoModelCopyWith(_VideoModel value, $Res Function(_VideoModel) _then) = __$VideoModelCopyWithImpl;
@override @useResult
$Res call({
 String id, MediaModel media, UserModel account, int likes,@JsonKey(name: 'has_liked') bool hasLiked, int comments, int shares, String? caption, List<String> tags, VideoPermissions? permissions, VideoMeta? meta,@JsonKey(name: 'is_sensitive') bool isSensitive
});


@override $MediaModelCopyWith<$Res> get media;@override $UserModelCopyWith<$Res> get account;@override $VideoPermissionsCopyWith<$Res>? get permissions;@override $VideoMetaCopyWith<$Res>? get meta;

}
/// @nodoc
class __$VideoModelCopyWithImpl<$Res>
    implements _$VideoModelCopyWith<$Res> {
  __$VideoModelCopyWithImpl(this._self, this._then);

  final _VideoModel _self;
  final $Res Function(_VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? media = null,Object? account = null,Object? likes = null,Object? hasLiked = null,Object? comments = null,Object? shares = null,Object? caption = freezed,Object? tags = null,Object? permissions = freezed,Object? meta = freezed,Object? isSensitive = null,}) {
  return _then(_VideoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaModel,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserModel,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,hasLiked: null == hasLiked ? _self.hasLiked : hasLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as VideoPermissions?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as VideoMeta?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaModelCopyWith<$Res> get media {
  
  return $MediaModelCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get account {
  
  return $UserModelCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoPermissionsCopyWith<$Res>? get permissions {
    if (_self.permissions == null) {
    return null;
  }

  return $VideoPermissionsCopyWith<$Res>(_self.permissions!, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoMetaCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $VideoMetaCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$MediaModel {

@JsonKey(name: 'src_url', readValue: _readSrcUrl) String get srcUrl;@JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl) String? get thumbnailUrl;@JsonKey(name: 'alt_text') String? get altText;
/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaModelCopyWith<MediaModel> get copyWith => _$MediaModelCopyWithImpl<MediaModel>(this as MediaModel, _$identity);

  /// Serializes this MediaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaModel&&(identical(other.srcUrl, srcUrl) || other.srcUrl == srcUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,srcUrl,thumbnailUrl,altText);

@override
String toString() {
  return 'MediaModel(srcUrl: $srcUrl, thumbnailUrl: $thumbnailUrl, altText: $altText)';
}


}

/// @nodoc
abstract mixin class $MediaModelCopyWith<$Res>  {
  factory $MediaModelCopyWith(MediaModel value, $Res Function(MediaModel) _then) = _$MediaModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'src_url', readValue: _readSrcUrl) String srcUrl,@JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl) String? thumbnailUrl,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class _$MediaModelCopyWithImpl<$Res>
    implements $MediaModelCopyWith<$Res> {
  _$MediaModelCopyWithImpl(this._self, this._then);

  final MediaModel _self;
  final $Res Function(MediaModel) _then;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? srcUrl = null,Object? thumbnailUrl = freezed,Object? altText = freezed,}) {
  return _then(_self.copyWith(
srcUrl: null == srcUrl ? _self.srcUrl : srcUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaModel].
extension MediaModelPatterns on MediaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaModel value)  $default,){
final _that = this;
switch (_that) {
case _MediaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaModel value)?  $default,){
final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'src_url', readValue: _readSrcUrl)  String srcUrl, @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)  String? thumbnailUrl, @JsonKey(name: 'alt_text')  String? altText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that.srcUrl,_that.thumbnailUrl,_that.altText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'src_url', readValue: _readSrcUrl)  String srcUrl, @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)  String? thumbnailUrl, @JsonKey(name: 'alt_text')  String? altText)  $default,) {final _that = this;
switch (_that) {
case _MediaModel():
return $default(_that.srcUrl,_that.thumbnailUrl,_that.altText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'src_url', readValue: _readSrcUrl)  String srcUrl, @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)  String? thumbnailUrl, @JsonKey(name: 'alt_text')  String? altText)?  $default,) {final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that.srcUrl,_that.thumbnailUrl,_that.altText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaModel implements MediaModel {
  const _MediaModel({@JsonKey(name: 'src_url', readValue: _readSrcUrl) required this.srcUrl, @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl) this.thumbnailUrl, @JsonKey(name: 'alt_text') this.altText});
  factory _MediaModel.fromJson(Map<String, dynamic> json) => _$MediaModelFromJson(json);

@override@JsonKey(name: 'src_url', readValue: _readSrcUrl) final  String srcUrl;
@override@JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl) final  String? thumbnailUrl;
@override@JsonKey(name: 'alt_text') final  String? altText;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaModelCopyWith<_MediaModel> get copyWith => __$MediaModelCopyWithImpl<_MediaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaModel&&(identical(other.srcUrl, srcUrl) || other.srcUrl == srcUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,srcUrl,thumbnailUrl,altText);

@override
String toString() {
  return 'MediaModel(srcUrl: $srcUrl, thumbnailUrl: $thumbnailUrl, altText: $altText)';
}


}

/// @nodoc
abstract mixin class _$MediaModelCopyWith<$Res> implements $MediaModelCopyWith<$Res> {
  factory _$MediaModelCopyWith(_MediaModel value, $Res Function(_MediaModel) _then) = __$MediaModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'src_url', readValue: _readSrcUrl) String srcUrl,@JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl) String? thumbnailUrl,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class __$MediaModelCopyWithImpl<$Res>
    implements _$MediaModelCopyWith<$Res> {
  __$MediaModelCopyWithImpl(this._self, this._then);

  final _MediaModel _self;
  final $Res Function(_MediaModel) _then;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? srcUrl = null,Object? thumbnailUrl = freezed,Object? altText = freezed,}) {
  return _then(_MediaModel(
srcUrl: null == srcUrl ? _self.srcUrl : srcUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VideoPermissions {

@JsonKey(name: 'can_comment') bool get canComment;
/// Create a copy of VideoPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoPermissionsCopyWith<VideoPermissions> get copyWith => _$VideoPermissionsCopyWithImpl<VideoPermissions>(this as VideoPermissions, _$identity);

  /// Serializes this VideoPermissions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoPermissions&&(identical(other.canComment, canComment) || other.canComment == canComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canComment);

@override
String toString() {
  return 'VideoPermissions(canComment: $canComment)';
}


}

/// @nodoc
abstract mixin class $VideoPermissionsCopyWith<$Res>  {
  factory $VideoPermissionsCopyWith(VideoPermissions value, $Res Function(VideoPermissions) _then) = _$VideoPermissionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'can_comment') bool canComment
});




}
/// @nodoc
class _$VideoPermissionsCopyWithImpl<$Res>
    implements $VideoPermissionsCopyWith<$Res> {
  _$VideoPermissionsCopyWithImpl(this._self, this._then);

  final VideoPermissions _self;
  final $Res Function(VideoPermissions) _then;

/// Create a copy of VideoPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canComment = null,}) {
  return _then(_self.copyWith(
canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoPermissions].
extension VideoPermissionsPatterns on VideoPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoPermissions value)  $default,){
final _that = this;
switch (_that) {
case _VideoPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _VideoPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'can_comment')  bool canComment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoPermissions() when $default != null:
return $default(_that.canComment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'can_comment')  bool canComment)  $default,) {final _that = this;
switch (_that) {
case _VideoPermissions():
return $default(_that.canComment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'can_comment')  bool canComment)?  $default,) {final _that = this;
switch (_that) {
case _VideoPermissions() when $default != null:
return $default(_that.canComment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoPermissions implements VideoPermissions {
  const _VideoPermissions({@JsonKey(name: 'can_comment') this.canComment = true});
  factory _VideoPermissions.fromJson(Map<String, dynamic> json) => _$VideoPermissionsFromJson(json);

@override@JsonKey(name: 'can_comment') final  bool canComment;

/// Create a copy of VideoPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoPermissionsCopyWith<_VideoPermissions> get copyWith => __$VideoPermissionsCopyWithImpl<_VideoPermissions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoPermissionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoPermissions&&(identical(other.canComment, canComment) || other.canComment == canComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canComment);

@override
String toString() {
  return 'VideoPermissions(canComment: $canComment)';
}


}

/// @nodoc
abstract mixin class _$VideoPermissionsCopyWith<$Res> implements $VideoPermissionsCopyWith<$Res> {
  factory _$VideoPermissionsCopyWith(_VideoPermissions value, $Res Function(_VideoPermissions) _then) = __$VideoPermissionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'can_comment') bool canComment
});




}
/// @nodoc
class __$VideoPermissionsCopyWithImpl<$Res>
    implements _$VideoPermissionsCopyWith<$Res> {
  __$VideoPermissionsCopyWithImpl(this._self, this._then);

  final _VideoPermissions _self;
  final $Res Function(_VideoPermissions) _then;

/// Create a copy of VideoPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canComment = null,}) {
  return _then(_VideoPermissions(
canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$VideoMeta {

@JsonKey(name: 'contains_ai') bool get containsAi;@JsonKey(name: 'contains_ad') bool get containsAd;
/// Create a copy of VideoMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoMetaCopyWith<VideoMeta> get copyWith => _$VideoMetaCopyWithImpl<VideoMeta>(this as VideoMeta, _$identity);

  /// Serializes this VideoMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoMeta&&(identical(other.containsAi, containsAi) || other.containsAi == containsAi)&&(identical(other.containsAd, containsAd) || other.containsAd == containsAd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,containsAi,containsAd);

@override
String toString() {
  return 'VideoMeta(containsAi: $containsAi, containsAd: $containsAd)';
}


}

/// @nodoc
abstract mixin class $VideoMetaCopyWith<$Res>  {
  factory $VideoMetaCopyWith(VideoMeta value, $Res Function(VideoMeta) _then) = _$VideoMetaCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'contains_ai') bool containsAi,@JsonKey(name: 'contains_ad') bool containsAd
});




}
/// @nodoc
class _$VideoMetaCopyWithImpl<$Res>
    implements $VideoMetaCopyWith<$Res> {
  _$VideoMetaCopyWithImpl(this._self, this._then);

  final VideoMeta _self;
  final $Res Function(VideoMeta) _then;

/// Create a copy of VideoMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? containsAi = null,Object? containsAd = null,}) {
  return _then(_self.copyWith(
containsAi: null == containsAi ? _self.containsAi : containsAi // ignore: cast_nullable_to_non_nullable
as bool,containsAd: null == containsAd ? _self.containsAd : containsAd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoMeta].
extension VideoMetaPatterns on VideoMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoMeta value)  $default,){
final _that = this;
switch (_that) {
case _VideoMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoMeta value)?  $default,){
final _that = this;
switch (_that) {
case _VideoMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'contains_ai')  bool containsAi, @JsonKey(name: 'contains_ad')  bool containsAd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoMeta() when $default != null:
return $default(_that.containsAi,_that.containsAd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'contains_ai')  bool containsAi, @JsonKey(name: 'contains_ad')  bool containsAd)  $default,) {final _that = this;
switch (_that) {
case _VideoMeta():
return $default(_that.containsAi,_that.containsAd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'contains_ai')  bool containsAi, @JsonKey(name: 'contains_ad')  bool containsAd)?  $default,) {final _that = this;
switch (_that) {
case _VideoMeta() when $default != null:
return $default(_that.containsAi,_that.containsAd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoMeta implements VideoMeta {
  const _VideoMeta({@JsonKey(name: 'contains_ai') this.containsAi = false, @JsonKey(name: 'contains_ad') this.containsAd = false});
  factory _VideoMeta.fromJson(Map<String, dynamic> json) => _$VideoMetaFromJson(json);

@override@JsonKey(name: 'contains_ai') final  bool containsAi;
@override@JsonKey(name: 'contains_ad') final  bool containsAd;

/// Create a copy of VideoMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoMetaCopyWith<_VideoMeta> get copyWith => __$VideoMetaCopyWithImpl<_VideoMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoMeta&&(identical(other.containsAi, containsAi) || other.containsAi == containsAi)&&(identical(other.containsAd, containsAd) || other.containsAd == containsAd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,containsAi,containsAd);

@override
String toString() {
  return 'VideoMeta(containsAi: $containsAi, containsAd: $containsAd)';
}


}

/// @nodoc
abstract mixin class _$VideoMetaCopyWith<$Res> implements $VideoMetaCopyWith<$Res> {
  factory _$VideoMetaCopyWith(_VideoMeta value, $Res Function(_VideoMeta) _then) = __$VideoMetaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'contains_ai') bool containsAi,@JsonKey(name: 'contains_ad') bool containsAd
});




}
/// @nodoc
class __$VideoMetaCopyWithImpl<$Res>
    implements _$VideoMetaCopyWith<$Res> {
  __$VideoMetaCopyWithImpl(this._self, this._then);

  final _VideoMeta _self;
  final $Res Function(_VideoMeta) _then;

/// Create a copy of VideoMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? containsAi = null,Object? containsAd = null,}) {
  return _then(_VideoMeta(
containsAi: null == containsAi ? _self.containsAi : containsAi // ignore: cast_nullable_to_non_nullable
as bool,containsAd: null == containsAd ? _self.containsAd : containsAd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
