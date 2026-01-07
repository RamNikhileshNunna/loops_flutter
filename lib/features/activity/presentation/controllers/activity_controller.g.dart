// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActivityController)
const activityControllerProvider = ActivityControllerProvider._();

final class ActivityControllerProvider
    extends
        $AsyncNotifierProvider<ActivityController, List<NotificationModel>> {
  const ActivityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityControllerHash();

  @$internal
  @override
  ActivityController create() => ActivityController();
}

String _$activityControllerHash() =>
    r'2e5931aa17f2b965913550950bf3ec064da62b77';

abstract class _$ActivityController
    extends $AsyncNotifier<List<NotificationModel>> {
  FutureOr<List<NotificationModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NotificationModel>>,
              List<NotificationModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationModel>>,
                List<NotificationModel>
              >,
              AsyncValue<List<NotificationModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
