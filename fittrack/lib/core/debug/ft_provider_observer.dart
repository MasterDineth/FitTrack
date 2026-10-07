import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug/profile-mode ProviderObserver that tracks creation, disposal,
/// and update counts per provider name to diagnose provider lifecycle issues.
base class FtProviderObserver extends ProviderObserver {
  final Map<String, int> addCounts = {};
  final Map<String, int> disposeCounts = {};
  final Map<String, int> updateCounts = {};

  String _providerName(ProviderObserverContext context) {
    return context.provider.name ?? context.provider.runtimeType.toString();
  }

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    final name = _providerName(context);
    addCounts[name] = (addCounts[name] ?? 0) + 1;
    debugPrint(
      '[FT_OBSERVER] didAddProvider: $name (total created: ${addCounts[name]})',
    );
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    final name = _providerName(context);
    disposeCounts[name] = (disposeCounts[name] ?? 0) + 1;
    debugPrint(
      '[FT_OBSERVER] didDisposeProvider: $name (total disposed: ${disposeCounts[name]})',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final name = _providerName(context);
    updateCounts[name] = (updateCounts[name] ?? 0) + 1;
    debugPrint(
      '[FT_OBSERVER] didUpdateProvider: $name (total updates: ${updateCounts[name]})',
    );
  }

  void dumpSummary() {
    debugPrint('=== [FT_OBSERVER] PROVIDER LIFECYCLE SUMMARY ===');
    final allNames = {
      ...addCounts.keys,
      ...disposeCounts.keys,
      ...updateCounts.keys,
    }.toList()
      ..sort();
    for (final name in allNames) {
      debugPrint(
        '  $name -> Added: ${addCounts[name] ?? 0}, Disposed: ${disposeCounts[name] ?? 0}, Updated: ${updateCounts[name] ?? 0}',
      );
    }
    debugPrint('================================================');
  }
}
