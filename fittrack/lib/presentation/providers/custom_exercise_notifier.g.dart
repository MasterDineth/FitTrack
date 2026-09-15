// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomExerciseNotifier)
final customExerciseProvider = CustomExerciseNotifierProvider._();

final class CustomExerciseNotifierProvider
    extends $NotifierProvider<CustomExerciseNotifier, CustomExerciseState> {
  CustomExerciseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customExerciseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customExerciseNotifierHash();

  @$internal
  @override
  CustomExerciseNotifier create() => CustomExerciseNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomExerciseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomExerciseState>(value),
    );
  }
}

String _$customExerciseNotifierHash() =>
    r'a2634ea990ca881c583f50b0b64bfc74a230d8dc';

abstract class _$CustomExerciseNotifier extends $Notifier<CustomExerciseState> {
  CustomExerciseState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CustomExerciseState, CustomExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CustomExerciseState, CustomExerciseState>,
              CustomExerciseState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
