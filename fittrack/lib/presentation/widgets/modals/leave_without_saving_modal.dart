import 'package:flutter/material.dart';

import 'modal_backdrop_helper.dart';

/// Shows the modernized "Leave without saving?" confirmation modal
/// with full backdrop blur matching the Stitch design system.
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

  static const Color _mint = Color(0xFF00D68F);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _rose500 = Color(0xFFEF4444);
  static const Color _rose600 = Color(0xFFE11D48);

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            bottomInset + (bottomPadding > 0 ? 8 : 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Affordance ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Top Bar: Warning Badge + Close Button ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
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
                              color: _rose500,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _rose500.withValues(alpha: 0.5),
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
                            color: _rose600,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                    color: _slate400,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Hero Icon with Subtle Pulse ───────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                    boxShadow: [
                      BoxShadow(
                        color: _rose500.withValues(alpha: 0.15),
                        blurRadius: 12 + _pulseAnim.value * 2,
                        spreadRadius: _pulseAnim.value * 0.8,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: const Center(
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: _rose500,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title & Description ───────────────────────────────────────
              const Text(
                'Leave without saving?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate900,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Your workout summary will not be saved if you go back now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _slate500,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Action Buttons ────────────────────────────────────────────
              // Primary: Stay
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text(
                  'Stay on Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _mint,
                  foregroundColor: _slate900,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 9),

              // Secondary: Leave
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Leave without Saving',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: _rose600,
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Microcopy ─────────────────────────────────────────────────
              const Text(
                'Tap outside or swipe down to cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate400,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
