// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier managing [NotificationSettingsState] lifecycle and persistence.

@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsProvider = NotificationSettingsNotifierProvider._();

/// Riverpod notifier managing [NotificationSettingsState] lifecycle and persistence.
final class NotificationSettingsNotifierProvider
    extends
        $NotifierProvider<
          NotificationSettingsNotifier,
          NotificationSettingsState
        > {
  /// Riverpod notifier managing [NotificationSettingsState] lifecycle and persistence.
  NotificationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsNotifierHash();

  @$internal
  @override
  NotificationSettingsNotifier create() => NotificationSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettingsState>(value),
    );
  }
}

String _$notificationSettingsNotifierHash() =>
    r'680d84736939076f5e30a2b941aba802df03e0c4';

/// Riverpod notifier managing [NotificationSettingsState] lifecycle and persistence.

abstract class _$NotificationSettingsNotifier
    extends $Notifier<NotificationSettingsState> {
  NotificationSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<NotificationSettingsState, NotificationSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationSettingsState, NotificationSettingsState>,
              NotificationSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
