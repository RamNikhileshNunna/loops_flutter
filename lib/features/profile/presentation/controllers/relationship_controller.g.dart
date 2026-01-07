// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(followers)
const followersProvider = FollowersFamily._();

final class FollowersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const FollowersProvider._({
    required FollowersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersHash();

  @override
  String toString() {
    return r'followersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return followers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersHash() => r'9c04f82391b9057f278c3f412bdd7a08568f30f8';

final class FollowersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  const FollowersFamily._()
    : super(
        retry: null,
        name: r'followersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowersProvider call(String userId) =>
      FollowersProvider._(argument: userId, from: this);

  @override
  String toString() => r'followersProvider';
}

@ProviderFor(following)
const followingProvider = FollowingFamily._();

final class FollowingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  const FollowingProvider._({
    required FollowingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingHash();

  @override
  String toString() {
    return r'followingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return following(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingHash() => r'a001293595ed597d44b860aa92b47c50ef72e19d';

final class FollowingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  const FollowingFamily._()
    : super(
        retry: null,
        name: r'followingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowingProvider call(String userId) =>
      FollowingProvider._(argument: userId, from: this);

  @override
  String toString() => r'followingProvider';
}
