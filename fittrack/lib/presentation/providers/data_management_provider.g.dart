// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier managing data backups, snapshot lists, and irreversible erase workflows.

@ProviderFor(DataManagementNotifier)
final dataManagementProvider = DataManagementNotifierProvider._();

/// Riverpod notifier managing data backups, snapshot lists, and irreversible erase workflows.
final class DataManagementNotifierProvider
    extends $NotifierProvider<DataManagementNotifier, DataManagementState> {
  /// Riverpod notifier managing data backups, snapshot lists, and irreversible erase workflows.
  DataManagementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataManagementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataManagementNotifierHash();

  @$internal
  @override
  DataManagementNotifier create() => DataManagementNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataManagementState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataManagementState>(value),
    );
  }
}

String _$dataManagementNotifierHash() =>
    r'a8c90c7fb023b46dce5f1c14521f1668a5f8a109';

/// Riverpod notifier managing data backups, snapshot lists, and irreversible erase workflows.

abstract class _$DataManagementNotifier extends $Notifier<DataManagementState> {
  DataManagementState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DataManagementState, DataManagementState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DataManagementState, DataManagementState>,
              DataManagementState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
