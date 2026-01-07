// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(suggestedAccounts)
const suggestedAccountsProvider = SuggestedAccountsProvider._();

final class SuggestedAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const SuggestedAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestedAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestedAccountsHash();

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    return suggestedAccounts(ref);
  }
}

String _$suggestedAccountsHash() => r'51478b214d7bd94962147cd9edba4cd8e471635d';

@ProviderFor(trendingTags)
const trendingTagsProvider = TrendingTagsProvider._();

final class TrendingTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TagModel>>,
          List<TagModel>,
          FutureOr<List<TagModel>>
        >
    with $FutureModifier<List<TagModel>>, $FutureProvider<List<TagModel>> {
  const TrendingTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingTagsHash();

  @$internal
  @override
  $FutureProviderElement<List<TagModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TagModel>> create(Ref ref) {
    return trendingTags(ref);
  }
}

String _$trendingTagsHash() => r'13c51ff6c381ade7c58cf2706dce91578426bdc4';

@ProviderFor(TagFeedController)
const tagFeedControllerProvider = TagFeedControllerFamily._();

final class TagFeedControllerProvider
    extends $AsyncNotifierProvider<TagFeedController, List<VideoModel>> {
  const TagFeedControllerProvider._({
    required TagFeedControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagFeedControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagFeedControllerHash();

  @override
  String toString() {
    return r'tagFeedControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TagFeedController create() => TagFeedController();

  @override
  bool operator ==(Object other) {
    return other is TagFeedControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagFeedControllerHash() => r'f9086d969a9b136d71f087ff6ac55defd221d11a';

final class TagFeedControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TagFeedController,
          AsyncValue<List<VideoModel>>,
          List<VideoModel>,
          FutureOr<List<VideoModel>>,
          String
        > {
  const TagFeedControllerFamily._()
    : super(
        retry: null,
        name: r'tagFeedControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagFeedControllerProvider call(String tag) =>
      TagFeedControllerProvider._(argument: tag, from: this);

  @override
  String toString() => r'tagFeedControllerProvider';
}

abstract class _$TagFeedController extends $AsyncNotifier<List<VideoModel>> {
  late final _$args = ref.$arg as String;
  String get tag => _$args;

  FutureOr<List<VideoModel>> build(String tag);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<VideoModel>>, List<VideoModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VideoModel>>, List<VideoModel>>,
              AsyncValue<List<VideoModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
