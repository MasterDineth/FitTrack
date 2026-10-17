import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_header_avatar.dart';
import '../../../providers/notifications_provider.dart';
import '../../../providers/notification_settings_provider.dart';

class DashboardHeader extends ConsumerStatefulWidget {
  const DashboardHeader({super.key});

  @override
  ConsumerState<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends ConsumerState<DashboardHeader>
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

  void _triggerIslandAnimations(FtNotificationItem? activeItem) {
    final haptics = _isHapticsEnabled();
    if (activeItem != null && activeItem.id != _lastIslandItemId) {
      _lastIslandItemId = activeItem.id;
      if (haptics) {
        HapticFeedback.mediumImpact();
      }
      _bellSwingController.repeat(reverse: true);
      _progressController.forward(from: 0.0);
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

  @override
  Widget build(BuildContext context) {
    final activeIslandItem = ref.watch(notificationIslandProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final isExpanded = activeIslandItem != null;

    _triggerIslandAnimations(activeIslandItem);

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeaderWidth = constraints.maxWidth;

          return SizedBox(
            height: 54,
            width: maxHeaderWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Left: Brand Mark + Name (Fades & scales smoothly when Island expands)
                Positioned(
                  left: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    opacity: isExpanded ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 280),
                      scale: isExpanded ? 0.92 : 1.0,
                      alignment: Alignment.centerLeft,
                      child: IgnorePointer(
                        ignoring: isExpanded,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/dashboard/brand_mark.webp',
                                width: 32,
                                height: 32,
                                cacheWidth: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'FitTrack',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.55,
                                color: context.ftInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Far Right: 36x36 User Avatar (Fades out while Island spans header)
                Positioned(
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    opacity: isExpanded ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 260),
                      scale: isExpanded ? 0.85 : 1.0,
                      child: IgnorePointer(
                        ignoring: isExpanded,
                        child: const FtHeaderAvatar(),
                      ),
                    ),
                  ),
                ),

                // 3. Morphing Frosted Notification Island (40x40 Circle <-> Full Width Pill)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 460),
                  curve: Curves.easeOutCubic,
                  right: isExpanded ? 0.0 : 44.0,
                  width: isExpanded ? maxHeaderWidth : 40.0,
                  height: isExpanded ? 52.0 : 40.0,
                  child: Builder(
                    builder: (bellContext) => GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled()) {
                          HapticFeedback.lightImpact();
                        }
                        final renderBox =
                            bellContext.findRenderObject() as RenderBox?;
                        Offset? origin;
                        if (renderBox != null && renderBox.hasSize) {
                          origin = renderBox.localToGlobal(
                            renderBox.size.center(Offset.zero),
                          );
                        }
                        ref
                            .read(notificationShadeProvider.notifier)
                            .open(origin: origin);
                      },
                      child: GlassSurface(
                      tier: isExpanded
                          ? FtGlassTier.glassFloating
                          : FtGlassTier.glass2,
                      radius: isExpanded ? 20.0 : 20.0,
                      width: isExpanded ? maxHeaderWidth : 40.0,
                      height: isExpanded ? 52.0 : 40.0,
                      shadow: isExpanded,
                      borderTint: isExpanded
                          ? context.ftPrimary.withValues(alpha: 0.25)
                          : null,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: isExpanded
                              ? _buildExpandedIslandContent(
                                  context,
                                  activeIslandItem,
                                  maxHeaderWidth,
                                )
                              : _buildCollapsedBellContent(
                                  context,
                                  unreadCount,
                                ),
                        ),
                      ),
                    ),
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

  Widget _buildCollapsedBellContent(BuildContext context, int unreadCount) {
    return SizedBox(
      key: const ValueKey('island_collapsed'),
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 20,
            color: context.ftInk,
          ),
          if (unreadCount > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.ftPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedIslandContent(
    BuildContext context,
    FtNotificationItem item,
    double maxHeaderWidth,
  ) {
    return Stack(
      key: ValueKey('island_expanded_${item.id}'),
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
                          final angle =
                              math.sin(_bellSwingController.value * math.pi * 2) *
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
                              style: const TextStyle(fontWeight: FontWeight.w800),
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
                          ref.read(notificationIslandProvider.notifier).collapse();
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
    );
  }
}
