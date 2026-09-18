import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_activation.dart';
import '../providers/custom_exercise_notifier.dart';
import '../widgets/modals/add_form_cue_dialog.dart';
import '../widgets/modals/add_muscle_activation_modal.dart';

/// Local private card decoration helper matching Stitch specifications.
BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  final colorScheme = Theme.of(context).colorScheme;

  if (isLight) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  } else {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: colorScheme.outline),
    );
  }
}

/// Custom dashed border painter for image dropzone upload area.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  static const double dashWidth = 6.0;
  static const double dashSpace = 4.0;

  const _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

/// Create Custom Exercise Screen matching Stitch templates across Light & Dark/OLED modes.
class CreateCustomExerciseScreen extends ConsumerWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customExerciseProvider);
    final notifier = ref.read(customExerciseProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Exercise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Configure exercise telemetry, media, and cues',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Basic Info ─────────────────────────────────
                _CardSection(
                  icon: Icons.edit_note_rounded,
                  title: 'Basic Info',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Title
                      _FieldLabel(text: 'Exercise Title'),
                      const SizedBox(height: 6),
                      _NoBorderInputContainer(
                        child: TextField(
                          onChanged: notifier.setTitle,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Incline Dumbbell Hammer Press',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Equipment Required
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FieldLabel(text: 'Equipment Required'),
                          Text(
                            'SELECT ONE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Equipment.values.map((eq) {
                          final isSelected = state.equipment == eq;
                          return _EquipmentChip(
                            equipment: eq,
                            isSelected: isSelected,
                            onTap: () => notifier.setEquipment(eq),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Movement Classification
                      _FieldLabel(text: 'Movement Classification'),
                      const SizedBox(height: 10),
                      ...MovementClassification.values.map((mc) {
                        final isSelected = state.movementClassification == mc;
                        return _MovementClassificationCard(
                          classification: mc,
                          isSelected: isSelected,
                          onTap: () => notifier.setMovementClassification(mc),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Section 2: Media Upload ───────────────────────────────
                _CardSection(
                  icon: Icons.photo_camera_rounded,
                  title: 'Media Upload',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashed border image dropzone
                      CustomPaint(
                        painter: _DashedBorderPainter(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                          radius: 16,
                          strokeWidth: 1.5,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to add exercise visual',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'PNG, JPG, GIF max 10MB',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // YouTube Breakdown URL
                      _FieldLabel(text: 'YouTube Breakdown URL'),
                      const SizedBox(height: 6),
                      _NoBorderInputContainer(
                        child: TextField(
                          onChanged: notifier.setYoutubeUrl,
                          keyboardType: TextInputType.url,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'https://youtube.com/watch?v=...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.play_circle_fill_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leave blank to auto-link live smart guide search',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Section 3: Phased Execution Steps ─────────────────────
                _CardSection(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Phased Execution Steps',
                  trailing: GestureDetector(
                    onTap: notifier.addExecutionStep,
                    child: Text(
                      '+ Add Phase',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.executionSteps.isEmpty)
                        _EmptyHint(
                          icon: Icons.format_list_numbered_rounded,
                          text: 'No phases added yet. Tap + Add Phase above.',
                          onAdd: notifier.addExecutionStep,
                          addLabel: '+ Add First Phase',
                        )
                      else
                        ...state.executionSteps.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExecutionStepCard(
                              index: entry.key,
                              step: entry.value,
                              onTitleChanged: (v) => notifier.updateExecutionStep(
                                entry.key,
                                title: v,
                              ),
                              onInstructionsChanged: (v) =>
                                  notifier.updateExecutionStep(
                                entry.key,
                                instructions: v,
                              ),
                              onRemove: () => notifier.removeExecutionStep(entry.key),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Section 4: Technique Cues & Pitfalls ──────────────────
                _CardSection(
                  icon: Icons.verified_rounded,
                  title: 'Technique Cues & Pitfalls',
                  trailing: GestureDetector(
                    onTap: () => _showAddFormCueDialog(context, notifier),
                    child: Text(
                      '+ Add Cue',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.formCues.isEmpty)
                        _EmptyHint(
                          icon: Icons.tips_and_updates_outlined,
                          text: 'Add DO and DON\'T technique cues to guide form.',
                          onAdd: () => _showAddFormCueDialog(context, notifier),
                          addLabel: '+ Add Technique Cue',
                        )
                      else
                        ...state.formCues.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FormCueCard(
                              cue: entry.value,
                              onRemove: () => notifier.removeFormCue(entry.key),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Section 5: Muscle Activation ──────────────────────────
                _CardSection(
                  icon: Icons.bolt_rounded,
                  title: 'Muscle Activation',
                  trailing: Text(
                    'Kinetic Load',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.muscleActivations.isEmpty)
                        _EmptyHint(
                          icon: Icons.accessibility_new_rounded,
                          text: 'Define target muscle activation percentages.',
                          onAdd: () => _showAddMuscleModal(context, notifier),
                          addLabel: '+ Add Muscle Activation',
                        )
                      else
                        ...state.muscleActivations.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MuscleActivationCard(
                              activation: entry.value,
                              onIntensityChanged: (v) => notifier
                                  .updateMuscleActivationIntensity(entry.key, v),
                              onRemove: () =>
                                  notifier.removeMuscleActivation(entry.key),
                            ),
                          );
                        }),
                      const SizedBox(height: 6),
                      // Add Target Muscle Activation button
                      GestureDetector(
                        onTap: () => _showAddMuscleModal(context, notifier),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Target Muscle Activation',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky Bottom CTA ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickySaveDock(
              isValid: state.isValid,
              isSaving: state.isSaving,
              saveError: state.saveError,
              onSave: () => _save(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  static void _showAddFormCueDialog(
    BuildContext context,
    CustomExerciseNotifier notifier,
  ) {
    showDialog<FormCueDraft>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: const AddFormCueDialog(),
      ),
    ).then((result) {
      if (result != null) notifier.addFormCue(result);
    });
  }

  static void _showAddMuscleModal(
    BuildContext context,
    CustomExerciseNotifier notifier,
  ) {
    showModalBottomSheet<MuscleActivationDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: const AddMuscleActivationModal(),
      ),
    ).then((result) {
      if (result != null) notifier.addMuscleActivation(result);
    });
  }

  static Future<void> _save(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(customExerciseProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final success = await notifier.save();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exercise created successfully!',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}

// ── Helper Widgets ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _NoBorderInputContainer extends StatelessWidget {
  const _NoBorderInputContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EquipmentChip extends StatelessWidget {
  const _EquipmentChip({
    required this.equipment,
    required this.isSelected,
    required this.onTap,
  });

  final Equipment equipment;
  final bool isSelected;
  final VoidCallback onTap;

  static String _label(Equipment eq) => switch (eq) {
        Equipment.barbell => 'Barbell',
        Equipment.dumbbell => 'Dumbbell',
        Equipment.cable => 'Cable',
        Equipment.machine => 'Machine',
        Equipment.bodyweight => 'Bodyweight',
        Equipment.other => 'Other',
      };

  static IconData _icon(Equipment eq) => switch (eq) {
        Equipment.barbell => Icons.fitness_center_rounded,
        Equipment.dumbbell => Icons.sports_gymnastics_rounded,
        Equipment.cable => Icons.cable_rounded,
        Equipment.machine => Icons.precision_manufacturing_rounded,
        Equipment.bodyweight => Icons.accessibility_new_rounded,
        Equipment.other => Icons.sports_kabaddi_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon(equipment),
              size: 15,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _label(equipment),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementClassificationCard extends StatelessWidget {
  const _MovementClassificationCard({
    required this.classification,
    required this.isSelected,
    required this.onTap,
  });

  final MovementClassification classification;
  final bool isSelected;
  final VoidCallback onTap;

  static String _label(MovementClassification mc) => switch (mc) {
        MovementClassification.compound => 'Compound',
        MovementClassification.isolation => 'Isolation',
        MovementClassification.calisthenics => 'Calisthenics',
        MovementClassification.mobility => 'Mobility',
        MovementClassification.other => 'Other',
      };

  static String _desc(MovementClassification mc) => switch (mc) {
        MovementClassification.compound => 'Multi-joint major kinetic movement',
        MovementClassification.isolation => 'Single joint localized muscle focus',
        MovementClassification.calisthenics =>
          'Bodyweight leverage, control, and agility',
        MovementClassification.mobility =>
          'Kinetic flow, stretch & joint integrity',
        MovementClassification.other => 'General movement pattern',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final decoration = isSelected
        ? BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.primary, width: 1.5),
          )
        : _buildCardDecoration(context, radius: 14);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: decoration,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label(classification),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _desc(classification),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phased Execution Step Card ───────────────────────────────────────────────
class _ExecutionStepCard extends StatelessWidget {
  const _ExecutionStepCard({
    required this.index,
    required this.step,
    required this.onTitleChanged,
    required this.onInstructionsChanged,
    required this.onRemove,
  });

  final int index;
  final ExecutionStepDraft step;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onInstructionsChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Solid Primary Sequence Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: step.title)
                    ..selection = TextSelection.collapsed(offset: step.title.length),
                  onChanged: onTitleChanged,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phase Title (e.g., Setup & Scapular Lock)',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Icon(
                Icons.drag_handle_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: TextField(
              controller: TextEditingController(text: step.instructions)
                ..selection = TextSelection.collapsed(
                    offset: step.instructions.length),
              onChanged: onInstructionsChanged,
              maxLines: null,
              minLines: 2,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Add detailed instructions for this phase...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Technique Cue Card ───────────────────────────────────────────────────────
class _FormCueCard extends StatelessWidget {
  const _FormCueCard({
    required this.cue,
    required this.onRemove,
  });

  final FormCueDraft cue;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = cue.isPositive;

    final bgColor = isPositive
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.error.withValues(alpha: 0.08);
    final borderColor = isPositive
        ? colorScheme.primary.withValues(alpha: 0.35)
        : colorScheme.error.withValues(alpha: 0.35);
    final accentColor = isPositive ? colorScheme.primary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check_rounded : Icons.close_rounded,
              size: 14,
              color: isPositive ? colorScheme.onPrimary : colorScheme.onError,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive ? 'DO' : "DON'T",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cue.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Muscle Activation Card ───────────────────────────────────────────────────
class _MuscleActivationCard extends StatelessWidget {
  const _MuscleActivationCard({
    required this.activation,
    required this.onIntensityChanged,
    required this.onRemove,
  });

  final MuscleActivationDraft activation;
  final ValueChanged<int> onIntensityChanged;
  final VoidCallback onRemove;

  static String _roleBadgeText(MuscleRole role) => switch (role) {
        MuscleRole.agonist => 'PRIME',
        MuscleRole.synergist => 'SYNERGIST',
        MuscleRole.stabilizer => 'STABILIZER',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      activation.muscleName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _roleBadgeText(activation.role),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${activation.intensityPercentage}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Forced Primary Active Track Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: activation.intensityPercentage.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (v) => onIntensityChanged(v.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.text,
    required this.onAdd,
    required this.addLabel,
  });

  final IconData icon;
  final String text;
  final VoidCallback onAdd;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 26,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAdd,
            child: Text(
              addLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Save Dock ─────────────────────────────────────────────────────────
class _StickySaveDock extends StatelessWidget {
  const _StickySaveDock({
    required this.isValid,
    required this.isSaving,
    required this.saveError,
    required this.onSave,
  });

  final bool isValid;
  final bool isSaving;
  final String? saveError;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                saveError!,
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: (isValid && !isSaving) ? onSave : null,
              icon: isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
              label: Text(
                isSaving ? 'Registering Exercise...' : 'Create Exercise',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: colorScheme.onPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                elevation: 0,
                shadowColor: isLight ? colorScheme.primary : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
