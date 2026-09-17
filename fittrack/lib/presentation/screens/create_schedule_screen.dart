import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/schedule_editor_notifier.dart';
import '../widgets/add_exercise_bottom_sheet.dart';

class CreateScheduleScreen extends ConsumerStatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  ConsumerState<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends ConsumerState<CreateScheduleScreen> {
  // ── Controllers & State ──────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _expandedExerciseIndex = 0;

  static const _allMuscles = [
    'Chest', 'Back', 'Shoulders',
    'Biceps', 'Triceps', 'Forearms',
    'Core', 'Quads', 'Hamstrings',
    'Glutes', 'Calves',
  ];

  static const _weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleEditorProvider);
    final notifier = ref.read(scheduleEditorProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Schedule',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.headlineMedium?.color ?? colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Summary mini-bar ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SummaryBar(
                  durationLabel: state.totalDurationFormatted,
                  totalSets: state.totalSets,
                  calories: state.estimatedCalories,
                ),
              ),

              // ── Form fields ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Schedule Name'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _nameCtrl,
                        hint: 'e.g. Push / Pull / Legs',
                        onChanged: notifier.setName,
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel('Description (optional)'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _descCtrl,
                        hint: 'Briefly describe this schedule…',
                        maxLines: 3,
                        onChanged: notifier.setDescription,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Target muscles ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SectionLabel('Target Muscles'),
                          const SizedBox(width: 8),
                          if (state.targetMuscles.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${state.targetMuscles.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allMuscles.map((m) {
                          final selected = state.targetMuscles.contains(m);
                          return GestureDetector(
                            onTap: () => notifier.toggleMuscle(m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Weekday pills ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Training Days'),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(7, (i) {
                          final wd = i + 1; // 1 = Monday
                          final isActive =
                              state.assignedWeekdays.contains(wd);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => notifier.toggleWeekday(wd),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: EdgeInsets.only(
                                  right: i < 6 ? 6 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? colorScheme.primary : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _weekdayLabels[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colorScheme.onPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Added exercises ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      _SectionLabel('Exercises'),
                      if (state.exercises.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.exercises.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Exercise cards (reorderable)
              if (state.exercises.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _EmptyExercisesCard(
                      onAddTap: () => _showAddExerciseSheet(context, notifier),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverReorderableList(
                    // ignore: deprecated_member_use
                    onReorder: notifier.reorderExercises,
                    itemCount: state.exercises.length,
                    itemBuilder: (context, index) {
                      final entry = state.exercises[index];
                      return _ExerciseCard(
                        key: ValueKey('${entry.exerciseId}_$index'),
                        index: index,
                        entry: entry,
                        isExpanded: _expandedExerciseIndex == index,
                        onToggle: () {
                          setState(() {
                            if (_expandedExerciseIndex == index) {
                              _expandedExerciseIndex = null;
                            } else {
                              _expandedExerciseIndex = index;
                            }
                          });
                        },
                        onRemove: () =>
                            notifier.removeExercise(index),
                        onChangeSets: (v) => notifier.updateExerciseParam(
                            index, sets: v),
                        onChangeReps: (v) => notifier.updateExerciseParam(
                            index, reps: v),
                        onChangeWeight: (v) =>
                            notifier.updateExerciseParam(
                                index, weightKg: v),
                        onChangeRest: (v) => notifier.updateExerciseParam(
                            index, restSeconds: v),
                      );
                    },
                  ),
                ),

              // Add exercise button
              if (state.exercises.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showAddExerciseSheet(context, notifier),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Exercise'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ),

              // Bottom padding for sticky CTA
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── Sticky Save CTA ───────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SaveBar(
              isValid: state.isValid,
              isSaving: state.isSaving,
              saveError: state.saveError,
              onSave: () => _save(context, notifier),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseSheet(
    BuildContext context,
    ScheduleEditorNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AddExerciseBottomSheet(
          onExercisesAdded: (entries) {
            for (final e in entries) {
              notifier.addExercise(e);
            }
          },
          onCreateNew: () => context.push('/exercises/create-custom'),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    ScheduleEditorNotifier notifier,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final success = await notifier.save();
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Schedule saved!',
              style: TextStyle(color: colorScheme.onPrimary)),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      router.pop();
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.durationLabel,
    required this.totalSets,
    required this.calories,
  });
  final String durationLabel;
  final int totalSets;
  final int calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          _StatChip(Icons.timer_rounded, durationLabel, 'Duration'),
          const SizedBox(width: 12),
          _StatChip(Icons.format_list_numbered_rounded, '$totalSets', 'Sets'),
          const SizedBox(width: 12),
          _StatChip(Icons.local_fire_department_rounded, '~$calories', 'kcal'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExercisesCard extends StatelessWidget {
  const _EmptyExercisesCard({required this.onAddTap});
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.add_circle_outline_rounded,
                  color: colorScheme.onPrimaryContainer, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first exercise',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to browse the exercise library',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    super.key,
    required this.index,
    required this.entry,
    required this.isExpanded,
    required this.onToggle,
    required this.onRemove,
    required this.onChangeSets,
    required this.onChangeReps,
    required this.onChangeWeight,
    required this.onChangeRest,
  });

  final int index;
  final ScheduleExerciseEntry entry;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final ValueChanged<int> onChangeSets;
  final ValueChanged<int> onChangeReps;
  final ValueChanged<double> onChangeWeight;
  final ValueChanged<int> onChangeRest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? colorScheme.primary : colorScheme.outlineVariant,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header (tap to toggle)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  children: [
                    // Step number badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isExpanded ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                        border: isExpanded
                            ? Border.all(color: colorScheme.primary, width: 1.5)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isExpanded ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.exerciseName.isEmpty
                            ? 'Exercise ${index + 1}'
                            : entry.exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    // Drag handle
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Icon(Icons.drag_indicator_rounded,
                            color: Color(0xFFcbd5e1), size: 22),
                      ),
                    ),
                    // Remove
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFFef4444), size: 18),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (!isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(54, 0, 16, 16),
              child: Text(
                '${entry.targetSets} sets • ${entry.targetReps} reps • ${entry.restDurationSeconds}s rest',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Steppers grid (2x2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StepperCell(
                        label: 'Sets',
                        value: entry.targetSets,
                        onMinus: () =>
                            onChangeSets((entry.targetSets - 1).clamp(1, 99)),
                        onPlus: () =>
                            onChangeSets((entry.targetSets + 1).clamp(1, 99)),
                        display: '${entry.targetSets}',
                        onEdit: () => _showEditDialog(
                            context,
                            'Sets',
                            entry.targetSets.toDouble(),
                            (v) => onChangeSets(v.toInt())),
                      ),
                      const SizedBox(width: 12),
                      _StepperCell(
                        label: 'Reps',
                        value: entry.targetReps,
                        onMinus: () =>
                            onChangeReps((entry.targetReps - 1).clamp(1, 999)),
                        onPlus: () =>
                            onChangeReps((entry.targetReps + 1).clamp(1, 999)),
                        display: '${entry.targetReps}',
                        onEdit: () => _showEditDialog(
                            context,
                            'Reps',
                            entry.targetReps.toDouble(),
                            (v) => onChangeReps(v.toInt())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StepperCell(
                        label: 'Wt. kg',
                        value: entry.targetWeightKg.toInt(),
                        onMinus: () => onChangeWeight(
                            (entry.targetWeightKg - 0.5)
                                .clamp(0, 999)
                                .toDouble()),
                        onPlus: () => onChangeWeight(
                            (entry.targetWeightKg + 0.5)
                                .clamp(0, 999)
                                .toDouble()),
                        display: entry.targetWeightKg == 0
                            ? 'BW'
                            : entry.targetWeightKg.toStringAsFixed(entry.targetWeightKg % 1 == 0 ? 0 : 1),
                        onEdit: () => _showEditDialog(
                            context,
                            'Weight (kg)',
                            entry.targetWeightKg,
                            onChangeWeight,
                            isDouble: true),
                      ),
                      const SizedBox(width: 12),
                      _StepperCell(
                        label: 'Rest',
                        value: entry.restDurationSeconds,
                        onMinus: () => onChangeRest(
                            (entry.restDurationSeconds - 15).clamp(0, 600)),
                        onPlus: () => onChangeRest(
                            (entry.restDurationSeconds + 15).clamp(0, 600)),
                        display:
                            '${entry.restDurationSeconds ~/ 60}:${(entry.restDurationSeconds % 60).toString().padLeft(2, '0')}',
                        onEdit: () => _showEditDialog(
                            context,
                            'Rest (sec)',
                            entry.restDurationSeconds.toDouble(),
                            (v) => onChangeRest(v.toInt())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, double initial, ValueChanged<double> onSave, {bool isDouble = false}) {
    final controller = TextEditingController(text: isDouble ? initial.toString() : initial.toInt().toString());
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierColor: colorScheme.scrim.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Edit $title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) onSave(val);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StepperCell extends StatelessWidget {
  const _StepperCell({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.display,
    this.onEdit,
  });

  final String label;
  final num value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String display;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniBtn(Icons.remove_rounded, onMinus),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 40),
                    alignment: Alignment.center,
                    child: Text(
                      display,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _MiniBtn(Icons.add_rounded, onPlus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 13, color: colorScheme.onSurface),
      ),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 14, 20, 14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text(
                      'Save Schedule',
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
