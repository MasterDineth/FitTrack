import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import 'modal_backdrop_helper.dart';

/// Shows the modern Save Session Modal from Stitch (ID: b42dc5d85712471eaaf22f1f2cc118e6).
Future<void> showSaveSessionModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required Future<void> Function() onSave,
}) async {
  await showBlurBottomSheet<void>(
    context: context,
    child: _SaveSessionCard(
      state: state,
      onSave: onSave,
    ),
  );
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 36,
            offset: const Offset(0, 14),
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
                    color: colorScheme.outlineVariant,
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
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),

              // ── Hero Icon Pill ────────────────────────────────────────────
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.cloud_done_outlined,
                          color: colorScheme.onPrimaryContainer,
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
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
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
              Text(
                'Save this session?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Your completed sets, reps, and workout telemetry will be securely stored to your training log.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SESSION PROGRESS',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Ready to sync',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
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
                        _divider(colorScheme.outlineVariant),
                        // 2: Sets
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.repeat_rounded,
                            label: 'Sets',
                            value: '${widget.state.completedSetCount}',
                          ),
                        ),
                        _divider(colorScheme.outlineVariant),
                        // 3: Exercises
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.fitness_center_rounded,
                            label: 'Exercises',
                            value: '$completedCount / $totalCount',
                          ),
                        ),
                        _divider(colorScheme.outlineVariant),
                        // 4: Est. Burn
                        Expanded(
                          child: _TelemetryMetric(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.orange,
                            label: 'Est. Burn',
                            richValue: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${widget.state.estimatedCalories} ',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'kcal',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: colorScheme.primary.withValues(alpha: 0.35),
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
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(Icons.save_rounded, size: 20, color: colorScheme.onPrimary),
                  label: Text(
                    _saving ? 'Saving...' : 'Yes, Save It',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
                icon: Icon(Icons.play_arrow_rounded, size: 20, color: colorScheme.onSurface),
                label: Text(
                  'Keep Training',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),

              // ── Microcopy Dismiss Hint ─────────────────────────────────────
              Text(
                'Tap outside or swipe down to cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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

  Widget _divider(Color color) {
    return Container(
      width: 1,
      height: 30,
      color: color,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: iconColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
      ],
    );
  }
}
