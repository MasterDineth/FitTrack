// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logic_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Estimates the total duration (in seconds) for a workout given its exercises.
///
/// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.

@ProviderFor(durationCalculation)
final durationCalculationProvider = DurationCalculationFamily._();

/// Estimates the total duration (in seconds) for a workout given its exercises.
///
/// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.

final class DurationCalculationProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Estimates the total duration (in seconds) for a workout given its exercises.
  ///
  /// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.
  DurationCalculationProvider._({
    required DurationCalculationFamily super.from,
    required List<ScheduleExercise> super.argument,
  }) : super(
         retry: null,
         name: r'durationCalculationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$durationCalculationHash();

  @override
  String toString() {
    return r'durationCalculationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as List<ScheduleExercise>;
    return durationCalculation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DurationCalculationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$durationCalculationHash() =>
    r'fcf089f0a35a7ea351f0e7edd87f2cfacaf79498';

/// Estimates the total duration (in seconds) for a workout given its exercises.
///
/// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.

final class DurationCalculationFamily extends $Family
    with $FunctionalFamilyOverride<int, List<ScheduleExercise>> {
  DurationCalculationFamily._()
    : super(
        retry: null,
        name: r'durationCalculationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Estimates the total duration (in seconds) for a workout given its exercises.
  ///
  /// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.

  DurationCalculationProvider call(List<ScheduleExercise> exercises) =>
      DurationCalculationProvider._(argument: exercises, from: this);

  @override
  String toString() => r'durationCalculationProvider';
}

/// Recommends the next [Schedule] to perform based on sessions completed
/// so far this week.
///
/// Returns `null` when all scheduled workouts have been completed
/// (i.e. a rest state).

@ProviderFor(splitRecommendation)
final splitRecommendationProvider = SplitRecommendationFamily._();

/// Recommends the next [Schedule] to perform based on sessions completed
/// so far this week.
///
/// Returns `null` when all scheduled workouts have been completed
/// (i.e. a rest state).

final class SplitRecommendationProvider
    extends
        $FunctionalProvider<
          AsyncValue<Schedule?>,
          Schedule?,
          FutureOr<Schedule?>
        >
    with $FutureModifier<Schedule?>, $FutureProvider<Schedule?> {
  /// Recommends the next [Schedule] to perform based on sessions completed
  /// so far this week.
  ///
  /// Returns `null` when all scheduled workouts have been completed
  /// (i.e. a rest state).
  SplitRecommendationProvider._({
    required SplitRecommendationFamily super.from,
    required (IScheduleRepository, IWorkoutSessionRepository) super.argument,
  }) : super(
         retry: null,
         name: r'splitRecommendationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$splitRecommendationHash();

  @override
  String toString() {
    return r'splitRecommendationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Schedule?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Schedule?> create(Ref ref) {
    final argument =
        this.argument as (IScheduleRepository, IWorkoutSessionRepository);
    return splitRecommendation(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SplitRecommendationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$splitRecommendationHash() =>
    r'017a30130bbdf704dcdb326b0ab9d038016964be';

/// Recommends the next [Schedule] to perform based on sessions completed
/// so far this week.
///
/// Returns `null` when all scheduled workouts have been completed
/// (i.e. a rest state).

final class SplitRecommendationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Schedule?>,
          (IScheduleRepository, IWorkoutSessionRepository)
        > {
  SplitRecommendationFamily._()
    : super(
        retry: null,
        name: r'splitRecommendationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recommends the next [Schedule] to perform based on sessions completed
  /// so far this week.
  ///
  /// Returns `null` when all scheduled workouts have been completed
  /// (i.e. a rest state).

  SplitRecommendationProvider call(
    IScheduleRepository scheduleRepo,
    IWorkoutSessionRepository sessionRepo,
  ) => SplitRecommendationProvider._(
    argument: (scheduleRepo, sessionRepo),
    from: this,
  );

  @override
  String toString() => r'splitRecommendationProvider';
}

/// Aggregates dashboard metrics for the current week and all-time.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])

@ProviderFor(dashboardMetrics)
final dashboardMetricsProvider = DashboardMetricsFamily._();

/// Aggregates dashboard metrics for the current week and all-time.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])

final class DashboardMetricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Aggregates dashboard metrics for the current week and all-time.
  ///
  /// Returns a map with keys:
  /// - `daysTrainedThisWeek` ([int])
  /// - `totalWorkoutsCompleted` ([int])
  /// - `totalCaloriesBurned` ([int])
  DashboardMetricsProvider._({
    required DashboardMetricsFamily super.from,
    required IWorkoutSessionRepository super.argument,
  }) : super(
         retry: null,
         name: r'dashboardMetricsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardMetricsHash();

  @override
  String toString() {
    return r'dashboardMetricsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as IWorkoutSessionRepository;
    return dashboardMetrics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardMetricsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardMetricsHash() => r'75a08aa3554566bc95228ccf6324fac6d8911a3f';

/// Aggregates dashboard metrics for the current week and all-time.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])

final class DashboardMetricsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, dynamic>>,
          IWorkoutSessionRepository
        > {
  DashboardMetricsFamily._()
    : super(
        retry: null,
        name: r'dashboardMetricsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Aggregates dashboard metrics for the current week and all-time.
  ///
  /// Returns a map with keys:
  /// - `daysTrainedThisWeek` ([int])
  /// - `totalWorkoutsCompleted` ([int])
  /// - `totalCaloriesBurned` ([int])

  DashboardMetricsProvider call(IWorkoutSessionRepository sessionRepo) =>
      DashboardMetricsProvider._(argument: sessionRepo, from: this);

  @override
  String toString() => r'dashboardMetricsProvider';
}

/// Returns the set of [DateTime]s in [month] on which a workout session
/// was started, for rendering the monthly activity calendar.

@ProviderFor(calendarActivity)
final calendarActivityProvider = CalendarActivityFamily._();

/// Returns the set of [DateTime]s in [month] on which a workout session
/// was started, for rendering the monthly activity calendar.

final class CalendarActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTime>>,
          List<DateTime>,
          FutureOr<List<DateTime>>
        >
    with $FutureModifier<List<DateTime>>, $FutureProvider<List<DateTime>> {
  /// Returns the set of [DateTime]s in [month] on which a workout session
  /// was started, for rendering the monthly activity calendar.
  CalendarActivityProvider._({
    required CalendarActivityFamily super.from,
    required (IWorkoutSessionRepository, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'calendarActivityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarActivityHash();

  @override
  String toString() {
    return r'calendarActivityProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DateTime>> create(Ref ref) {
    final argument = this.argument as (IWorkoutSessionRepository, DateTime);
    return calendarActivity(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarActivityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarActivityHash() => r'73743bb822d96c99c4490cad03f609e6825717bb';

/// Returns the set of [DateTime]s in [month] on which a workout session
/// was started, for rendering the monthly activity calendar.

final class CalendarActivityFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DateTime>>,
          (IWorkoutSessionRepository, DateTime)
        > {
  CalendarActivityFamily._()
    : super(
        retry: null,
        name: r'calendarActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns the set of [DateTime]s in [month] on which a workout session
  /// was started, for rendering the monthly activity calendar.

  CalendarActivityProvider call(
    IWorkoutSessionRepository sessionRepo,
    DateTime month,
  ) => CalendarActivityProvider._(argument: (sessionRepo, month), from: this);

  @override
  String toString() => r'calendarActivityProvider';
}
