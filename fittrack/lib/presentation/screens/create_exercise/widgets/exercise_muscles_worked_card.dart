import 'package:flutter/material.dart';
import '../../../../domain/entities/muscle_activation.dart';
import '../../../providers/custom_exercise_notifier.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Muscles Worked Section Card for Create Exercise Screen.
/// Matches Stitch Screen ID de3d4ad0debd49a9905572984fbbde63.
///
/// Features:
/// - List of up to 3 muscles worked with:
///   - Role pill badge (Prime mover, Synergist, Stabilizer).
///   - Activation share percentage display.
///   - Visual gradient activation bar with thumb indicator.
///   - Delete / remove button.
/// - "Add muscle" dashed button (opens FitTrack Add Muscle Picker modal).
class ExerciseMusclesWorkedCard extends StatefulWidget {
  const ExerciseMusclesWorkedCard({
    super.key,
    required this.activations,
    required this.onAddMuscleTap,
    required this.onRemoveMuscle,
  });

  final List<MuscleActivationDraft> activations;
  final VoidCallback onAddMuscleTap;
  final ValueChanged<int> onRemoveMuscle;

  @override
  State<ExerciseMusclesWorkedCard> createState() =>
      _ExerciseMusclesWorkedCardState();
}

class _ExerciseMusclesWorkedCardState extends State<ExerciseMusclesWorkedCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final count = widget.activations.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.monitor_heart_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muscles worked',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          Text(
                            'Target activations',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count muscle${count == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 14),

            if (widget.activations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No muscles attached yet. Add prime movers and synergists (up to 3 max).',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              )
            else
              Column(
                children: widget.activations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activation = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x1F1E1838)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x33FFFFFF)
                              : Colors.white.withValues(alpha: 0.90),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Muscle Name, Role Badge & Delete button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        activation.muscleName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: ink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoleBadge(activation.role, primary),
                                  ],
                                ),
                              ),
                              FtPressable(
                                onTap: () => widget.onRemoveMuscle(index),
                                pressedScale: 0.88,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Color(0xFFF43F5E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Activation Percentage & Subtitle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${activation.intensityPercentage}%',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Activation share',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Visual Slider Progress Track
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final totalWidth = constraints.maxWidth;
                              final fraction = (activation.intensityPercentage / 100).clamp(0.05, 1.0);
                              final fillWidth = totalWidth * fraction;

                              return SizedBox(
                                height: 16,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // Track Background
                                    Container(
                                      height: 10,
                                      width: totalWidth,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x26FFFFFF)
                                            : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),

                                    // Gradient Fill
                                    Container(
                                      height: 10,
                                      width: fillWidth,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primary,
                                            context.ftPrimaryLight,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),

                                    // Circular Thumb Indicator
                                    Positioned(
                                      left: (fillWidth - 8).clamp(0.0, totalWidth - 16),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.20),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Add Muscle Action Button (Max 3)
            if (widget.activations.length < 3) ...[
              const SizedBox(height: 4),
              FtPressable(
                onTap: widget.onAddMuscleTap,
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1F1E1838)
                        : Colors.white.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.40),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add muscle',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(MuscleRole role, Color primary) {
    switch (role) {
      case MuscleRole.agonist:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'Prime mover',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      case MuscleRole.synergist:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: const Text(
            'Synergist',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F766E),
            ),
          ),
        );
      case MuscleRole.stabilizer:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFEB78B).withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFEB78B).withValues(alpha: 0.40),
              width: 0.8,
            ),
          ),
          child: const Text(
            'Stabilizer',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
            ),
          ),
        );
    }
  }
}
