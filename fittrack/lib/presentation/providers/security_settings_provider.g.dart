// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier managing [SecuritySettings] state and persistence.

@ProviderFor(SecuritySettingsNotifier)
final securitySettingsProvider = SecuritySettingsNotifierProvider._();

/// Riverpod notifier managing [SecuritySettings] state and persistence.
final class SecuritySettingsNotifierProvider
    extends $AsyncNotifierProvider<SecuritySettingsNotifier, SecuritySettings> {
  /// Riverpod notifier managing [SecuritySettings] state and persistence.
  SecuritySettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securitySettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securitySettingsNotifierHash();

  @$internal
  @override
  SecuritySettingsNotifier create() => SecuritySettingsNotifier();
}

String _$securitySettingsNotifierHash() =>
    r'baa63613aaec73342efaa8e10bbaf3aee82f6fb9';

/// Riverpod notifier managing [SecuritySettings] state and persistence.

abstract class _$SecuritySettingsNotifier
    extends $AsyncNotifier<SecuritySettings> {
  FutureOr<SecuritySettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SecuritySettings>, SecuritySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SecuritySettings>, SecuritySettings>,
              AsyncValue<SecuritySettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
