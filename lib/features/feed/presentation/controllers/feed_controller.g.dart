// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedController)
const feedControllerProvider = FeedControllerProvider._();

final class FeedControllerProvider
    extends $AsyncNotifierProvider<FeedController, List<VideoModel>> {
  const FeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedControllerHash();

  @$internal
  @override
  FeedController create() => FeedController();
}

String _$feedControllerHash() => r'e6466e91623e504aa0aaec85927df4763c086ac6';

abstract class _$FeedController extends $AsyncNotifier<List<VideoModel>> {
  FutureOr<List<VideoModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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

@ProviderFor(FollowingFeedController)
const followingFeedControllerProvider = FollowingFeedControllerProvider._();

final class FollowingFeedControllerProvider
    extends $AsyncNotifierProvider<FollowingFeedController, List<VideoModel>> {
  const FollowingFeedControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingFeedControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingFeedControllerHash();

  @$internal
  @override
  FollowingFeedController create() => FollowingFeedController();
}

String _$followingFeedControllerHash() =>
    r'931f6d41bb50202812f038bd321c763f703ca2ff';

abstract class _$FollowingFeedController
    extends $AsyncNotifier<List<VideoModel>> {
  FutureOr<List<VideoModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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
