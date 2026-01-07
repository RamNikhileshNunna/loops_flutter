// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

@JsonKey(name: 'autoplay_videos') bool get autoplayVideos;@JsonKey(name: 'loop_videos') bool get loopVideos;@JsonKey(name: 'default_feed') String get defaultFeed;@JsonKey(name: 'hide_for_you_feed') bool get hideForYouFeed;@JsonKey(name: 'mute_on_open') bool get muteOnOpen;@JsonKey(name: 'auto_expand_cw') bool get autoExpandCw; String get appearance;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.autoplayVideos, autoplayVideos) || other.autoplayVideos == autoplayVideos)&&(identical(other.loopVideos, loopVideos) || other.loopVideos == loopVideos)&&(identical(other.defaultFeed, defaultFeed) || other.defaultFeed == defaultFeed)&&(identical(other.hideForYouFeed, hideForYouFeed) || other.hideForYouFeed == hideForYouFeed)&&(identical(other.muteOnOpen, muteOnOpen) || other.muteOnOpen == muteOnOpen)&&(identical(other.autoExpandCw, autoExpandCw) || other.autoExpandCw == autoExpandCw)&&(identical(other.appearance, appearance) || other.appearance == appearance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,autoplayVideos,loopVideos,defaultFeed,hideForYouFeed,muteOnOpen,autoExpandCw,appearance);

@override
String toString() {
  return 'AppSettings(autoplayVideos: $autoplayVideos, loopVideos: $loopVideos, defaultFeed: $defaultFeed, hideForYouFeed: $hideForYouFeed, muteOnOpen: $muteOnOpen, autoExpandCw: $autoExpandCw, appearance: $appearance)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'autoplay_videos') bool autoplayVideos,@JsonKey(name: 'loop_videos') bool loopVideos,@JsonKey(name: 'default_feed') String defaultFeed,@JsonKey(name: 'hide_for_you_feed') bool hideForYouFeed,@JsonKey(name: 'mute_on_open') bool muteOnOpen,@JsonKey(name: 'auto_expand_cw') bool autoExpandCw, String appearance
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoplayVideos = null,Object? loopVideos = null,Object? defaultFeed = null,Object? hideForYouFeed = null,Object? muteOnOpen = null,Object? autoExpandCw = null,Object? appearance = null,}) {
  return _then(_self.copyWith(
autoplayVideos: null == autoplayVideos ? _self.autoplayVideos : autoplayVideos // ignore: cast_nullable_to_non_nullable
as bool,loopVideos: null == loopVideos ? _self.loopVideos : loopVideos // ignore: cast_nullable_to_non_nullable
as bool,defaultFeed: null == defaultFeed ? _self.defaultFeed : defaultFeed // ignore: cast_nullable_to_non_nullable
as String,hideForYouFeed: null == hideForYouFeed ? _self.hideForYouFeed : hideForYouFeed // ignore: cast_nullable_to_non_nullable
as bool,muteOnOpen: null == muteOnOpen ? _self.muteOnOpen : muteOnOpen // ignore: cast_nullable_to_non_nullable
as bool,autoExpandCw: null == autoExpandCw ? _self.autoExpandCw : autoExpandCw // ignore: cast_nullable_to_non_nullable
as bool,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'autoplay_videos')  bool autoplayVideos, @JsonKey(name: 'loop_videos')  bool loopVideos, @JsonKey(name: 'default_feed')  String defaultFeed, @JsonKey(name: 'hide_for_you_feed')  bool hideForYouFeed, @JsonKey(name: 'mute_on_open')  bool muteOnOpen, @JsonKey(name: 'auto_expand_cw')  bool autoExpandCw,  String appearance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoplayVideos,_that.loopVideos,_that.defaultFeed,_that.hideForYouFeed,_that.muteOnOpen,_that.autoExpandCw,_that.appearance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'autoplay_videos')  bool autoplayVideos, @JsonKey(name: 'loop_videos')  bool loopVideos, @JsonKey(name: 'default_feed')  String defaultFeed, @JsonKey(name: 'hide_for_you_feed')  bool hideForYouFeed, @JsonKey(name: 'mute_on_open')  bool muteOnOpen, @JsonKey(name: 'auto_expand_cw')  bool autoExpandCw,  String appearance)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.autoplayVideos,_that.loopVideos,_that.defaultFeed,_that.hideForYouFeed,_that.muteOnOpen,_that.autoExpandCw,_that.appearance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'autoplay_videos')  bool autoplayVideos, @JsonKey(name: 'loop_videos')  bool loopVideos, @JsonKey(name: 'default_feed')  String defaultFeed, @JsonKey(name: 'hide_for_you_feed')  bool hideForYouFeed, @JsonKey(name: 'mute_on_open')  bool muteOnOpen, @JsonKey(name: 'auto_expand_cw')  bool autoExpandCw,  String appearance)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoplayVideos,_that.loopVideos,_that.defaultFeed,_that.hideForYouFeed,_that.muteOnOpen,_that.autoExpandCw,_that.appearance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({@JsonKey(name: 'autoplay_videos') this.autoplayVideos = true, @JsonKey(name: 'loop_videos') this.loopVideos = true, @JsonKey(name: 'default_feed') this.defaultFeed = 'local', @JsonKey(name: 'hide_for_you_feed') this.hideForYouFeed = false, @JsonKey(name: 'mute_on_open') this.muteOnOpen = false, @JsonKey(name: 'auto_expand_cw') this.autoExpandCw = false, this.appearance = 'system'});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey(name: 'autoplay_videos') final  bool autoplayVideos;
@override@JsonKey(name: 'loop_videos') final  bool loopVideos;
@override@JsonKey(name: 'default_feed') final  String defaultFeed;
@override@JsonKey(name: 'hide_for_you_feed') final  bool hideForYouFeed;
@override@JsonKey(name: 'mute_on_open') final  bool muteOnOpen;
@override@JsonKey(name: 'auto_expand_cw') final  bool autoExpandCw;
@override@JsonKey() final  String appearance;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.autoplayVideos, autoplayVideos) || other.autoplayVideos == autoplayVideos)&&(identical(other.loopVideos, loopVideos) || other.loopVideos == loopVideos)&&(identical(other.defaultFeed, defaultFeed) || other.defaultFeed == defaultFeed)&&(identical(other.hideForYouFeed, hideForYouFeed) || other.hideForYouFeed == hideForYouFeed)&&(identical(other.muteOnOpen, muteOnOpen) || other.muteOnOpen == muteOnOpen)&&(identical(other.autoExpandCw, autoExpandCw) || other.autoExpandCw == autoExpandCw)&&(identical(other.appearance, appearance) || other.appearance == appearance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,autoplayVideos,loopVideos,defaultFeed,hideForYouFeed,muteOnOpen,autoExpandCw,appearance);

