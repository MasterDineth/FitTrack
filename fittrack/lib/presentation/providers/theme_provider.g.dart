// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier managing [ThemeSettings] state and persistence.

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Riverpod notifier managing [ThemeSettings] state and persistence.
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeSettings> {
  /// Riverpod notifier managing [ThemeSettings] state and persistence.
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeSettings>(value),
    );
  }
}

String _$themeNotifierHash() => r'0a9c56287a9860ba9115b5820cbc1816765c26ac';

/// Riverpod notifier managing [ThemeSettings] state and persistence.

abstract class _$ThemeNotifier extends $Notifier<ThemeSettings> {
  ThemeSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeSettings, ThemeSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeSettings, ThemeSettings>,
              ThemeSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
