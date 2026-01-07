import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @JsonKey(name: 'autoplay_videos') @Default(true) bool autoplayVideos,
    @JsonKey(name: 'loop_videos') @Default(true) bool loopVideos,
    @JsonKey(name: 'default_feed') @Default('local') String defaultFeed,
    @JsonKey(name: 'hide_for_you_feed') @Default(false) bool hideForYouFeed,
    @JsonKey(name: 'mute_on_open') @Default(false) bool muteOnOpen,
    @JsonKey(name: 'auto_expand_cw') @Default(false) bool autoExpandCw,
    @Default('system') String appearance,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
