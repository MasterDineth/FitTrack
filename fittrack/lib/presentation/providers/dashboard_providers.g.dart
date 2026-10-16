// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches today's bio-metrics telemetry (Movement, Strain, Recovery).

@ProviderFor(bioMetrics)
final bioMetricsProvider = BioMetricsProvider._();

/// Fetches today's bio-metrics telemetry (Movement, Strain, Recovery).

final class BioMetricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyBioMetrics?>,
          DailyBioMetrics?,
          FutureOr<DailyBioMetrics?>
        >
    with $FutureModifier<DailyBioMetrics?>, $FutureProvider<DailyBioMetrics?> {
  /// Fetches today's bio-metrics telemetry (Movement, Strain, Recovery).
  BioMetricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bioMetricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bioMetricsHash();

  @$internal
  @override
  $FutureProviderElement<DailyBioMetrics?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailyBioMetrics?> create(Ref ref) {
    return bioMetrics(ref);
  }
}

String _$bioMetricsHash() => r'4ba4dfc1a9b13cec00207299a8478b1bc0a4e734';

/// Manages daily habit items and toggle mutations with SQLite persistence.

@ProviderFor(HabitsNotifier)
final habitsProvider = HabitsNotifierProvider._();

/// Manages daily habit items and toggle mutations with SQLite persistence.
final class HabitsNotifierProvider
    extends $AsyncNotifierProvider<HabitsNotifier, List<DailyHabit>> {
  /// Manages daily habit items and toggle mutations with SQLite persistence.
  HabitsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsNotifierHash();

  @$internal
  @override
  HabitsNotifier create() => HabitsNotifier();
}

String _$habitsNotifierHash() => r'0027389674fd521222c157ec217b2d4a1fe7545b';

/// Manages daily habit items and toggle mutations with SQLite persistence.

abstract class _$HabitsNotifier extends $AsyncNotifier<List<DailyHabit>> {
  FutureOr<List<DailyHabit>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DailyHabit>>, List<DailyHabit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DailyHabit>>, List<DailyHabit>>,
              AsyncValue<List<DailyHabit>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provides lifestyle and masterclass cards from local JSON asset.

@ProviderFor(lifestyleContent)
final lifestyleContentProvider = LifestyleContentProvider._();

/// Provides lifestyle and masterclass cards from local JSON asset.

final class LifestyleContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LifestyleArticle>>,
          List<LifestyleArticle>,
          FutureOr<List<LifestyleArticle>>
        >
    with
        $FutureModifier<List<LifestyleArticle>>,
        $FutureProvider<List<LifestyleArticle>> {
  /// Provides lifestyle and masterclass cards from local JSON asset.
  LifestyleContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lifestyleContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lifestyleContentHash();

  @$internal
  @override
  $FutureProviderElement<List<LifestyleArticle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LifestyleArticle>> create(Ref ref) {
    return lifestyleContent(ref);
  }
}

String _$lifestyleContentHash() => r'a0bad4c131e2bda2af42d3a76d879ff16e66875f';

/// Computes weekly momentum, 7-day strip, and streak from session data.

@ProviderFor(weeklyMomentum)
final weeklyMomentumProvider = WeeklyMomentumProvider._();

/// Computes weekly momentum, 7-day strip, and streak from session data.

final class WeeklyMomentumProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyMomentumData>,
          WeeklyMomentumData,
          FutureOr<WeeklyMomentumData>
        >
    with
        $FutureModifier<WeeklyMomentumData>,
        $FutureProvider<WeeklyMomentumData> {
  /// Computes weekly momentum, 7-day strip, and streak from session data.
  WeeklyMomentumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyMomentumProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyMomentumHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyMomentumData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyMomentumData> create(Ref ref) {
    return weeklyMomentum(ref);
  }
}

String _$weeklyMomentumHash() => r'0e379542f1723f4e1fe9b2e8efed5f1158c24dc6';

/// Aggregates weekly tonnage load and strain status.

@ProviderFor(weeklyLoad)
final weeklyLoadProvider = WeeklyLoadProvider._();

/// Aggregates weekly tonnage load and strain status.

final class WeeklyLoadProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyLoadData>,
          WeeklyLoadData,
          FutureOr<WeeklyLoadData>
        >
    with $FutureModifier<WeeklyLoadData>, $FutureProvider<WeeklyLoadData> {
  /// Aggregates weekly tonnage load and strain status.
  WeeklyLoadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyLoadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyLoadHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyLoadData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyLoadData> create(Ref ref) {
    return weeklyLoad(ref);
  }
}

String _$weeklyLoadHash() => r'ec9d5a37a38cb2411afc5ff0908534d32f689ee0';

/// Unread notification count for the header bell badge (reactive to notification list).

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Unread notification count for the header bell badge (reactive to notification list).

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Unread notification count for the header bell badge (reactive to notification list).
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadNotificationCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadNotificationCountHash() =>
    r'28ba1ddff2b4c33fd17e90b1f83dc57a8b06eeef';
