import 'package:flutter/material.dart';

import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import 'modal_backdrop_helper.dart';

/// Shows the modernized "Leave without saving?" confirmation modal
/// with full backdrop blur and frosted glass matching the Stitch design system.
/// Returns `true` if the user confirms leaving, `false` otherwise.
Future<bool> showLeaveWithoutSavingModal(BuildContext context) async {
  final result = await showBlurBottomSheet<bool>(
    context: context,
    child: const _LeaveWithoutSavingCard(),
  );
  return result ?? false;
}

class _LeaveWithoutSavingCard extends StatefulWidget {
  const _LeaveWithoutSavingCard();

  @override
  State<_LeaveWithoutSavingCard> createState() =>
      _LeaveWithoutSavingCardState();
}

class _LeaveWithoutSavingCardState extends State<_LeaveWithoutSavingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final isDark = context.isDark;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: GlassSurface(
            tier: FtGlassTier.glassFloating,
            radius: 32,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              bottomInset + (bottomPadding > 0 ? 8 : 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag Affordance ─────────────────────────────────────────
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Top Bar: Warning Badge + Close Button ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(
                          alpha: isDark ? 0.16 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, _) => Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF43F5E).withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: _pulseAnim.value,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'UNSAVED SUMMARY',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              color: Color(0xFFE11D48),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FtPressable(
                      onTap: () => Navigator.of(context).pop(false),
                      pressedScale: 0.90,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Hero Icon with Subtle Pulse ─────────────────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF43F5E),
                          Color(0xFFE11D48),
                          Color(0xFFBE123C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                          blurRadius: 16 + _pulseAnim.value * 2,
                          spreadRadius: _pulseAnim.value * 0.6,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Title & Description ─────────────────────────────────────
                Text(
                  'Leave without saving?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    color: ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Your workout summary will not be saved if you leave now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Action Buttons ──────────────────────────────────────────
                // Primary: Stay on Summary
                FtPressable(
                  onTap: () => Navigator.of(context).pop(false),
                  pressedScale: 0.98,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          Color.lerp(primary, Colors.white, 0.12) ?? primary,
                          Color.lerp(primary, Colors.black, 0.15) ?? primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Stay on Summary',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Destructive: Leave without Saving
                FtPressable(
                  onTap: () => Navigator.of(context).pop(true),
                  pressedScale: 0.98,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF43F5E).withValues(
                          alpha: isDark ? 0.35 : 0.30,
                        ),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFFE11D48),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Leave without Saving',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Microcopy ───────────────────────────────────────────────
                Text(
                  'Tap outside or swipe down to cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    color: muted.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
