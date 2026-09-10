// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_logic_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(durationCalculation)
final durationCalculationProvider = DurationCalculationFamily._();

final class DurationCalculationProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
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
    r'74d9a9ec3d842c7a23c048e422a0d77c7bdba00c';

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

  DurationCalculationProvider call(List<ScheduleExercise> exercises) =>
      DurationCalculationProvider._(argument: exercises, from: this);

  @override
  String toString() => r'durationCalculationProvider';
}

@ProviderFor(splitRecommendation)
final splitRecommendationProvider = SplitRecommendationFamily._();

final class SplitRecommendationProvider
    extends
        $FunctionalProvider<
          AsyncValue<Schedule?>,
          Schedule?,
          FutureOr<Schedule?>
        >
    with $FutureModifier<Schedule?>, $FutureProvider<Schedule?> {
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
    r'f5385cbfea4bd8eb1db616ce88d162d9c6e5613a';

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

@ProviderFor(dashboardMetrics)
final dashboardMetricsProvider = DashboardMetricsFamily._();

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

String _$dashboardMetricsHash() => r'fd49bd772c749883b87ec49cdf7b29a7f3de22f2';

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

  DashboardMetricsProvider call(IWorkoutSessionRepository sessionRepo) =>
      DashboardMetricsProvider._(argument: sessionRepo, from: this);

  @override
  String toString() => r'dashboardMetricsProvider';
}

@ProviderFor(calendarActivity)
final calendarActivityProvider = CalendarActivityFamily._();

final class CalendarActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTime>>,
          List<DateTime>,
          FutureOr<List<DateTime>>
        >
    with $FutureModifier<List<DateTime>>, $FutureProvider<List<DateTime>> {
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

String _$calendarActivityHash() => r'c56abaa092b8e150c700f0b3365ef7b665ef67e9';

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

  CalendarActivityProvider call(
    IWorkoutSessionRepository sessionRepo,
    DateTime month,
  ) => CalendarActivityProvider._(argument: (sessionRepo, month), from: this);

  @override
  String toString() => r'calendarActivityProvider';
}
