import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_providers.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'ft_pressable.dart';

class NotificationShadeOverlay extends ConsumerWidget {
  const NotificationShadeOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardNotificationsProvider);
    final notifier = ref.read(dashboardNotificationsProvider.notifier);
    final isOpen = state.isShadeOpen;

    return IgnorePointer(
      ignoring: !isOpen,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: isOpen ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          if (progress == 0.0 && !isOpen) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              // 1. Blurred Frosted Backdrop Scrim (Tap outside to close)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.closeShade();
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 14.0 * progress,
                      sigmaY: 14.0 * progress,
                    ),
                    child: Container(
                      color: (context.isDark
                              ? Colors.black
                              : const Color(0xFF1D1735))
                          .withValues(alpha: 0.18 * progress),
                    ),
                  ),
                ),
              ),

              // 2. Centered 393px Full-Height Frosted Notification Shade (Image 2 Box)
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 393),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      child: Transform.scale(
                        scale: 0.12 + (0.88 * progress),
                        alignment: const Alignment(0.74, -0.94),
                        child: Opacity(
                          opacity: progress.clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: GlassSurface(
          tier: FtGlassTier.glassFloating,
          radius: 30.0,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: Only "Notifications" Title + "Clear all" Button ────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.ftInk,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (state.items.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.ftPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${state.items.length}',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: context.ftPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (state.items.isNotEmpty)
                    FtPressable(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        notifier.clearAll();
                      },
                      pressedScale: 0.95,
                      child: GlassSurface(
                        tier: FtGlassTier.glass2,
                        radius: 999,
                        shadow: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: context.ftPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Notification Toast List (Swipe to Discard Only) ────────────
              Expanded(
                child: state.items.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only( top: 2, bottom: 12),
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _SwipeableToastNotificationTile(
                            key: ValueKey(item.id),
                            item: item,
                            onDismissed: () {
                              HapticFeedback.mediumImpact();
                              notifier.dismissItem(item.id);
                            },
                          );
                        },
                      ),
              ),

              // ── Bottom Grab Handle to Collapse Shade ──────────────────────
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.closeShade();
                },
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -120) {
                    HapticFeedback.lightImpact();
                    notifier.closeShade();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.ftMuted.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassSurface(
            tier: FtGlassTier.glass2,
            radius: 18,
            width: 48,
            height: 48,
            shadow: false,
            alignment: Alignment.center,
            child: Icon(
              Icons.done_all_rounded,
              size: 22,
              color: context.ftPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No notifications',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.ftInk,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Swipe down or use the test bar to push alerts',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact toast-like notification card with swipe-to-discard and NO individual X button.
class _SwipeableToastNotificationTile extends StatelessWidget {
  final FtNotificationItem item;
  final VoidCallback onDismissed;

  const _SwipeableToastNotificationTile({
    super.key,
    required this.item,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.28,
        DismissDirection.endToStart: 0.28,
      },
      resizeDuration: const Duration(milliseconds: 220),
      movementDuration: const Duration(milliseconds: 260),
      onDismissed: (_) => onDismissed(),
      background: _buildSwipeBackground(Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(Alignment.centerRight),
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 16.0,
        borderTint: context.ftPrimary.withValues(alpha: 0.16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _buildLeadingIcon(context, item.type),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    color: context.ftInk,
                  ),
                  children: [
                    TextSpan(
                      text: '${item.title} ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: item.body,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: FtGlassTheme.rose.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FtGlassTheme.rose.withValues(alpha: 0.35),
        ),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        size: 18,
        color: FtGlassTheme.rose,
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, FtNotificationType type) {
    switch (type) {
      case FtNotificationType.hydration:
        return const Icon(
          Icons.water_drop_rounded,
          size: 16,
          color: Color(0xFF0EA5E9),
        );
      case FtNotificationType.pr:
        return Icon(
          Icons.emoji_events_rounded,
          size: 16,
          color: context.ftPrimary,
        );
      case FtNotificationType.strain:
        return const Icon(
          Icons.bolt_rounded,
          size: 16,
          color: FtGlassTheme.orange,
        );
      case FtNotificationType.habit:
        return const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: FtGlassTheme.teal,
        );
    }
  }
}
