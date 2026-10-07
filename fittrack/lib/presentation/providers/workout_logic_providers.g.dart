// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logic_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single keepAlive revision tracker that is bumped whenever a session is
/// saved, finished, or discarded so derived providers only re-evaluate then.

@ProviderFor(SessionsRevisionNotifier)
final sessionsRevisionProvider = SessionsRevisionNotifierProvider._();

/// Single keepAlive revision tracker that is bumped whenever a session is
/// saved, finished, or discarded so derived providers only re-evaluate then.
final class SessionsRevisionNotifierProvider
    extends $NotifierProvider<SessionsRevisionNotifier, int> {
  /// Single keepAlive revision tracker that is bumped whenever a session is
  /// saved, finished, or discarded so derived providers only re-evaluate then.
  SessionsRevisionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsRevisionNotifierHash();

  @$internal
  @override
  SessionsRevisionNotifier create() => SessionsRevisionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionsRevisionNotifierHash() =>
    r'e55b081febbcbefc8eccbed729a09725e137df4f';

/// Single keepAlive revision tracker that is bumped whenever a session is
/// saved, finished, or discarded so derived providers only re-evaluate then.

abstract class _$SessionsRevisionNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Normalised selected month for the activity calendar (always Year, Month, 1).

@ProviderFor(SelectedMonthNotifier)
final selectedMonthProvider = SelectedMonthNotifierProvider._();

/// Normalised selected month for the activity calendar (always Year, Month, 1).
final class SelectedMonthNotifierProvider
    extends $NotifierProvider<SelectedMonthNotifier, DateTime> {
  /// Normalised selected month for the activity calendar (always Year, Month, 1).
  SelectedMonthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMonthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthNotifierHash();

  @$internal
  @override
  SelectedMonthNotifier create() => SelectedMonthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedMonthNotifierHash() =>
    r'589315428ac7c98953540b4b7dab0abed5d6c2b7';

/// Normalised selected month for the activity calendar (always Year, Month, 1).

abstract class _$SelectedMonthNotifier extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

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
    r'e4d969598527a95b486a881434913c7701356385';

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

/// Aggregates dashboard metrics for the current week and all-time
/// using indexed SQL aggregate queries.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])
/// - `activeDatesThisMonth` ([List<DateTime>])

@ProviderFor(dashboardMetrics)
final dashboardMetricsProvider = DashboardMetricsFamily._();

/// Aggregates dashboard metrics for the current week and all-time
/// using indexed SQL aggregate queries.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])
/// - `activeDatesThisMonth` ([List<DateTime>])

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
  /// Aggregates dashboard metrics for the current week and all-time
  /// using indexed SQL aggregate queries.
  ///
  /// Returns a map with keys:
  /// - `daysTrainedThisWeek` ([int])
  /// - `totalWorkoutsCompleted` ([int])
  /// - `totalCaloriesBurned` ([int])
  /// - `activeDatesThisMonth` ([List<DateTime>])
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

String _$dashboardMetricsHash() => r'c8c3c16ca748ecb87ae4e0a6d095238de0760a71';

/// Aggregates dashboard metrics for the current week and all-time
/// using indexed SQL aggregate queries.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])
/// - `activeDatesThisMonth` ([List<DateTime>])

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

  /// Aggregates dashboard metrics for the current week and all-time
  /// using indexed SQL aggregate queries.
  ///
  /// Returns a map with keys:
  /// - `daysTrainedThisWeek` ([int])
  /// - `totalWorkoutsCompleted` ([int])
  /// - `totalCaloriesBurned` ([int])
  /// - `activeDatesThisMonth` ([List<DateTime>])

  DashboardMetricsProvider call(IWorkoutSessionRepository sessionRepo) =>
      DashboardMetricsProvider._(argument: sessionRepo, from: this);

  @override
  String toString() => r'dashboardMetricsProvider';
}

/// Returns the set of [DateTime]s in the currently selected month on which
/// a workout session was started, for rendering the monthly activity calendar.
///
/// Keyed only by normalized month via [selectedMonthNotifierProvider].
/// Reuses the dashboard aggregates query for the current month.

@ProviderFor(calendarActivity)
final calendarActivityProvider = CalendarActivityFamily._();

/// Returns the set of [DateTime]s in the currently selected month on which
/// a workout session was started, for rendering the monthly activity calendar.
///
/// Keyed only by normalized month via [selectedMonthNotifierProvider].
/// Reuses the dashboard aggregates query for the current month.

final class CalendarActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTime>>,
          List<DateTime>,
          FutureOr<List<DateTime>>
        >
    with $FutureModifier<List<DateTime>>, $FutureProvider<List<DateTime>> {
  /// Returns the set of [DateTime]s in the currently selected month on which
  /// a workout session was started, for rendering the monthly activity calendar.
  ///
  /// Keyed only by normalized month via [selectedMonthNotifierProvider].
  /// Reuses the dashboard aggregates query for the current month.
  CalendarActivityProvider._({
    required CalendarActivityFamily super.from,
    required IWorkoutSessionRepository super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DateTime>> create(Ref ref) {
    final argument = this.argument as IWorkoutSessionRepository;
    return calendarActivity(ref, argument);
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

String _$calendarActivityHash() => r'65ee031096e4db4700a90852325e6476df33ffa9';

/// Returns the set of [DateTime]s in the currently selected month on which
/// a workout session was started, for rendering the monthly activity calendar.
///
/// Keyed only by normalized month via [selectedMonthNotifierProvider].
/// Reuses the dashboard aggregates query for the current month.

final class CalendarActivityFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DateTime>>,
          IWorkoutSessionRepository
        > {
  CalendarActivityFamily._()
    : super(
        retry: null,
        name: r'calendarActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns the set of [DateTime]s in the currently selected month on which
  /// a workout session was started, for rendering the monthly activity calendar.
  ///
  /// Keyed only by normalized month via [selectedMonthNotifierProvider].
  /// Reuses the dashboard aggregates query for the current month.

  CalendarActivityProvider call(IWorkoutSessionRepository sessionRepo) =>
      CalendarActivityProvider._(argument: sessionRepo, from: this);

  @override
  String toString() => r'calendarActivityProvider';
}

/// Returns up to 5 most recent workout sessions using an indexed LIMIT query.

@ProviderFor(recentWorkoutSessions)
final recentWorkoutSessionsProvider = RecentWorkoutSessionsFamily._();

/// Returns up to 5 most recent workout sessions using an indexed LIMIT query.

final class RecentWorkoutSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSession>>,
          List<WorkoutSession>,
          FutureOr<List<WorkoutSession>>
        >
    with
        $FutureModifier<List<WorkoutSession>>,
        $FutureProvider<List<WorkoutSession>> {
  /// Returns up to 5 most recent workout sessions using an indexed LIMIT query.
  RecentWorkoutSessionsProvider._({
    required RecentWorkoutSessionsFamily super.from,
    required IWorkoutSessionRepository super.argument,
  }) : super(
         retry: null,
         name: r'recentWorkoutSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentWorkoutSessionsHash();

  @override
  String toString() {
    return r'recentWorkoutSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSession>> create(Ref ref) {
    final argument = this.argument as IWorkoutSessionRepository;
    return recentWorkoutSessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentWorkoutSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentWorkoutSessionsHash() =>
    r'6c833615ed208da0346ea97c54d9651bfc772059';

/// Returns up to 5 most recent workout sessions using an indexed LIMIT query.

final class RecentWorkoutSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WorkoutSession>>,
          IWorkoutSessionRepository
        > {
  RecentWorkoutSessionsFamily._()
    : super(
        retry: null,
        name: r'recentWorkoutSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns up to 5 most recent workout sessions using an indexed LIMIT query.

  RecentWorkoutSessionsProvider call(IWorkoutSessionRepository sessionRepo) =>
      RecentWorkoutSessionsProvider._(argument: sessionRepo, from: this);

  @override
  String toString() => r'recentWorkoutSessionsProvider';
}
