import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../providers/repository_providers.dart';
import '../providers/schedule_editor_notifier.dart';

/// Bottom sheet for browsing and selecting exercises to add to a schedule.
///
/// On selection, the caller receives a list of [ScheduleExerciseEntry] objects
/// via the [onExercisesAdded] callback.
class AddExerciseBottomSheet extends ConsumerStatefulWidget {
  const AddExerciseBottomSheet({
    super.key,
    required this.onExercisesAdded,
    this.onCreateNew,
  });

  final void Function(List<ScheduleExerciseEntry> selected) onExercisesAdded;
  final VoidCallback? onCreateNew;

  @override
  ConsumerState<AddExerciseBottomSheet> createState() =>
      _AddExerciseBottomSheetState();
}

final _exercisesProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllExercises();
});

class _AddExerciseBottomSheetState
    extends ConsumerState<AddExerciseBottomSheet> {
  String _query = '';
  String? _selectedMuscleFilter;
  final Set<String> _selectedIds = {};

  static const _muscleFilters = [
    'All', 'Chest', 'Back', 'Shoulders',
    'Arms', 'Core', 'Legs', 'Glutes',
  ];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(_exercisesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    // Grab handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedIds.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_selectedIds.length} selected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search exercises…',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Muscle category filter pills
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _muscleFilters.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _muscleFilters[i];
                          final isAll = cat == 'All';
                          final isActive = isAll
                              ? _selectedMuscleFilter == null
                              : _selectedMuscleFilter == cat;
                          return GestureDetector(
                            onTap: () => setState(() =>
                                _selectedMuscleFilter =
                                    isAll ? null : cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive ? colorScheme.primaryContainer : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── Exercise list ─────────────────────────────────────────────
              Expanded(
                child: exercisesAsync.when(
                  data: (exercises) {
                    final filtered = _filterExercises(exercises);
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No exercises found',
                          style: TextStyle(color: Color(0xFF94a3b8)),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _ExerciseTile(
                            exercise: filtered[i],
                            isSelected:
                                _selectedIds.contains(filtered[i].id),
                            onToggle: () => setState(() {
                              if (_selectedIds.contains(filtered[i].id)) {
                                _selectedIds.remove(filtered[i].id);
                              } else {
                                _selectedIds.add(filtered[i].id);
                              }
                            }),
                          ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, s) => Center(
                    child: Text('Error: $e'),
                  ),
                ),
              ),

              // ── Sticky bottom tray ────────────────────────────────────────
              _BottomTray(
                selectedCount: _selectedIds.length,
                exercises: exercisesAsync.hasValue
                    ? _getSelectedEntries(exercisesAsync.value!)
                    : [],
                onAddSelected: () {
                  if (exercisesAsync.hasValue) {
                    widget.onExercisesAdded(
                        _getSelectedEntries(exercisesAsync.value!));
                  }
                  Navigator.of(context).pop();
                },
                onCreateNew: () {
                  Navigator.of(context).pop();
                  widget.onCreateNew?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Exercise> _filterExercises(List<Exercise> all) {
    return all.where((ex) {
      final q = _query.toLowerCase();
      final matchesSearch = q.isEmpty ||
          ex.name.toLowerCase().contains(q) ||
          ex.equipment.name.toLowerCase().contains(q);
      final matchesCat = _selectedMuscleFilter == null; // category filter
      return matchesSearch && matchesCat;
    }).toList();
  }

  List<ScheduleExerciseEntry> _getSelectedEntries(List<Exercise> allExercises) {
    return _selectedIds.map((id) {
      final ex = allExercises.firstWhere((e) => e.id == id, orElse: () => Exercise(id: id, name: id, equipment: Equipment.other, movementClassification: MovementClassification.other, isCustom: false));
      return ScheduleExerciseEntry(
        exerciseId: id,
        exerciseName: ex.name,
      );
    }).toList();
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.isSelected,
    required this.onToggle,
  });

  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.fitness_center_rounded,
              color: colorScheme.primary, size: 22),
        ),
        title: Text(
          exercise.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            _Tag(exercise.equipment.name),
            const SizedBox(width: 6),
            _Tag(exercise.movementClassification.name),
          ],
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSelected ? Icons.check_rounded : Icons.add_rounded,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
        onTap: onToggle,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BottomTray extends StatelessWidget {
  const _BottomTray({
    required this.selectedCount,
    required this.exercises,
    required this.onAddSelected,
    required this.onCreateNew,
  });

  final int selectedCount;
  final List<ScheduleExerciseEntry> exercises;
  final VoidCallback onAddSelected;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // + Create New
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('Create New'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add Selected
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selectedCount > 0 ? onAddSelected : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                selectedCount > 0
                    ? 'Add $selectedCount Exercise${selectedCount > 1 ? 's' : ''}'
                    : 'Select Exercises',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
