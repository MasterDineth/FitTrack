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
    r'b8f3ef717a83e73a0ea8cce3430882755c68e632';

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
    r'175e31dcb2e05cf9687826ffc0fe04369024a636';

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

@ProviderFor(workoutSessionDetail)
final workoutSessionDetailProvider = WorkoutSessionDetailFamily._();

final class WorkoutSessionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSessionDetailData?>,
          WorkoutSessionDetailData?,
          FutureOr<WorkoutSessionDetailData?>
        >
    with
        $FutureModifier<WorkoutSessionDetailData?>,
        $FutureProvider<WorkoutSessionDetailData?> {
  WorkoutSessionDetailProvider._({
    required WorkoutSessionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutSessionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionDetailHash();

  @override
  String toString() {
    return r'workoutSessionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSessionDetailData?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSessionDetailData?> create(Ref ref) {
    final argument = this.argument as String;
    return workoutSessionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSessionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSessionDetailHash() =>
    r'02fdf3a21dbefd1da41b1889c6f22a123f0f988e';

final class WorkoutSessionDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<WorkoutSessionDetailData?>, String> {
  WorkoutSessionDetailFamily._()
    : super(
        retry: null,
        name: r'workoutSessionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSessionDetailProvider call(String sessionId) =>
      WorkoutSessionDetailProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'workoutSessionDetailProvider';
}
