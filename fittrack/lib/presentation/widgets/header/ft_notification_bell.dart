import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notifications_provider.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import 'ft_header_tokens.dart';

/// Circular frosted glass notification bell button with unread pip
/// and origin-aware opening of the global notification shade.
class FtNotificationBell extends ConsumerWidget {
  const FtNotificationBell({super.key});

  void _handleTap(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final renderBox = context.findRenderObject() as RenderBox?;
    Offset? origin;
    if (renderBox != null && renderBox.hasSize) {
      origin = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    }
    try {
      ref.read(notificationShadeProvider.notifier).open(origin: origin);
    } catch (_) {
      // Graceful fallback when notificationShadeProvider is not in scope
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int unreadCount = 0;
    try {
      unreadCount = ref.watch(unreadNotificationCountProvider);
    } catch (_) {
      // Graceful fallback for widget tests without ProviderScope
    }

    return Semantics(
      button: true,
      label: 'Notifications, $unreadCount unread',
      child: FtPressable(
        onTap: () => _handleTap(context, ref),
        pressedScale: 0.95,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: FtHeaderTokens.minTouchTarget,
            minHeight: FtHeaderTokens.minTouchTarget,
          ),
          child: Center(
            child: SizedBox(
              width: FtHeaderTokens.bellVisualSize,
              height: FtHeaderTokens.bellVisualSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GlassSurface(
                    tier: FtGlassTier.glass2,
                    radius: FtHeaderTokens.bellVisualSize / 2,
                    width: FtHeaderTokens.bellVisualSize,
                    height: FtHeaderTokens.bellVisualSize,
                    shadow: false,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: context.ftInk,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: FtHeaderTokens.badgeSize,
                        height: FtHeaderTokens.badgeSize,
                        decoration: BoxDecoration(
                          color: context.ftPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: FtHeaderTokens.badgeRingWidth,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
