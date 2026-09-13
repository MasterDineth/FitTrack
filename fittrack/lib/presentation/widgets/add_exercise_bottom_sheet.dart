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
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf7f9fb),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    // Grab handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe2e8f0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedIds.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _mint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_selectedIds.length} selected',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _dark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search exercises…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFf1f5f9),
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
                                    isActive ? _mint : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? _mint
                                      : const Color(0xFFe2e8f0),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? _dark
                                      : const Color(0xFF64748b),
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _mint : const Color(0xFFe2e8f0),
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
            color: _mint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center_rounded,
              color: _mint, size: 22),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _dark,
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
            color: isSelected ? _mint : const Color(0xFFf1f5f9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSelected ? Icons.check_rounded : Icons.add_rounded,
            color: isSelected ? _dark : const Color(0xFF64748b),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f5f9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF64748b),
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                foregroundColor: _dark,
                side: const BorderSide(color: Color(0xFFe2e8f0)),
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
                backgroundColor: _mint,
                foregroundColor: _dark,
                disabledBackgroundColor: const Color(0xFFe2e8f0),
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
