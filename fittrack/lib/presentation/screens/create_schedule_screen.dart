import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/schedule_editor_notifier.dart';
import '../widgets/add_exercise_bottom_sheet.dart';

/// Builds card decoration dynamically adapting between Light, Slate Dark, and Pure OLED Dark modes.
BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
  final theme = Theme.of(context);
  final isLight = theme.brightness == Brightness.light;
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: isLight ? null : Border.all(color: theme.colorScheme.outline, width: 1),
    boxShadow: isLight
        ? const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ]
        : null,
  );
}

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
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Core',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
  ];

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
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Center(
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'HYPERTROPHY SPLIT PLAN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
            onPressed: () => context.pop(),
            tooltip: 'Close',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Top Metrics Summary Card ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _MetricsCard(
                    durationLabel: state.totalDurationFormatted,
                    totalSets: state.totalSets,
                    calories: state.estimatedCalories,
                  ),
                ),
              ),

              // ── Schedule Details Inputs ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _InputSection(
                    nameCtrl: _nameCtrl,
                    descCtrl: _descCtrl,
                    onNameChanged: notifier.setName,
                    onDescChanged: notifier.setDescription,
                  ),
                ),
              ),

              // ── Target Muscles Section ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _TargetMusclesSection(
                    allMuscles: _allMuscles,
                    selectedMuscles: state.targetMuscles,
                    onToggleMuscle: notifier.toggleMuscle,
                  ),
                ),
              ),

              // ── Assigned Weekdays Section ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _AssignedWeekdaysSection(
                    assignedWeekdays: state.assignedWeekdays,
                    onToggleWeekday: notifier.toggleWeekday,
                  ),
                ),
              ),

              // ── Exercises Section Header ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${state.exercises.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showAddExerciseSheet(context, notifier),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add Exercise',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Exercise Cards Stack / Empty State ───────────────────────
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
                      final isExpanded = _expandedExerciseIndex == index;

                      return _ExerciseCard(
                        key: ValueKey('${entry.exerciseId}_$index'),
                        index: index,
                        entry: entry,
                        isExpanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            if (_expandedExerciseIndex == index) {
                              _expandedExerciseIndex = null;
                            } else {
                              _expandedExerciseIndex = index;
                            }
                          });
                        },
                        onRemove: () => notifier.removeExercise(index),
                        onChangeSets: (v) =>
                            notifier.updateExerciseParam(index, sets: v),
                        onChangeReps: (v) =>
                            notifier.updateExerciseParam(index, reps: v),
                        onChangeWeight: (v) =>
                            notifier.updateExerciseParam(index, weightKg: v),
                        onChangeRest: (v) =>
                            notifier.updateExerciseParam(index, restSeconds: v),
                      );
                    },
                  ),
                ),

              // Bottom spacer for sticky CTA
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // ── Sticky Save Schedule Bottom Bar ──────────────────────────────
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
          content: Text(
            'Schedule saved!',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      router.pop();
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Floating card displaying 3-column metrics grid: Duration, Sets, Est. Burn.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.durationLabel,
    required this.totalSets,
    required this.calories,
  });

  final String durationLabel;
  final int totalSets;
  final int calories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: _buildCardDecoration(context, radius: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Duration Col
            Expanded(
              child: _MetricColumn(
                icon: Icons.timer_outlined,
                value: durationLabel,
                label: 'Duration',
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 4,
              endIndent: 4,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            // Sets Col
            Expanded(
              child: _MetricColumn(
                icon: Icons.view_headline_rounded,
                value: '$totalSets',
                label: 'Sets',
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 4,
              endIndent: 4,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            // Est. Burn Col
            Expanded(
              child: _MetricColumn(
                icon: Icons.local_fire_department_rounded,
                value: '~$calories kcal',
                label: 'Est. Burn',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Text input fields for Schedule Name and Description.
class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.nameCtrl,
    required this.descCtrl,
    required this.onNameChanged,
    required this.onDescChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Schedule Name Label
        Text(
          'SCHEDULE NAME',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: colorScheme.outline, width: 1) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: nameCtrl,
            onChanged: onNameChanged,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Push Hypertrophy A',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Description Label
        Row(
          children: [
            Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(optional)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: colorScheme.outline, width: 1) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: descCtrl,
            maxLines: 3,
            minLines: 2,
            onChanged: onDescChanged,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Compound pressing followed by lateral deltoid burnout...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// Target muscles multi-select chips section.
class _TargetMusclesSection extends StatelessWidget {
  const _TargetMusclesSection({
    required this.allMuscles,
    required this.selectedMuscles,
    required this.onToggleMuscle,
  });

  final List<String> allMuscles;
  final List<String> selectedMuscles;
  final ValueChanged<String> onToggleMuscle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              'TARGET MUSCLES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                '${selectedMuscles.length} Selected',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Multi-select',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allMuscles.map((muscle) {
            final isSelected = selectedMuscles.contains(muscle);
            return GestureDetector(
              onTap: () => onToggleMuscle(muscle),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.transparent : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: colorScheme.primary, width: 1.5)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Assigned weekdays recurring picker section.
class _AssignedWeekdaysSection extends StatelessWidget {
  const _AssignedWeekdaysSection({
    required this.assignedWeekdays,
    required this.onToggleWeekday,
  });

  final List<int> assignedWeekdays;
  final ValueChanged<int> onToggleWeekday;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              'ASSIGNED WEEKDAYS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(Weekly recurring)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const Spacer(),
            Text(
              '${assignedWeekdays.length} days / week',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            final dayNumber = i + 1; // 1 = Monday ... 7 = Sunday
            final isActive = assignedWeekdays.contains(dayNumber);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                child: GestureDetector(
                  onTap: () => onToggleWeekday(dayNumber),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: isActive
                          ? Border.all(color: colorScheme.primary, width: 1.5)
                          : (isDark
                              ? Border.all(color: colorScheme.outline, width: 1)
                              : null),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? colorScheme.primary : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Empty state when no exercises have been added yet.
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
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: _buildCardDecoration(context, radius: 20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Add your first exercise',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to browse the exercise library',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible exercise configuration card with 2x2 parameter steppers.
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

  int get _estWorkoutMinutes {
    final s = entry.targetSets;
    if (s <= 0) return 0;
    final totalSec = (s * 60) + ((s > 1 ? s - 1 : 1) * entry.restDurationSeconds) + 90;
    return (totalSec / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildCardDecoration(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row (Tap to expand/collapse) ─────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    // Drag Grip Handle
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          size: 20,
                        ),
                      ),
                    ),
                    // Sequence Badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isExpanded
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.exerciseName.isEmpty
                                ? 'Exercise ${index + 1}'
                                : entry.exerciseName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (isExpanded)
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Configuring parameters',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '${entry.targetSets} sets • ${entry.targetReps} reps • $_estWorkoutMinutes min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Chevron toggle
                    IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: onToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    // Remove button
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        size: 18,
                      ),
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

          // ── Parameter Grid (Visible when expanded) ──────────────────────
          if (isExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StepperBlock(
                        label: 'SETS',
                        valueText: '${entry.targetSets}',
                        unitText: '',
                        onMinus: () =>
                            onChangeSets((entry.targetSets - 1).clamp(1, 99)),
                        onPlus: () =>
                            onChangeSets((entry.targetSets + 1).clamp(1, 99)),
                        onTapValue: () => _showEditDialog(
                          context,
                          'Sets',
                          entry.targetSets.toDouble(),
                          (v) => onChangeSets(v.toInt()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StepperBlock(
                        label: 'REPS',
                        valueText: '${entry.targetReps}',
                        unitText: '',
                        onMinus: () =>
                            onChangeReps((entry.targetReps - 1).clamp(1, 999)),
                        onPlus: () =>
                            onChangeReps((entry.targetReps + 1).clamp(1, 999)),
                        onTapValue: () => _showEditDialog(
                          context,
                          'Reps',
                          entry.targetReps.toDouble(),
                          (v) => onChangeReps(v.toInt()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StepperBlock(
                        label: 'WEIGHT',
                        valueText: entry.targetWeightKg == 0
                            ? 'BW'
                            : entry.targetWeightKg.toStringAsFixed(
                                entry.targetWeightKg % 1 == 0 ? 0 : 1),
                        unitText: entry.targetWeightKg == 0 ? '' : 'kg',
                        onMinus: () => onChangeWeight(
                          (entry.targetWeightKg - 0.5).clamp(0, 999).toDouble(),
                        ),
                        onPlus: () => onChangeWeight(
                          (entry.targetWeightKg + 0.5).clamp(0, 999).toDouble(),
                        ),
                        onTapValue: () => _showEditDialog(
                          context,
                          'Weight (kg)',
                          entry.targetWeightKg,
                          onChangeWeight,
                          isDouble: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StepperBlock(
                        label: 'EST. WORKOUT TIME',
                        valueText: '$_estWorkoutMinutes',
                        unitText: 'min',
                        onMinus: () => onChangeRest(
                          (entry.restDurationSeconds - 15).clamp(15, 600),
                        ),
                        onPlus: () => onChangeRest(
                          (entry.restDurationSeconds + 15).clamp(15, 600),
                        ),
                        onTapValue: () => _showEditDialog(
                          context,
                          'Rest Duration (sec)',
                          entry.restDurationSeconds.toDouble(),
                          (v) => onChangeRest(v.toInt()),
                        ),
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

  void _showEditDialog(
    BuildContext context,
    String title,
    double initial,
    ValueChanged<double> onSave, {
    bool isDouble = false,
  }) {
    final controller = TextEditingController(
      text: isDouble ? initial.toString() : initial.toInt().toString(),
    );
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierColor: colorScheme.scrim.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Edit $title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter value',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
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
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
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

/// Single stepper block with label, `-`, center value, and `+` buttons.
class _StepperBlock extends StatelessWidget {
  const _StepperBlock({
    required this.label,
    required this.valueText,
    required this.unitText,
    required this.onMinus,
    required this.onPlus,
    required this.onTapValue,
  });

  final String label;
  final String valueText;
  final String unitText;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTapValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: isLight ? null : Border.all(color: colorScheme.outline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus button
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onTap: onMinus,
                ),
                // Value (tappable)
                GestureDetector(
                  onTap: onTapValue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          valueText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (unitText.isNotEmpty) ...[
                          const SizedBox(width: 3),
                          Text(
                            unitText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Plus button
                _StepperButton(
                  icon: Icons.add_rounded,
                  onTap: onPlus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small +/- button used inside stepper blocks.
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLight ? colorScheme.outlineVariant : colorScheme.outline,
            width: 1,
          ),
          boxShadow: isLight
              ? const [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }
}

/// Sticky bottom CTA button to save schedule.
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ]
            : null,
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
                  fontWeight: FontWeight.w500,
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
                disabledBackgroundColor:
                    colorScheme.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor:
                    colorScheme.onSurface.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save Schedule',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
