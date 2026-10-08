// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedules_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod Notifier managing Workout Schedules, Filters, Search, and Bookmarks.

@ProviderFor(SchedulesNotifier)
final schedulesProvider = SchedulesNotifierProvider._();

/// Riverpod Notifier managing Workout Schedules, Filters, Search, and Bookmarks.
final class SchedulesNotifierProvider
    extends $NotifierProvider<SchedulesNotifier, SchedulesState> {
  /// Riverpod Notifier managing Workout Schedules, Filters, Search, and Bookmarks.
  SchedulesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schedulesNotifierHash();

  @$internal
  @override
  SchedulesNotifier create() => SchedulesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchedulesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchedulesState>(value),
    );
  }
}

String _$schedulesNotifierHash() => r'219d3a82beecb8ff67895cdfe4f32b12fae0952a';

/// Riverpod Notifier managing Workout Schedules, Filters, Search, and Bookmarks.

abstract class _$SchedulesNotifier extends $Notifier<SchedulesState> {
  SchedulesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SchedulesState, SchedulesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SchedulesState, SchedulesState>,
              SchedulesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider that loads up to 5 workout schedules directly from SQLite database.

@ProviderFor(dbBrowseSchedules)
final dbBrowseSchedulesProvider = DbBrowseSchedulesProvider._();

/// Provider that loads up to 5 workout schedules directly from SQLite database.

final class DbBrowseSchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSchedule>>,
          List<WorkoutSchedule>,
          FutureOr<List<WorkoutSchedule>>
        >
    with
        $FutureModifier<List<WorkoutSchedule>>,
        $FutureProvider<List<WorkoutSchedule>> {
  /// Provider that loads up to 5 workout schedules directly from SQLite database.
  DbBrowseSchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dbBrowseSchedulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dbBrowseSchedulesHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSchedule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSchedule>> create(Ref ref) {
    return dbBrowseSchedules(ref);
  }
}

String _$dbBrowseSchedulesHash() => r'82d66755cefcade0e7c51fae66a9c45de7841c15';

/// Provider that loads Today's Routine Spotlight with top 3 exercises from DB.

@ProviderFor(routineSpotlight)
final routineSpotlightProvider = RoutineSpotlightProvider._();

/// Provider that loads Today's Routine Spotlight with top 3 exercises from DB.

final class RoutineSpotlightProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutineSpotlight>,
          RoutineSpotlight,
          FutureOr<RoutineSpotlight>
        >
    with $FutureModifier<RoutineSpotlight>, $FutureProvider<RoutineSpotlight> {
  /// Provider that loads Today's Routine Spotlight with top 3 exercises from DB.
  RoutineSpotlightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineSpotlightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineSpotlightHash();

  @$internal
  @override
  $FutureProviderElement<RoutineSpotlight> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutineSpotlight> create(Ref ref) {
    return routineSpotlight(ref);
  }
}

String _$routineSpotlightHash() => r'322ace1480488198197c59e2b70003ef7df11783';

/// Provider providing Trending Programs for the Workout Library carousel.

@ProviderFor(trendingPrograms)
final trendingProgramsProvider = TrendingProgramsProvider._();

/// Provider providing Trending Programs for the Workout Library carousel.

final class TrendingProgramsProvider
    extends
        $FunctionalProvider<
          List<TrendingProgram>,
          List<TrendingProgram>,
          List<TrendingProgram>
        >
    with $Provider<List<TrendingProgram>> {
  /// Provider providing Trending Programs for the Workout Library carousel.
  TrendingProgramsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingProgramsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingProgramsHash();

  @$internal
  @override
  $ProviderElement<List<TrendingProgram>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TrendingProgram> create(Ref ref) {
    return trendingPrograms(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TrendingProgram> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TrendingProgram>>(value),
    );
  }
}

String _$trendingProgramsHash() => r'7cf0a629e8069d58da29d0a06791c9514cfd5841';

/// Provider providing user saved/custom routines for the "My Saved & Custom" section.

@ProviderFor(customRoutines)
final customRoutinesProvider = CustomRoutinesProvider._();

/// Provider providing user saved/custom routines for the "My Saved & Custom" section.

final class CustomRoutinesProvider
    extends
        $FunctionalProvider<
          List<CustomWorkoutRoutine>,
          List<CustomWorkoutRoutine>,
          List<CustomWorkoutRoutine>
        >
    with $Provider<List<CustomWorkoutRoutine>> {
  /// Provider providing user saved/custom routines for the "My Saved & Custom" section.
  CustomRoutinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customRoutinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customRoutinesHash();

  @$internal
  @override
  $ProviderElement<List<CustomWorkoutRoutine>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CustomWorkoutRoutine> create(Ref ref) {
    return customRoutines(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CustomWorkoutRoutine> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CustomWorkoutRoutine>>(value),
    );
  }
}

String _$customRoutinesHash() => r'fa328ef9060c5116b73401aef9e046d07976d629';
