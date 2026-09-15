// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_workout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveWorkoutNotifier)
final activeWorkoutProvider = ActiveWorkoutNotifierProvider._();

final class ActiveWorkoutNotifierProvider
    extends $NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState> {
  ActiveWorkoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWorkoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWorkoutNotifierHash();

  @$internal
  @override
  ActiveWorkoutNotifier create() => ActiveWorkoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveWorkoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveWorkoutState>(value),
    );
  }
}

String _$activeWorkoutNotifierHash() =>
    r'76d57f6e17422f46815161952ffdb57552879245';

abstract class _$ActiveWorkoutNotifier extends $Notifier<ActiveWorkoutState> {
  ActiveWorkoutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActiveWorkoutState, ActiveWorkoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveWorkoutState, ActiveWorkoutState>,
              ActiveWorkoutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
