// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_editor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleEditorNotifier)
final scheduleEditorProvider = ScheduleEditorNotifierProvider._();

final class ScheduleEditorNotifierProvider
    extends $NotifierProvider<ScheduleEditorNotifier, ScheduleEditorState> {
  ScheduleEditorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleEditorNotifierHash();

  @$internal
  @override
  ScheduleEditorNotifier create() => ScheduleEditorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleEditorState>(value),
    );
  }
}

String _$scheduleEditorNotifierHash() =>
    r'f23643847e653b6f10058ca6e4ee5b21059da9a9';

abstract class _$ScheduleEditorNotifier extends $Notifier<ScheduleEditorState> {
  ScheduleEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScheduleEditorState, ScheduleEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScheduleEditorState, ScheduleEditorState>,
              ScheduleEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
