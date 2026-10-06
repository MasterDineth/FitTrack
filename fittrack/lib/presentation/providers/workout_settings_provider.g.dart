// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier managing [WorkoutSettingsState] persistence and reactive updates.

@ProviderFor(WorkoutSettingsNotifier)
final workoutSettingsProvider = WorkoutSettingsNotifierProvider._();

/// Riverpod notifier managing [WorkoutSettingsState] persistence and reactive updates.
final class WorkoutSettingsNotifierProvider
    extends $NotifierProvider<WorkoutSettingsNotifier, WorkoutSettingsState> {
  /// Riverpod notifier managing [WorkoutSettingsState] persistence and reactive updates.
  WorkoutSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSettingsNotifierHash();

  @$internal
  @override
  WorkoutSettingsNotifier create() => WorkoutSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutSettingsState>(value),
    );
  }
}

String _$workoutSettingsNotifierHash() =>
    r'a75b51463b796cefb7d9ac8a41cc04b9f0662acf';

/// Riverpod notifier managing [WorkoutSettingsState] persistence and reactive updates.

abstract class _$WorkoutSettingsNotifier
    extends $Notifier<WorkoutSettingsState> {
  WorkoutSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkoutSettingsState, WorkoutSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutSettingsState, WorkoutSettingsState>,
              WorkoutSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
