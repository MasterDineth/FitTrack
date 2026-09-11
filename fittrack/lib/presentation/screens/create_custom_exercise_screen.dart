import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_activation.dart';
import '../providers/custom_exercise_notifier.dart';
import '../widgets/modals/add_form_cue_dialog.dart';
import '../widgets/modals/add_muscle_activation_modal.dart';

class CreateCustomExerciseScreen extends ConsumerWidget {
  const CreateCustomExerciseScreen({super.key});

  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _bg = Color(0xFFf7f9fb);
  static const Color _muted = Color(0xFF64748b);
  static const Color _border = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customExerciseProvider);
    final notifier = ref.read(customExerciseProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _dark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create Exercise',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section: Basic Info ───────────────────────────────────
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Basic Info'),
                      const SizedBox(height: 12),

                      // Title
                      _FieldLabel('Exercise Title'),
                      const SizedBox(height: 6),
                      _TextField(
                        hint: 'e.g. Barbell Bench Press',
                        onChanged: notifier.setTitle,
                      ),
                      const SizedBox(height: 20),

                      // Equipment
                      _FieldLabel('Equipment'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Equipment.values.map((eq) {
                          final isSelected = state.equipment == eq;
                          final label = _equipmentLabel(eq);
                          return GestureDetector(
                            onTap: () => notifier.setEquipment(eq),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? _mint : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _mint : _border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? _dark : _muted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Movement Classification
                      _FieldLabel('Movement Classification'),
                      const SizedBox(height: 10),
                      ...MovementClassification.values.map((mc) {
                        final isSelected =
                            state.movementClassification == mc;
                        return GestureDetector(
                          onTap: () =>
                              notifier.setMovementClassification(mc),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _mint.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? _mint : _border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? _mint
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? _mint
                                          : _border,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded,
                                          size: 12, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _movementLabel(mc),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isSelected
                                            ? _dark
                                            : _dark,
                                      ),
                                    ),
                                    Text(
                                      _movementDescription(mc),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // ── Section: Media ────────────────────────────────────────
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Media'),
                      const SizedBox(height: 12),

                      // Image picker placeholder
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf1f5f9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_outlined,
                                  size: 32, color: Color(0xFFcbd5e1)),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add image',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // YouTube URL
                      _FieldLabel('YouTube URL (optional)'),
                      const SizedBox(height: 6),
                      _TextField(
                        hint: 'https://youtube.com/watch?v=…',
                        onChanged: notifier.setYoutubeUrl,
                        keyboardType: TextInputType.url,
                        prefixIcon: const Icon(
                          Icons.play_circle_outline_rounded,
                          color: Color(0xFFef4444),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Section: Execution Steps ──────────────────────────────
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SectionHeader('Execution Steps'),
                          const Spacer(),
                          GestureDetector(
                            onTap: notifier.addExecutionStep,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _mint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+ Add Phase',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.executionSteps.isEmpty)
                        _EmptyHint(
                          icon: Icons.format_list_numbered_rounded,
                          text: 'Add step-by-step execution phases',
                        )
                      else
                        ...state.executionSteps.asMap().entries.map(
                          (entry) => _StepCard(
                            index: entry.key,
                            step: entry.value,
                            onTitleChanged: (v) =>
                                notifier.updateExecutionStep(
                                    entry.key, title: v),
                            onInstructionsChanged: (v) =>
                                notifier.updateExecutionStep(
                                    entry.key, instructions: v),
                            onRemove: () =>
                                notifier.removeExecutionStep(entry.key),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Section: Technique Cues ───────────────────────────────
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SectionHeader('Technique Cues'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showAddFormCueDialog(
                                context, notifier),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _mint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+ Add Cue',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.formCues.isEmpty)
                        _EmptyHint(
                          icon: Icons.tips_and_updates_outlined,
                          text: 'Add DO and DON\'T technique tips',
                        )
                      else
                        ...state.formCues.asMap().entries.map(
                          (entry) => _FormCueTile(
                            cue: entry.value,
                            onRemove: () =>
                                notifier.removeFormCue(entry.key),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Section: Muscle Activation ────────────────────────────
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SectionHeader('Muscle Activation'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showAddMuscleModal(
                                context, notifier),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _mint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+ Add Muscle',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.muscleActivations.isEmpty)
                        _EmptyHint(
                          icon: Icons.accessibility_new_rounded,
                          text: 'Define muscles and their activation roles',
                        )
                      else
                        ...state.muscleActivations.asMap().entries.map(
                          (entry) => _MuscleActivationTile(
                            activation: entry.value,
                            onIntensityChanged: (v) =>
                                notifier.updateMuscleActivationIntensity(
                                    entry.key, v),
                            onRemove: () => notifier
                                .removeMuscleActivation(entry.key),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky Save CTA ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SaveBar(
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

  // ── Helper methods ────────────────────────────────────────────────────────

  static String _equipmentLabel(Equipment eq) {
    return switch (eq) {
      Equipment.barbell => 'Barbell',
      Equipment.dumbbell => 'Dumbbell',
      Equipment.cable => 'Cable',
      Equipment.machine => 'Machine',
      Equipment.bodyweight => 'Bodyweight',
      Equipment.other => 'Other',
    };
  }

  static String _movementLabel(MovementClassification mc) {
    return switch (mc) {
      MovementClassification.compound => 'Compound',
      MovementClassification.isolation => 'Isolation',
      MovementClassification.calisthenics => 'Calisthenics',
      MovementClassification.mobility => 'Mobility',
      MovementClassification.other => 'Other',
    };
  }

  static String _movementDescription(MovementClassification mc) {
    return switch (mc) {
      MovementClassification.compound =>
        'Multi-joint, recruits multiple muscle groups',
      MovementClassification.isolation =>
        'Single-joint, targets one muscle group',
      MovementClassification.calisthenics =>
        'Bodyweight-based, gymnastics-style',
      MovementClassification.mobility =>
        'Flexibility and range-of-motion focused',
      MovementClassification.other => 'General movement pattern',
    };
  }

  static void _showAddFormCueDialog(
    BuildContext context,
    CustomExerciseNotifier notifier,
  ) {
    showModalBottomSheet<FormCueDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFormCueDialog(),
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
      builder: (_) => const AddMuscleActivationModal(),
    ).then((result) {
      if (result != null) notifier.addMuscleActivation(result);
    });
  }

  static Future<void> _save(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(customExerciseProvider.notifier);
    final success = await notifier.save();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise created!'),
          backgroundColor: _mint,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0f172a),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748b),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  static const Color _mint = Color(0xFF00d68f);

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFa0aec0), fontSize: 13),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: const Color(0xFFf8fafc),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _mint, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFFcbd5e1)),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94a3b8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _dark,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFFef4444)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: onTitleChanged,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _dark,
            ),
            decoration: const InputDecoration(
              hintText: 'Phase title (e.g. Setup)',
              hintStyle: TextStyle(color: Color(0xFFa0aec0), fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(height: 12),
          TextField(
            onChanged: onInstructionsChanged,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            decoration: const InputDecoration(
              hintText: 'Step-by-step instructions…',
              hintStyle: TextStyle(color: Color(0xFFa0aec0), fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCueTile extends StatelessWidget {
  const _FormCueTile({required this.cue, required this.onRemove});
  final FormCueDraft cue;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isPositive = cue.isPositive;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFF00d68f).withValues(alpha: 0.06)
            : const Color(0xFFef4444).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? const Color(0xFF00d68f).withValues(alpha: 0.3)
              : const Color(0xFFef4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 18,
            color: isPositive
                ? const Color(0xFF00d68f)
                : const Color(0xFFef4444),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cue.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0f172a),
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 16, color: Color(0xFFa0aec0)),
          ),
        ],
      ),
    );
  }
}

class _MuscleActivationTile extends StatelessWidget {
  const _MuscleActivationTile({
    required this.activation,
    required this.onIntensityChanged,
    required this.onRemove,
  });

  final MuscleActivationDraft activation;
  final ValueChanged<int> onIntensityChanged;
  final VoidCallback onRemove;

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  static Color _roleColor(MuscleRole role) => switch (role) {
        MuscleRole.agonist => const Color(0xFF00d68f),
        MuscleRole.synergist => const Color(0xFF3b82f6),
        MuscleRole.stabilizer => const Color(0xFFf59e0b),
      };

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(activation.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  activation.role.name[0].toUpperCase() +
                      activation.role.name.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activation.muscleName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _dark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFFa0aec0)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Intensity',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748b),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onIntensityChanged(
                    (activation.intensityPercentage - 5).clamp(5, 100)),
                child: _MiniStepBtn(Icons.remove_rounded),
              ),
              const SizedBox(width: 8),
              Text(
                '${activation.intensityPercentage}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _dark,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onIntensityChanged(
                    (activation.intensityPercentage + 5).clamp(5, 100)),
                child: _MiniStepBtn(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: activation.intensityPercentage / 100,
              backgroundColor: const Color(0xFFe2e8f0),
              valueColor: AlwaysStoppedAnimation<Color>(roleColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepBtn extends StatelessWidget {
  const _MiniStepBtn(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFf1f5f9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: const Color(0xFF0f172a)),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isValid,
    required this.isSaving,
    required this.saveError,
    required this.onSave,
  });

  final bool isValid;
  final bool isSaving;
  final String? saveError;
  final VoidCallback onSave;

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 14, 20, 14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                saveError!,
                style: const TextStyle(
                  color: Color(0xFFef4444),
                  fontSize: 12,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isValid && !isSaving) ? onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _mint,
                foregroundColor: _dark,
                disabledBackgroundColor: const Color(0xFFe2e8f0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create Exercise',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
