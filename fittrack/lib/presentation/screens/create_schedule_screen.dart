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
  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _bg = Color(0xFFf7f9fb);
  static const Color _muted = Color(0xFF64748b);
  static const Color _border = Color(0xFFe2e8f0);

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
          'Create Schedule',
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
                                color: _mint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${state.targetMuscles.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
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
                                    ? _mint
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? _mint : _border,
                                ),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? _dark : _muted,
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
                                  color: isActive ? _mint : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive ? _mint : _border,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _weekdayLabels[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isActive ? _dark : _muted,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: _dark,
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
                            color: _mint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.exercises.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _dark,
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
                        foregroundColor: _dark,
                        side: const BorderSide(color: _border),
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
      barrierColor: const Color(0x660F172A),
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
    final success = await notifier.save();
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Schedule saved!'),
          backgroundColor: Color(0xFF00d68f),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0f172a),
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

  static const Color _mint = Color(0xFF00d68f);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFa0aec0)),
        filled: true,
        fillColor: Colors.white,
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
      color: Colors.white,
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _mint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: _mint),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _dark,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748b),
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFe2e8f0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _mint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_circle_outline_rounded,
                  color: _mint, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your first exercise',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _dark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to browse the exercise library',
              style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _border = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? _mint : _border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: _mint.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header (tap to toggle)
          InkWell(
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
                      color: isExpanded ? Colors.white : const Color(0xFFf1f5f9),
                      border: isExpanded
                          ? Border.all(color: _mint, width: 1.5)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isExpanded ? _mint : _dark,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _dark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94a3b8),
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

          if (!isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(54, 0, 16, 16),
              child: Text(
                '${entry.targetSets} sets • ${entry.targetReps} reps • ${entry.restDurationSeconds}s rest',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748b),
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
                            : '${entry.targetWeightKg.toStringAsFixed(entry.targetWeightKg % 1 == 0 ? 0 : 1)}',
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
    showDialog(
      context: context,
      barrierColor: const Color(0x660F172A),
      builder: (ctx) => AlertDialog(
        title: Text('Edit $title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748b))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) onSave(val);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _mint,
              foregroundColor: _dark,
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

  static const Color _dark = Color(0xFF0f172a);
  static const Color _mint = Color(0xFF00d68f);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fafc),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFf1f5f9)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748b),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _dark,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFFf1f5f9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 13, color: const Color(0xFF0f172a)),
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
