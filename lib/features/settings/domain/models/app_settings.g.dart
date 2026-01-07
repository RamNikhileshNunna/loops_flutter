// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  autoplayVideos: json['autoplay_videos'] as bool? ?? true,
  loopVideos: json['loop_videos'] as bool? ?? true,
  defaultFeed: json['default_feed'] as String? ?? 'local',
  hideForYouFeed: json['hide_for_you_feed'] as bool? ?? false,
  muteOnOpen: json['mute_on_open'] as bool? ?? false,
  autoExpandCw: json['auto_expand_cw'] as bool? ?? false,
  appearance: json['appearance'] as String? ?? 'system',
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'autoplay_videos': instance.autoplayVideos,
      'loop_videos': instance.loopVideos,
      'default_feed': instance.defaultFeed,
      'hide_for_you_feed': instance.hideForYouFeed,
      'mute_on_open': instance.muteOnOpen,
      'auto_expand_cw': instance.autoExpandCw,
      'appearance': instance.appearance,
    };
