import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notifications_provider.dart';
import '../../screens/dashboard/widgets/notification_shade_overlay.dart';

/// App-wide host for the frosted [NotificationShadeOverlay].
///
/// Mounts the overlay with transparent Material semantics at the root navigation level,
/// and intercepts Android system back gestures (`WidgetsBindingObserver.didPopRoute`)
/// when the shade is open so back presses collapse the shade without popping the underlying route.
class GlobalNotificationShadeHost extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalNotificationShadeHost({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalNotificationShadeHost> createState() =>
      _GlobalNotificationShadeHostState();
}

class _GlobalNotificationShadeHostState
    extends ConsumerState<GlobalNotificationShadeHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final shadeState = ref.read(notificationShadeProvider);
    if (shadeState.isOpen) {
      ref.read(notificationShadeProvider.notifier).close();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        const Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: NotificationShadeOverlay(),
          ),
        ),
      ],
    );
  }
}
