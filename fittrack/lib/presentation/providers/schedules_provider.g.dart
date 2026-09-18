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

String _$schedulesNotifierHash() => r'5d546f56f02b8b59f70facad6c6d0341c488924d';

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
