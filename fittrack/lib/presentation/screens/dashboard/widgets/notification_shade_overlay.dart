import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notifications_provider.dart';
import '../../../providers/notification_settings_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'ft_pressable.dart';

class NotificationShadeOverlay extends ConsumerStatefulWidget {
  const NotificationShadeOverlay({super.key});

  @override
  ConsumerState<NotificationShadeOverlay> createState() =>
      _NotificationShadeOverlayState();
}

class _NotificationShadeOverlayState
    extends ConsumerState<NotificationShadeOverlay> {
  final Set<String> _clearingItemIds = {};
  bool _isClearingAll = false;
  double _verticalDragDistance = 0.0;

  void _closeShade() {
    if (_isClearingAll) return;
    final haptics = ref.read(notificationSettingsProvider).hapticsEnabled;
    if (haptics) {
      HapticFeedback.lightImpact();
    }
    ref.read(notificationShadeProvider.notifier).close();
  }

  /// Triggers Android-style staggered cascade dismissal with haptics for each card,
  /// then clears the state and collapses the shade overlay.
  Future<void> _handleClearAllAnimated(List<FtNotificationItem> items) async {
    if (_isClearingAll || items.isEmpty) return;
    setState(() => _isClearingAll = true);

    bool haptics = true;
    try {
      haptics = ref.read(notificationSettingsProvider).hapticsEnabled;
    } catch (_) {}

    for (int i = 0; i < items.length; i++) {
      if (!mounted) return;
      if (haptics) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _clearingItemIds.add(items[i].id);
      });
      await Future.delayed(const Duration(milliseconds: 65));
    }

    // Wait for the last card slide animation to complete
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    ref.read(notificationFeedProvider.notifier).clearAll();
    if (haptics) {
      HapticFeedback.mediumImpact();
    }
    ref.read(notificationShadeProvider.notifier).close();

    if (mounted) {
      setState(() {
        _clearingItemIds.clear();
        _isClearingAll = false;
      });
    }
  }

  Alignment _getAlignment(BuildContext context, Offset? origin) {
    if (origin == null) return const Alignment(0.74, -0.94);
    final size = MediaQuery.sizeOf(context);
    if (size.width == 0 || size.height == 0) {
      return const Alignment(0.74, -0.94);
    }
    final x = (origin.dx / size.width) * 2.0 - 1.0;
    final y = (origin.dy / size.height) * 2.0 - 1.0;
    return Alignment(x.clamp(-1.0, 1.0), y.clamp(-1.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final shadeState = ref.watch(notificationShadeProvider);
    final items = ref.watch(notificationFeedProvider);
    final feedNotifier = ref.read(notificationFeedProvider.notifier);
    final isOpen = shadeState.isOpen;

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
              // 1. Blurred Frosted Backdrop Scrim (Tap or swipe up to close)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeShade,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < -140) {
                      _closeShade();
                    }
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

              // 2. Centered 393px Full-Height Frosted Notification Shade
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 393),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      child: Transform.scale(
                        scale: 0.12 + (0.88 * progress),
                        alignment: _getAlignment(context, shadeState.origin),
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (_) {
            _verticalDragDistance = 0.0;
          },
          onVerticalDragUpdate: (details) {
            _verticalDragDistance += details.primaryDelta ?? 0.0;
            // Swipe up anywhere in the body collapses the shade
            if (_verticalDragDistance < -50) {
              _closeShade();
              _verticalDragDistance = 0.0;
            }
          },
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -140) {
              _closeShade();
            }
          },
          child: GlassSurface(
            tier: FtGlassTier.glassFloating,
            radius: 30.0,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: "Notifications" Title + "Close" Button ─────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Notifications',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: context.ftInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (items.isNotEmpty)
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
                                '${items.length}',
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
                    ),
                    // Close button in header (replaces top clear all)
                    FtPressable(
                      onTap: _closeShade,
                      pressedScale: 0.95,
                      child: GlassSurface(
                        tier: FtGlassTier.glass2,
                        radius: 999,
                        shadow: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: context.ftInk,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Close',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: context.ftInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Notification Toast List (Swipe to Discard / Expandable) ─
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyState(context)
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // Detect swipe-up overscroll on the list to dismiss
                            if (notification is OverscrollNotification &&
                                notification.overscroll > 12) {
                              _closeShade();
                              return true;
                            }
                            if (notification is ScrollEndNotification &&
                                (notification.dragDetails?.primaryVelocity ?? 0) <
                                    -200) {
                              _closeShade();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 2, bottom: 8),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isClearingThis =
                                  _clearingItemIds.contains(item.id);

                              return AnimatedSlide(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInCubic,
                                offset: isClearingThis
                                    ? const Offset(1.35, 0.0)
                                    : Offset.zero,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeIn,
                                  opacity: isClearingThis ? 0.0 : 1.0,
                                  child: _SwipeableToastNotificationTile(
                                    key: ValueKey(item.id),
                                    item: item,
                                    onDismissed: () {
                                      feedNotifier.dismiss(item.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),

                // ── Bottom "Clear all" Button (moved to bottom) ────────────
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: FtPressable(
                        onTap: () => _handleClearAllAnimated(items),
                        pressedScale: 0.95,
                        child: GlassSurface(
                          tier: FtGlassTier.glass2,
                          radius: 999,
                          shadow: false,
                          borderTint:
                              context.ftPrimary.withValues(alpha: 0.22),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.clear_all_rounded,
                                size: 16,
                                color: context.ftPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: context.ftPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Bottom Grab Handle to Collapse Shade ────────────────────
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeShade,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) < -120) {
                      _closeShade();
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
            'Swipe up anywhere to close shade',
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

/// Expandable and swipeable notification card with:
/// - In-flight haptic feedback when crossing the dismiss threshold.
/// - Clean clipping so delete color does not bleed around rounded corners.
/// - Opaque card backing to prevent background color leakage through frosted glass.
/// - Expandable on tap: closed by default, separates into title and full body when expanded.
class _SwipeableToastNotificationTile extends ConsumerStatefulWidget {
  final FtNotificationItem item;
  final VoidCallback onDismissed;

  const _SwipeableToastNotificationTile({
    super.key,
    required this.item,
    required this.onDismissed,
  });

  @override
  ConsumerState<_SwipeableToastNotificationTile> createState() =>
      _SwipeableToastNotificationTileState();
}

class _SwipeableToastNotificationTileState
    extends ConsumerState<_SwipeableToastNotificationTile> {
  bool _isExpanded = false;
  bool _hasTriggeredHaptic = false;

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark ? const Color(0xFF1E1A34) : Colors.white;
    bool haptics = true;
    try {
      haptics = ref.read(notificationSettingsProvider).hapticsEnabled;
    } catch (_) {}

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Dismissible(
        key: ValueKey('dismiss_${widget.item.id}'),
        direction: DismissDirection.horizontal,
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.28,
          DismissDirection.endToStart: 0.28,
        },
        resizeDuration: const Duration(milliseconds: 220),
        movementDuration: const Duration(milliseconds: 260),
        onUpdate: (details) {
          // Tactile haptic feedback WHILE dismissing instead of only after dismissed
          if (details.reached && !_hasTriggeredHaptic) {
            _hasTriggeredHaptic = true;
            if (haptics) {
              HapticFeedback.mediumImpact();
            }
          } else if (!details.reached && _hasTriggeredHaptic) {
            _hasTriggeredHaptic = false;
          }
        },
        onDismissed: (_) {
          if (haptics) {
            HapticFeedback.selectionClick();
          }
          widget.onDismissed();
        },
        background: _buildSwipeBackground(Alignment.centerLeft),
        secondaryBackground: _buildSwipeBackground(Alignment.centerRight),
        child: GestureDetector(
          onTap: () {
            if (haptics) {
              HapticFeedback.selectionClick();
            }
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: context.ftPrimary.withValues(alpha: 0.16),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: _isExpanded
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: _isExpanded ? 2.0 : 0.0),
                      child: _buildLeadingIcon(context, widget.item.type),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isExpanded
                          ? _buildExpandedContent(context)
                          : _buildCollapsedContent(context),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: context.ftMuted.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Collapsed view: Single compact line with title and body.
  Widget _buildCollapsedContent(BuildContext context) {
    return RichText(
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
            text: '${widget.item.title} ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: widget.item.body,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Expanded view: Separated distinct title and body lines with timestamp.
  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.item.title,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: context.ftInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.item.body,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: context.ftMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatTimeAgo(widget.item.timestamp),
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: context.ftPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: FtGlassTheme.rose,
      child: const Icon(
        Icons.delete_outline_rounded,
        size: 20,
        color: Colors.white,
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
      case FtNotificationType.workoutComplete:
        return const Icon(
          Icons.flag_rounded,
          size: 16,
          color: FtGlassTheme.teal,
        );
      case FtNotificationType.restOver:
        return const Icon(
          Icons.timer_rounded,
          size: 16,
          color: FtGlassTheme.orange,
        );
      case FtNotificationType.reminder:
        return const Icon(
          Icons.notifications_rounded,
          size: 16,
          color: Color(0xFF818CF8),
        );
      case FtNotificationType.summary:
        return const Icon(
          Icons.bar_chart_rounded,
          size: 16,
          color: Color(0xFF34D399),
        );
      case FtNotificationType.system:
        return const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: Colors.white54,
        );
    }
  }
}
