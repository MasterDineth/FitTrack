// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutHistoryNotifier)
final workoutHistoryProvider = WorkoutHistoryNotifierProvider._();

final class WorkoutHistoryNotifierProvider
    extends $NotifierProvider<WorkoutHistoryNotifier, WorkoutHistoryState> {
  WorkoutHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutHistoryNotifierHash();

  @$internal
  @override
  WorkoutHistoryNotifier create() => WorkoutHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutHistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutHistoryState>(value),
    );
  }
}

String _$workoutHistoryNotifierHash() =>
    r'ce6e54cf8c9006bfc2fec2c57fe80b7265c48ccd';

abstract class _$WorkoutHistoryNotifier extends $Notifier<WorkoutHistoryState> {
  WorkoutHistoryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkoutHistoryState, WorkoutHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutHistoryState, WorkoutHistoryState>,
              WorkoutHistoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(workoutSessionById)
final workoutSessionByIdProvider = WorkoutSessionByIdFamily._();

final class WorkoutSessionByIdProvider
    extends
        $FunctionalProvider<WorkoutSession?, WorkoutSession?, WorkoutSession?>
    with $Provider<WorkoutSession?> {
  WorkoutSessionByIdProvider._({
    required WorkoutSessionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutSessionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionByIdHash();

  @override
  String toString() {
    return r'workoutSessionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<WorkoutSession?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkoutSession? create(Ref ref) {
    final argument = this.argument as String;
    return workoutSessionById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutSession?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSessionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSessionByIdHash() =>
    r'c10780d84c1834ce044e556c6259a0a36660b6eb';

final class WorkoutSessionByIdFamily extends $Family
    with $FunctionalFamilyOverride<WorkoutSession?, String> {
  WorkoutSessionByIdFamily._()
    : super(
        retry: null,
        name: r'workoutSessionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSessionByIdProvider call(String id) =>
      WorkoutSessionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'workoutSessionByIdProvider';
}
