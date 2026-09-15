import 'dart:ui';
import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';

/// Shows the modern Save Session Modal from Stitch (ID: b42dc5d85712471eaaf22f1f2cc118e6).
/// Features:
///   - Full-screen dimmed backdrop blur
///   - Illuminated mint hero icon with cloud save & checkmark badge
///   - Title: "Save this session?"
///   - Session Progress telemetry card (Time, Sets, Exercises, Est. Burn)
///   - Primary button: "Yes, Save It" with kinetic mint glow
///   - Secondary button: "Keep Training"
Future<void> showSaveSessionModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required Future<void> Function() onSave,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent, // Handled by custom BackdropFilter
    builder: (ctx) => _SaveSessionModalHost(
      state: state,
      onSave: onSave,
    ),
  );
}

class _SaveSessionModalHost extends StatelessWidget {
  const _SaveSessionModalHost({
    required this.state,
    required this.onSave,
  });

  final ActiveWorkoutState state;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // ── Blurred Dimmed Backdrop ──────────────────────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.45),
              ),
            ),
          ),

          // ── Bottom Sheet Card ────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside modal from closing
              child: _SaveSessionCard(
                state: state,
                onSave: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveSessionCard extends StatefulWidget {
  const _SaveSessionCard({
    required this.state,
    required this.onSave,
  });

  final ActiveWorkoutState state;
  final Future<void> Function() onSave;

  @override
  State<_SaveSessionCard> createState() => _SaveSessionCardState();
}

class _SaveSessionCardState extends State<_SaveSessionCard> {
  bool _saving = false;

  static const Color _mint = Color(0xFF00D68F);
  static const Color _mintDark = Color(0xFF00B578);
  static const Color _mintSoft = Color(0xFFE6FBF3);
  static const Color _mintBorder = Color(0xFFABF3D6);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate800 = Color(0xFF1E293B);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.state.entries
        .where(
          (e) => widget.state.completedSets.any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalCount = widget.state.entries.length;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
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
              // ── Top Drag Indicator ─────────────────────────────────────────
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
              const SizedBox(height: 4),

              // ── Top Bar with Close Button ─────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: _slate500,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),

              // ── Illuminated Mint Hero Icon Pill ────────────────────────────
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _mintSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _mintBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: _mint.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.cloud_done_outlined,
                          color: _mintDark,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _mint,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: _slate900,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Title & Value Reassurance ──────────────────────────────────
              const Text(
                'Save this session?',
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
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Your completed sets, reps, and workout telemetry will be securely stored to your training log.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _slate500,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Session Telemetry Summary Card ─────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SESSION PROGRESS',
                            style: TextStyle(
                              color: _slate500,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Ready to sync',
                                style: TextStyle(
                                  color: _mintDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // 1: Time
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.access_time_rounded,
                            label: 'Time',
                            value: widget.state.elapsedFormatted,
                          ),
                        ),
                        _divider(),
                        // 2: Sets
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.repeat_rounded,
                            label: 'Sets',
                            value: '${widget.state.completedSetCount}',
                          ),
                        ),
                        _divider(),
                        // 3: Exercises
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.fitness_center_rounded,
                            label: 'Exercises',
                            value: '$completedCount / $totalCount',
                          ),
                        ),
                        _divider(),
                        // 4: Est. Burn
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            label: 'Est. Burn',
                            richValue: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${widget.state.estimatedCalories} ',
                                    style: const TextStyle(
                                      color: _slate800,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'kcal',
                                    style: TextStyle(
                                      color: _slate400,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Action Buttons Group ───────────────────────────────────────
              // Primary Action: Yes, Save It
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _mint.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            Navigator.of(context).pop();
                            await widget.onSave();
                          } catch (_) {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _slate900,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    _saving ? 'Saving...' : 'Yes, Save It',
                    style: const TextStyle(
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
              ),
              const SizedBox(height: 9),

              // Secondary Action: Keep Training
              FilledButton.icon(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text(
                  'Keep Training',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: _slate700,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),

              // ── Microcopy Dismiss Hint ─────────────────────────────────────
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

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _TelemetryMetric extends StatelessWidget {
  const _TelemetryMetric({
    required this.icon,
    this.iconColor,
    required this.label,
    this.value,
    this.richValue,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? value;
  final Widget? richValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor ?? const Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        richValue ??
            Text(
              value ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
      ],
    );
  }
}
