import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notification_settings_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import 'ft_header_tokens.dart';
import 'ft_notification_bell.dart';

/// Reusable universal in-header dynamic island header.
///
/// Features:
/// - In-header choreography: morphs the 40x40 resting bell into a full-width
///   frosted dynamic island pill on notification arrival.
/// - Left-side content (`leftChild`) and right-side avatar (`trailing`) smoothly
///   fade and scale down during expansion.
/// - Oscillating bell swing animation and auto-collapse progress line.
/// - Swipe-up to dismiss and explicit dismiss button.
/// - Respects `MediaQuery.disableAnimationsOf(context)` and `TickerMode.valuesOf(context)`.
class FtDynamicHeader extends ConsumerStatefulWidget {
  final Widget leftChild;
  final Widget? trailing;
  final double height;
  final EdgeInsetsGeometry padding;

  const FtDynamicHeader({
    super.key,
    required this.leftChild,
    this.trailing,
    this.height = 54.0,
    this.padding = const EdgeInsets.only(top: FtHeaderTokens.topPadding),
  });

  @override
  ConsumerState<FtDynamicHeader> createState() => _FtDynamicHeaderState();
}

class _FtDynamicHeaderState extends ConsumerState<FtDynamicHeader>
    with TickerProviderStateMixin {
  late final AnimationController _bellSwingController;
  late final AnimationController _progressController;
  String? _lastIslandItemId;

  @override
  void initState() {
    super.initState();
    _bellSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (!tickerEnabled) {
      if (_bellSwingController.isAnimating) _bellSwingController.stop();
      if (_progressController.isAnimating) _progressController.stop();
    }
  }

  @override
  void dispose() {
    _bellSwingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  bool _isHapticsEnabled() {
    try {
      return ref.read(notificationSettingsProvider).hapticsEnabled;
    } catch (_) {
      return true;
    }
  }

  void _triggerIslandAnimations(
    FtNotificationItem? activeItem,
    bool disableAnimations,
  ) {
    final haptics = _isHapticsEnabled();
    if (activeItem != null && activeItem.id != _lastIslandItemId) {
      _lastIslandItemId = activeItem.id;
      if (haptics) {
        HapticFeedback.mediumImpact();
      }
      if (!disableAnimations) {
        _bellSwingController.repeat(reverse: true);
        _progressController.forward(from: 0.0);
      }
    } else if (activeItem == null && _lastIslandItemId != null) {
      _lastIslandItemId = null;
      _bellSwingController.stop();
      _bellSwingController.reset();
      _progressController.stop();
      if (haptics) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _handleOpenShade(BuildContext bellContext) {
    if (_isHapticsEnabled()) {
      HapticFeedback.lightImpact();
    }
    final renderBox = bellContext.findRenderObject() as RenderBox?;
    Offset? origin;
    if (renderBox != null && renderBox.hasSize) {
      origin = renderBox.localToGlobal(
        renderBox.size.center(Offset.zero),
      );
    }
    try {
      ref.read(notificationShadeProvider.notifier).open(origin: origin);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    FtNotificationItem? activeIslandItem;
    try {
      activeIslandItem = ref.watch(notificationIslandProvider);
    } catch (_) {
      // Graceful fallback for isolated widget tests without ProviderScope
    }
    final isExpanded = activeIslandItem != null;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    _triggerIslandAnimations(activeIslandItem, disableAnimations);

    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 460);
    final fadeDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 240);

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeaderWidth = constraints.maxWidth;
          final rightActionWidth = widget.trailing != null
              ? (FtHeaderTokens.avatarVisualSize +
                  FtHeaderTokens.clusterGap +
                  FtHeaderTokens.bellVisualSize)
              : FtHeaderTokens.bellVisualSize;

          return SizedBox(
            height: widget.height,
            width: maxHeaderWidth,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                // 1. Left-Hand Layer (Title/Back Button)
                Positioned(
                  left: 0,
                  right: isExpanded
                      ? 0
                      : (rightActionWidth + FtHeaderTokens.clusterGap),
                  child: AnimatedOpacity(
                    duration: fadeDuration,
                    curve: Curves.easeOut,
                    opacity: isExpanded ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      scale: isExpanded ? 0.92 : 1.0,
                      alignment: Alignment.centerLeft,
                      child: IgnorePointer(
                        ignoring: isExpanded,
                        child: widget.leftChild,
                      ),
                    ),
                  ),
                ),

                // 2. Right-Hand Layer (Trailing Avatar)
                if (widget.trailing != null)
                  Positioned(
                    right: 0,
                    child: AnimatedOpacity(
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      opacity: isExpanded ? 0.0 : 1.0,
                      child: AnimatedScale(
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 260),
                        scale: isExpanded ? 0.85 : 1.0,
                        child: IgnorePointer(
                          ignoring: isExpanded,
                          child: widget.trailing!,
                        ),
                      ),
                    ),
                  ),

                // 3. Morphing Frosted Notification Island (Resting Bell <-> Full Width Pill)
                AnimatedPositioned(
                  duration: animDuration,
                  curve: Curves.easeOutCubic,
                  right: isExpanded
                      ? 0.0
                      : (widget.trailing != null
                          ? (FtHeaderTokens.avatarVisualSize +
                              FtHeaderTokens.clusterGap)
                          : 0.0),
                  width: isExpanded
                      ? maxHeaderWidth
                      : FtHeaderTokens.bellVisualSize,
                  height: isExpanded ? 52.0 : FtHeaderTokens.bellVisualSize,
                  child: AnimatedSwitcher(
                    duration: disableAnimations
                        ? const Duration(milliseconds: 1)
                        : const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: isExpanded
                        ? _buildExpandedIsland(
                            context,
                            activeIslandItem!,
                            maxHeaderWidth,
                          )
                        : const FtNotificationBell(
                            key: ValueKey('dynamic_island_collapsed_bell'),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedIsland(
    BuildContext context,
    FtNotificationItem item,
    double maxHeaderWidth,
  ) {
    return Builder(
      builder: (islandContext) => GestureDetector(
        key: ValueKey('dynamic_island_expanded_${item.id}'),
        onTap: () => _handleOpenShade(islandContext),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -100) {
            if (_isHapticsEnabled()) {
              HapticFeedback.selectionClick();
            }
            ref.read(notificationIslandProvider.notifier).collapse();
          }
        },
        child: GlassSurface(
          tier: FtGlassTier.glassFloating,
          radius: 20.0,
          width: maxHeaderWidth,
          height: 52.0,
          shadow: true,
          borderTint: context.ftPrimary.withValues(alpha: 0.25),
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: _buildExpandedIslandContent(context, item, maxHeaderWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedIslandContent(
    BuildContext context,
    FtNotificationItem item,
    double maxHeaderWidth,
  ) {
    return Semantics(
      liveRegion: true,
      label: 'Notification: ${item.title}, ${item.body}',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: math.max(0.0, maxHeaderWidth - 24.0),
                  child: Row(
                    children: [
                      // Animated Swinging Bell / Category Badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.ftPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.ftPrimary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: _bellSwingController,
                          builder: (context, child) {
                            final disableAnims =
                                MediaQuery.disableAnimationsOf(context);
                            final angle = disableAnims
                                ? 0.0
                                : math.sin(
                                        _bellSwingController.value *
                                            math.pi *
                                            2) *
                                    0.26;
                            return Transform.rotate(
                              angle: angle,
                              alignment: Alignment.topCenter,
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.notifications_active_rounded,
                            size: 16,
                            color: context.ftPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Single-Line Toast Content
                      Flexible(
                        child: Text(
                          '${item.title} ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: context.ftInk,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.ftMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Manual Dismiss Button
                      Semantics(
                        button: true,
                        label: 'Dismiss notification',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (_isHapticsEnabled()) {
                              HapticFeedback.selectionClick();
                            }
                            ref
                                .read(notificationIslandProvider.notifier)
                                .collapse();
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.ftInk.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: context.ftMuted,
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

          // Bottom Auto-Collapse Depletion Progress Bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) {
                final remainingFraction =
                    (1.0 - _progressController.value).clamp(0.0, 1.0);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: remainingFraction,
                    child: Container(
                      height: 2.2,
                      decoration: BoxDecoration(
                        color: context.ftPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
