// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_content_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentUserController)
const currentUserControllerProvider = CurrentUserControllerProvider._();

final class CurrentUserControllerProvider
    extends $AsyncNotifierProvider<CurrentUserController, UserModel?> {
  const CurrentUserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserControllerHash();

  @$internal
  @override
  CurrentUserController create() => CurrentUserController();
}

String _$currentUserControllerHash() =>
    r'bea00e7903dd3d002b7bad21876cb61d231a613f';

abstract class _$CurrentUserController extends $AsyncNotifier<UserModel?> {
  FutureOr<UserModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserModel?>, UserModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserModel?>, UserModel?>,
              AsyncValue<UserModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MyVideosController)
const myVideosControllerProvider = MyVideosControllerProvider._();

final class MyVideosControllerProvider
    extends $AsyncNotifierProvider<MyVideosController, List<VideoModel>> {
  const MyVideosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVideosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVideosControllerHash();

  @$internal
  @override
  MyVideosController create() => MyVideosController();
}

String _$myVideosControllerHash() =>
    r'8216b117f9ff4dd695ca8414725162050effd660';

abstract class _$MyVideosController extends $AsyncNotifier<List<VideoModel>> {
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

@ProviderFor(MyLikedVideosController)
const myLikedVideosControllerProvider = MyLikedVideosControllerProvider._();

final class MyLikedVideosControllerProvider
    extends $AsyncNotifierProvider<MyLikedVideosController, List<VideoModel>> {
  const MyLikedVideosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myLikedVideosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myLikedVideosControllerHash();

  @$internal
  @override
  MyLikedVideosController create() => MyLikedVideosController();
}

String _$myLikedVideosControllerHash() =>
    r'6320851d5c1b0e304f12dc37c4c6519648142906';

abstract class _$MyLikedVideosController
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
