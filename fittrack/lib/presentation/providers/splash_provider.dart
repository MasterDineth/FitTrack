import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Flipped to true by the splash screen once its intro AND exit animation
/// have finished. The router keeps the user on /splash until then, so the
/// splash controls its own hand-off.
class SplashDoneNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() => state = true;
}

final splashDoneProvider =
    NotifierProvider<SplashDoneNotifier, bool>(SplashDoneNotifier.new);
