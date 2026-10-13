import 'package:flutter/material.dart';
import '../../../providers/custom_exercise_notifier.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Execution Steps Section Card for Create Exercise Screen.
/// Matches Stitch Screen ID de3d4ad0debd49a9905572984fbbde63.
///
/// Features:
/// - Step-by-step timeline stepper (max 3 steps).
/// - Distinct color-coded step number circles (Step 1: primary, Step 2: primary-container, Step 3: brand-teal).
/// - Step title input and instructions textarea.
/// - Remove step button ('x').
/// - "Add Execution Step" dashed button (hidden or disabled at 3 steps).
class ExerciseExecutionStepsCard extends StatefulWidget {
  const ExerciseExecutionStepsCard({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
  });

  final List<ExecutionStepDraft> steps;
  final VoidCallback onAddStep;
  final void Function(int index, {String? title, String? instructions}) onUpdateStep;
  final ValueChanged<int> onRemoveStep;

  @override
  State<ExerciseExecutionStepsCard> createState() =>
      _ExerciseExecutionStepsCardState();
}

class _ExerciseExecutionStepsCardState
    extends State<ExerciseExecutionStepsCard> {
  bool _isExpanded = true;

  static const List<Color> _badgeColors = [
    Color(0xFF5F3BDC), // Primary violet
    Color(0xFF7858F6), // Primary container
    Color(0xFF2DD4BF), // Brand teal
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final stepCount = widget.steps.length;

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
                        Icons.format_list_numbered_rounded,
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
                            'Execution Steps',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          Text(
                            'Step-by-step movement cadence',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      '$stepCount step${stepCount == 1 ? '' : 's'}',
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

            if (widget.steps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No execution steps added yet. Add up to 3 movement steps.',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              )
            else
              // Timeline stepper items
              Stack(
                children: [
                  // Continuous vertical line behind badges
                  if (widget.steps.length > 1)
                    Positioned(
                      left: 15,
                      top: 18,
                      bottom: 24,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary,
                              const Color(0xFF2DD4BF),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),

                  Column(
                    children: widget.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final badgeColor = _badgeColors[index.clamp(0, 2)];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Circular Number Badge
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 12, top: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: badgeColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: index == 2 ? const Color(0xFF1D1735) : Colors.white,
                                ),
                              ),
                            ),

                            // Step Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0x1F1E1838)
                                      : Colors.white.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(16),
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
                                    // Title & Remove Button
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: step.title,
                                            onChanged: (val) {
                                              widget.onUpdateStep(index, title: val);
                                            },
                                            style: TextStyle(
                                              fontFamily: FtText.fontFamily,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: ink,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              hintText: index == 0
                                                  ? 'e.g. Stance & Grip'
                                                  : (index == 1
                                                      ? 'e.g. Inhale & Descent'
                                                      : 'e.g. Explosive Drive'),
                                              hintStyle: TextStyle(
                                                fontFamily: FtText.fontFamily,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: muted.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => widget.onRemoveStep(index),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: muted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Instructions Textarea
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x1FFFFFFF)
                                            : const Color(0x66F1EDFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0x1FFFFFFF)
                                              : const Color(0xFFE2E8F0),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: step.instructions,
                                        onChanged: (val) {
                                          widget.onUpdateStep(index, instructions: val);
                                        },
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: ink,
                                          height: 1.4,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          hintText: 'Enter step biomechanics and movement cues...',
                                          hintStyle: TextStyle(
                                            fontFamily: FtText.fontFamily,
                                            fontSize: 12,
                                            color: muted.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

            // Add Step Action Button (Max 3)
            if (widget.steps.length < 3) ...[
              const SizedBox(height: 4),
              FtPressable(
                onTap: widget.onAddStep,
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
                        'Add Execution Step',
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
}