@override
String toString() {
  return 'AppSettings(autoplayVideos: $autoplayVideos, loopVideos: $loopVideos, defaultFeed: $defaultFeed, hideForYouFeed: $hideForYouFeed, muteOnOpen: $muteOnOpen, autoExpandCw: $autoExpandCw, appearance: $appearance)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'autoplay_videos') bool autoplayVideos,@JsonKey(name: 'loop_videos') bool loopVideos,@JsonKey(name: 'default_feed') String defaultFeed,@JsonKey(name: 'hide_for_you_feed') bool hideForYouFeed,@JsonKey(name: 'mute_on_open') bool muteOnOpen,@JsonKey(name: 'auto_expand_cw') bool autoExpandCw, String appearance
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoplayVideos = null,Object? loopVideos = null,Object? defaultFeed = null,Object? hideForYouFeed = null,Object? muteOnOpen = null,Object? autoExpandCw = null,Object? appearance = null,}) {
  return _then(_AppSettings(
autoplayVideos: null == autoplayVideos ? _self.autoplayVideos : autoplayVideos // ignore: cast_nullable_to_non_nullable
as bool,loopVideos: null == loopVideos ? _self.loopVideos : loopVideos // ignore: cast_nullable_to_non_nullable
as bool,defaultFeed: null == defaultFeed ? _self.defaultFeed : defaultFeed // ignore: cast_nullable_to_non_nullable
as String,hideForYouFeed: null == hideForYouFeed ? _self.hideForYouFeed : hideForYouFeed // ignore: cast_nullable_to_non_nullable
as bool,muteOnOpen: null == muteOnOpen ? _self.muteOnOpen : muteOnOpen // ignore: cast_nullable_to_non_nullable
as bool,autoExpandCw: null == autoExpandCw ? _self.autoExpandCw : autoExpandCw // ignore: cast_nullable_to_non_nullable
as bool,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
