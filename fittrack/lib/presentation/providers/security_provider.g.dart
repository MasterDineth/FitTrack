// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SecurityNotifier)
final securityProvider = SecurityNotifierProvider._();

final class SecurityNotifierProvider
    extends $NotifierProvider<SecurityNotifier, SecurityState> {
  SecurityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityNotifierHash();

  @$internal
  @override
  SecurityNotifier create() => SecurityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityState>(value),
    );
  }
}

String _$securityNotifierHash() => r'4c2f3ffa4911644da52b067d5c58b00e2c15a623';

abstract class _$SecurityNotifier extends $Notifier<SecurityState> {
  SecurityState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SecurityState, SecurityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SecurityState, SecurityState>,
              SecurityState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
