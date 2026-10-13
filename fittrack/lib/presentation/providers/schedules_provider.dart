import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/workout_schedule.dart';
import '../../domain/entities/trending_program.dart';
import '../../domain/entities/routine_spotlight.dart';
import '../../domain/entities/custom_workout_routine.dart';
import 'repository_providers.dart';

export '../../domain/entities/schedule_exercise.dart';
export '../../domain/entities/workout_schedule.dart';
export '../../domain/entities/trending_program.dart';
export '../../domain/entities/routine_spotlight.dart';
export '../../domain/entities/custom_workout_routine.dart';

part 'schedules_provider.g.dart';

/// Available sorting options for the workout library.
enum SortOption {
  relevant,
  duration,
  title,
}

/// State representation for the Schedules & Workout Library module.
@immutable
class SchedulesState {
  const SchedulesState({
    required this.allSchedules,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.selectedSort = SortOption.relevant,
    this.expandedScheduleIds = const {'sch1'},
    this.bookmarkedIds = const {'sch1', 'sch2', 'sched_ppl_hypertrophy', 'trend_1'},
    this.isLoading = false,
  });

  final List<WorkoutSchedule> allSchedules;
  final String searchQuery;
  final String selectedCategoryFilter;
  final SortOption selectedSort;
  final Set<String> expandedScheduleIds;
  final Set<String> bookmarkedIds;
  final bool isLoading;

  /// Whether a specific schedule card is expanded in search/library view.
  bool isExpanded(String id) => expandedScheduleIds.contains(id);

  /// Whether all current filtered schedules are expanded.
  bool get allExpanded {
    final list = filteredSchedules;
    if (list.isEmpty) return false;
    return list.every((s) => expandedScheduleIds.contains(s.id));
  }

  /// Returns recommended programs focused on Advanced Hypertrophy & Strength Plateau Breakers.
  List<WorkoutSchedule> get recommendedSchedules => allSchedules
      .where((s) =>
          !s.isCustom &&
          (s.focus.toLowerCase() == 'hypertrophy' ||
              s.focus.toLowerCase() == 'strength' ||
              s.title.toLowerCase().contains('plateau') ||
              s.experience.toLowerCase() == 'advanced'))
      .toList();

  /// Returns schedules marked as favorite/bookmarked.
  List<WorkoutSchedule> get bookmarkedSchedules =>
      allSchedules.where((s) => s.isFavorite || bookmarkedIds.contains(s.id)).toList();

  /// Returns user-created custom schedules.
  List<WorkoutSchedule> get customSchedules =>
      allSchedules.where((s) => s.isCustom).toList();

  /// Returns schedules filtered by both the selected category chip and search query,
  /// sorted according to [selectedSort].
  List<WorkoutSchedule> get filteredSchedules {
    final list = allSchedules.where((schedule) {
      // 1. Category / Filter Chip matching
      if (selectedCategoryFilter != 'All' && selectedCategoryFilter != 'All Goals') {
        final filter = selectedCategoryFilter.toLowerCase();
        final matchesFocus = schedule.focus.toLowerCase() == filter;
        final matchesExperience = schedule.experience.toLowerCase() == filter;
        final matchesEquipment = schedule.equipment.toLowerCase() == filter;

        if (!matchesFocus && !matchesExperience && !matchesEquipment) {
          return false;
        }
      }

      // 2. Search Query matching
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchesTitle = schedule.title.toLowerCase().contains(q);
        final matchesDescription =
            schedule.description.toLowerCase().contains(q);
        final matchesFocus = schedule.focus.toLowerCase().contains(q);
        final matchesExperience = schedule.experience.toLowerCase().contains(q);
        final matchesEquipment = schedule.equipment.toLowerCase().contains(q);
        final matchesMuscles =
            schedule.targetMuscles.any((m) => m.toLowerCase().contains(q));

        if (!matchesTitle &&
            !matchesDescription &&
            !matchesFocus &&
            !matchesExperience &&
            !matchesEquipment &&
            !matchesMuscles) {
          return false;
        }
      }

      return true;
    }).toList();

    // 3. Sorting logic
    switch (selectedSort) {
      case SortOption.duration:
        list.sort((a, b) => a.durationWeeks.compareTo(b.durationWeeks));
        break;
      case SortOption.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.relevant:
        // Preserves seed / profile relevance ranking
        break;
    }

    return list;
  }

  SchedulesState copyWith({
    List<WorkoutSchedule>? allSchedules,
    String? searchQuery,
    String? selectedCategoryFilter,
    SortOption? selectedSort,
    Set<String>? expandedScheduleIds,
    Set<String>? bookmarkedIds,
    bool? isLoading,
  }) {
    return SchedulesState(
      allSchedules: allSchedules ?? this.allSchedules,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedSort: selectedSort ?? this.selectedSort,
      expandedScheduleIds: expandedScheduleIds ?? this.expandedScheduleIds,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchedulesState &&
          runtimeType == other.runtimeType &&
          listEquals(allSchedules, other.allSchedules) &&
          searchQuery == other.searchQuery &&
          selectedCategoryFilter == other.selectedCategoryFilter &&
          selectedSort == other.selectedSort &&
          setEquals(expandedScheduleIds, other.expandedScheduleIds) &&
          setEquals(bookmarkedIds, other.bookmarkedIds) &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(allSchedules),
        searchQuery,
        selectedCategoryFilter,
        selectedSort,
        Object.hashAll(expandedScheduleIds),
        Object.hashAll(bookmarkedIds),
        isLoading,
      );
}

/// Initial robust mock seed data covering Hypertrophy, Strength, Custom, and Bookmarks,
/// equipped with complete deep exercises and routine breakdowns.
const _initialSeedSchedules = <WorkoutSchedule>[
  WorkoutSchedule(
    id: 'sch1',
    title: 'Push-Pull-Legs Split',
    description:
        'High mechanical tension for progressive muscular overload across push and pull days.',
    focus: 'Hypertrophy',
    experience: 'Intermediate',
    equipment: 'Full Gym',
    durationWeeks: 8,
    daysPerWeek: 4,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Chest', 'Back', 'Legs'],
    exerciseCount: 3,
    estimatedMinutes: 60,
    exercises: [
      ScheduleExercise(
        id: 'sch1_ex1',
        scheduleId: 'sch1',
        exerciseId: 'ex1',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 85.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'sch1_ex2',
        scheduleId: 'sch1',
        exerciseId: 'ex2',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 30.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'sch1_ex3',
        scheduleId: 'sch1',
        exerciseId: 'ex3',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sch2',
    title: 'Strength Plateau Breaker',
    description:
        'Periodized heavy triples and submaximal recovery designed to break squat and bench plateaus.',
    focus: 'Strength',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 6,
    daysPerWeek: 5,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Back', 'Core', 'Quads'],
    exerciseCount: 5,
    estimatedMinutes: 55,
  ),
  WorkoutSchedule(
    id: 'sch3',
    title: 'Arnold Split Classic',
    description:
        'Antagonistic supersets pairing chest with back, shoulders with arms, and dedicated leg blast.',
    focus: 'Hypertrophy',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 10,
    daysPerWeek: 6,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Chest', 'Back', 'Arms'],
    exerciseCount: 6,
    estimatedMinutes: 70,
  ),
  WorkoutSchedule(
    id: 'sch4',
    title: 'German Volume Training (GVT)',
    description:
        '10×10 volume protocol for high neuromuscular exhaustion and extreme hypertrophy adaptation.',
    focus: 'Hypertrophy',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 6,
    daysPerWeek: 3,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Quads', 'Chest', 'Lats'],
    exerciseCount: 3,
    estimatedMinutes: 60,
  ),
  WorkoutSchedule(
    id: 'sch5',
    title: 'Torso & Limb Split',
    description:
        'Separates chest and back days from arm and quad isolation for maximal joint recovery.',
    focus: 'Hypertrophy',
    experience: 'Intermediate',
    equipment: 'Barbell & Cable',
    durationWeeks: 8,
    daysPerWeek: 4,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Upper Body', 'Arms'],
    exerciseCount: 4,
    estimatedMinutes: 45,
  ),
  WorkoutSchedule(
    id: 'sched_ppl_hypertrophy',
    title: 'Push-Pull-Legs Split',
    description:
        'High mechanical tension for progressive muscular overload across push and pull days.',
    focus: 'Hypertrophy',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 8,
    daysPerWeek: 4,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Chest', 'Back', 'Legs'],
    exerciseCount: 6,
    estimatedMinutes: 60,
    exercises: [
      ScheduleExercise(
        id: 'ppl_ex1',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 85.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'ppl_ex2',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_incline_dumbbell_press',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 30.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'ppl_ex3',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_standing_overhead_press',
        sortOrder: 3,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 52.5,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'ppl_ex4',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_cable_lateral_raise',
        sortOrder: 4,
        targetSets: 4,
        targetReps: 15,
        targetWeightKg: 10.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'ppl_ex5',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_cable_chest_flyes',
        sortOrder: 5,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'ppl_ex6',
        scheduleId: 'sched_ppl_hypertrophy',
        exerciseId: 'ex_overhead_triceps_extension',
        sortOrder: 6,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 25.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_strength_plateau',
    title: 'Strength Plateau Breaker',
    description:
        'Periodized heavy triples and submaximal recovery designed to break squat and bench plateaus.',
    focus: 'Strength',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 6,
    daysPerWeek: 3,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Back', 'Core', 'Quads'],
    exerciseCount: 5,
    estimatedMinutes: 55,
    exercises: [
      ScheduleExercise(
        id: 'spb_ex1',
        scheduleId: 'sched_strength_plateau',
        exerciseId: 'ex_barbell_back_squat',
        sortOrder: 1,
        targetSets: 5,
        targetReps: 3,
        targetWeightKg: 145.0,
        restDurationSeconds: 180,
      ),
      ScheduleExercise(
        id: 'spb_ex2',
        scheduleId: 'sched_strength_plateau',
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 2,
        targetSets: 5,
        targetReps: 3,
        targetWeightKg: 105.0,
        restDurationSeconds: 180,
      ),
      ScheduleExercise(
        id: 'spb_ex3',
        scheduleId: 'sched_strength_plateau',
        exerciseId: 'ex_conventional_deadlift',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 3,
        targetWeightKg: 165.0,
        restDurationSeconds: 180,
      ),
      ScheduleExercise(
        id: 'spb_ex4',
        scheduleId: 'sched_strength_plateau',
        exerciseId: 'ex_weighted_pull_ups',
        sortOrder: 4,
        targetSets: 4,
        targetReps: 5,
        targetWeightKg: 15.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'spb_ex5',
        scheduleId: 'sched_strength_plateau',
        exerciseId: 'ex_hanging_leg_raise',
        sortOrder: 5,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 0.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_arnold_classic',
    title: 'Arnold Split Classic',
    description:
        'Antagonistic supersets pairing chest with back, shoulders with arms, and dedicated leg blast.',
    focus: 'Hypertrophy',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 10,
    daysPerWeek: 6,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Chest', 'Back', 'Arms'],
    exerciseCount: 6,
    estimatedMinutes: 70,
    exercises: [
      ScheduleExercise(
        id: 'arnold_ex1',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_incline_barbell_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 75.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'arnold_ex2',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_bent_over_barbell_row',
        sortOrder: 2,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 70.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'arnold_ex3',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_weighted_chest_dips',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 15.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'arnold_ex4',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_lat_pulldown',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 65.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'arnold_ex5',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_dumbbell_bicep_curl',
        sortOrder: 5,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 16.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'arnold_ex6',
        scheduleId: 'sched_arnold_classic',
        exerciseId: 'ex_triceps_pushdown',
        sortOrder: 6,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 30.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_upper_lower_power',
    title: 'Upper / Lower Power',
    description:
        'Balanced 4-day cadence optimizing heavy mechanical tension with hypertrophy accessory work.',
    focus: 'Strength',
    experience: 'Intermediate',
    equipment: 'Full Gym',
    durationWeeks: 8,
    daysPerWeek: 4,
    isFavorite: true,
    isCustom: false,
    targetMuscles: ['Upper Body', 'Lower Body'],
    exerciseCount: 5,
    estimatedMinutes: 50,
    exercises: [
      ScheduleExercise(
        id: 'ulp_ex1',
        scheduleId: 'sched_upper_lower_power',
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 5,
        targetWeightKg: 90.0,
        restDurationSeconds: 150,
      ),
      ScheduleExercise(
        id: 'ulp_ex2',
        scheduleId: 'sched_upper_lower_power',
        exerciseId: 'ex_bent_over_barbell_row',
        sortOrder: 2,
        targetSets: 4,
        targetReps: 6,
        targetWeightKg: 75.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'ulp_ex3',
        scheduleId: 'sched_upper_lower_power',
        exerciseId: 'ex_standing_overhead_press',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 8,
        targetWeightKg: 45.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'ulp_ex4',
        scheduleId: 'sched_upper_lower_power',
        exerciseId: 'ex_dumbbell_bicep_curl',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 14.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'ulp_ex5',
        scheduleId: 'sched_upper_lower_power',
        exerciseId: 'ex_triceps_pushdown',
        sortOrder: 5,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 27.5,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_custom_push_a',
    title: 'Push Hypertrophy A',
    description:
        'Custom upper body push emphasis: incline bench, heavy weighted dips, and cable side laterals.',
    focus: 'Hypertrophy',
    experience: 'Intermediate',
    equipment: 'Dumbbells',
    durationWeeks: 6,
    daysPerWeek: 3,
    isFavorite: false,
    isCustom: true,
    targetMuscles: ['Delts', 'Triceps', 'Chest'],
    exerciseCount: 4,
    estimatedMinutes: 45,
    exercises: [
      ScheduleExercise(
        id: 'cpa_ex1',
        scheduleId: 'sched_custom_push_a',
        exerciseId: 'ex_incline_dumbbell_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 32.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'cpa_ex2',
        scheduleId: 'sched_custom_push_a',
        exerciseId: 'ex_weighted_chest_dips',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 20.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'cpa_ex3',
        scheduleId: 'sched_custom_push_a',
        exerciseId: 'ex_cable_lateral_raise',
        sortOrder: 3,
        targetSets: 4,
        targetReps: 15,
        targetWeightKg: 12.5,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'cpa_ex4',
        scheduleId: 'sched_custom_push_a',
        exerciseId: 'ex_triceps_pushdown',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 35.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_custom_legs_core',
    title: 'Heavy Leg Day & Core',
    description:
        'Squat specialization protocol paired with high-stability isometric core bracing.',
    focus: 'Strength',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 4,
    daysPerWeek: 2,
    isFavorite: false,
    isCustom: true,
    targetMuscles: ['Quads', 'Hamstrings', 'Core'],
    exerciseCount: 4,
    estimatedMinutes: 50,
    exercises: [
      ScheduleExercise(
        id: 'clc_ex1',
        scheduleId: 'sched_custom_legs_core',
        exerciseId: 'ex_barbell_back_squat',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 6,
        targetWeightKg: 130.0,
        restDurationSeconds: 150,
      ),
      ScheduleExercise(
        id: 'clc_ex2',
        scheduleId: 'sched_custom_legs_core',
        exerciseId: 'ex_romanian_deadlift',
        sortOrder: 2,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 115.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: 'clc_ex3',
        scheduleId: 'sched_custom_legs_core',
        exerciseId: 'ex_bodyweight_squats',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 24.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'clc_ex4',
        scheduleId: 'sched_custom_legs_core',
        exerciseId: 'ex_hanging_leg_raise',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 15,
        targetWeightKg: 0.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_gvt_10x10',
    title: 'German Volume Training (GVT)',
    description:
        '10×10 volume protocol for high neuromuscular exhaustion and rapid hypertrophy stimulation.',
    focus: 'Hypertrophy',
    experience: 'Advanced',
    equipment: 'Full Gym',
    durationWeeks: 6,
    daysPerWeek: 3,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Quads', 'Chest', 'Lats'],
    exerciseCount: 3,
    estimatedMinutes: 60,
    exercises: [
      ScheduleExercise(
        id: 'gvt_ex1',
        scheduleId: 'sched_gvt_10x10',
        exerciseId: 'ex_barbell_back_squat',
        sortOrder: 1,
        targetSets: 10,
        targetReps: 10,
        targetWeightKg: 90.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'gvt_ex2',
        scheduleId: 'sched_gvt_10x10',
        exerciseId: 'ex_romanian_deadlift',
        sortOrder: 2,
        targetSets: 10,
        targetReps: 10,
        targetWeightKg: 75.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'gvt_ex3',
        scheduleId: 'sched_gvt_10x10',
        exerciseId: 'ex_bodyweight_squats',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 15,
        targetWeightKg: 50.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_torso_limb',
    title: 'Torso & Limb Split',
    description:
        'Separates chest and back days from arm and quad isolation for maximal joint recovery.',
    focus: 'Hypertrophy',
    experience: 'Intermediate',
    equipment: 'Full Gym',
    durationWeeks: 8,
    daysPerWeek: 4,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Upper Body', 'Arms'],
    exerciseCount: 4,
    estimatedMinutes: 45,
    exercises: [
      ScheduleExercise(
        id: 'tl_ex1',
        scheduleId: 'sched_torso_limb',
        exerciseId: 'ex_incline_dumbbell_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 30.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'tl_ex2',
        scheduleId: 'sched_torso_limb',
        exerciseId: 'ex_lat_pulldown',
        sortOrder: 2,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 65.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'tl_ex3',
        scheduleId: 'sched_torso_limb',
        exerciseId: 'ex_cable_chest_flyes',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'tl_ex4',
        scheduleId: 'sched_torso_limb',
        exerciseId: 'ex_bent_over_barbell_row',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 60.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_bodyweight_foundations',
    title: 'Bodyweight Foundations',
    description:
        'Master relative body strength, scapular control, pull-up progressions, and core hollow holds.',
    focus: 'General',
    experience: 'Beginner',
    equipment: 'Bodyweight',
    durationWeeks: 4,
    daysPerWeek: 3,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Core', 'Back', 'Arms'],
    exerciseCount: 4,
    estimatedMinutes: 35,
    exercises: [
      ScheduleExercise(
        id: 'bw_ex1',
        scheduleId: 'sched_bodyweight_foundations',
        exerciseId: 'ex_pull_ups',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 0.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: 'bw_ex2',
        scheduleId: 'sched_bodyweight_foundations',
        exerciseId: 'ex_push_ups',
        sortOrder: 2,
        targetSets: 4,
        targetReps: 15,
        targetWeightKg: 0.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'bw_ex3',
        scheduleId: 'sched_bodyweight_foundations',
        exerciseId: 'ex_bodyweight_squats',
        sortOrder: 3,
        targetSets: 4,
        targetReps: 20,
        targetWeightKg: 0.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: 'bw_ex4',
        scheduleId: 'sched_bodyweight_foundations',
        exerciseId: 'ex_hanging_leg_raise',
        sortOrder: 4,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 0.0,
        restDurationSeconds: 60,
      ),
    ],
  ),
  WorkoutSchedule(
    id: 'sched_texas_method',
    title: 'Texas Method 3-Day',
    description:
        'Volume day, recovery day, and intensity rotation for compound powerlifting dominance.',
    focus: 'Strength',
    experience: 'Intermediate',
    equipment: 'Full Gym',
    durationWeeks: 12,
    daysPerWeek: 3,
    isFavorite: false,
    isCustom: false,
    targetMuscles: ['Posterior Chain', 'Quads', 'Chest'],
    exerciseCount: 3,
    estimatedMinutes: 55,
    exercises: [
      ScheduleExercise(
        id: 'tm_ex1',
        scheduleId: 'sched_texas_method',
        exerciseId: 'ex_barbell_back_squat',
        sortOrder: 1,
        targetSets: 5,
        targetReps: 5,
        targetWeightKg: 125.0,
        restDurationSeconds: 180,
      ),
      ScheduleExercise(
        id: 'tm_ex2',
        scheduleId: 'sched_texas_method',
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 2,
        targetSets: 5,
        targetReps: 5,
        targetWeightKg: 87.5,
        restDurationSeconds: 150,
      ),
      ScheduleExercise(
        id: 'tm_ex3',
        scheduleId: 'sched_texas_method',
        exerciseId: 'ex_conventional_deadlift',
        sortOrder: 3,
        targetSets: 1,
        targetReps: 5,
        targetWeightKg: 155.0,
        restDurationSeconds: 180,
      ),
    ],
  ),
];

/// Riverpod Notifier managing Workout Schedules, Filters, Search, and Bookmarks.
@riverpod
class SchedulesNotifier extends _$SchedulesNotifier {
  @override
  SchedulesState build() {
    return const SchedulesState(
      allSchedules: _initialSeedSchedules,
      searchQuery: '',
      selectedCategoryFilter: 'All',
      selectedSort: SortOption.relevant,
      expandedScheduleIds: {'sch1'},
      bookmarkedIds: {'sch1', 'sch2', 'sched_ppl_hypertrophy', 'trend_1'},
    );
  }

  /// Convenience getters mirroring state
  List<WorkoutSchedule> get recommendedSchedules => state.recommendedSchedules;
  List<WorkoutSchedule> get bookmarkedSchedules => state.bookmarkedSchedules;
  List<WorkoutSchedule> get customSchedules => state.customSchedules;
  List<WorkoutSchedule> get filteredSchedules => state.filteredSchedules;
  bool isExpanded(String id) => state.isExpanded(id);
  bool get allExpanded => state.allExpanded;

  /// Toggles expansion for an individual result card.
  void toggleExpand(String id) {
    final next = Set<String>.from(state.expandedScheduleIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(expandedScheduleIds: next);
  }

  /// Expands all filtered schedules if not all are expanded, else collapses all.
  void toggleExpandAll() {
    if (state.allExpanded) {
      collapseAll();
    } else {
      expandAll();
    }
  }

  /// Expands all visible results.
  void expandAll() {
    final ids = state.filteredSchedules.map((s) => s.id).toSet();
    state = state.copyWith(expandedScheduleIds: ids);
  }

  /// Collapses all visible results.
  void collapseAll() {
    state = state.copyWith(expandedScheduleIds: {});
  }

  /// Toggles favorite/bookmark status for a given schedule [id] and persists to SQLite.
  void toggleBookmark(String id) {
    final isNowBookmarked = !state.bookmarkedIds.contains(id);
    final newBookmarks = Set<String>.from(state.bookmarkedIds);
    if (isNowBookmarked) {
      newBookmarks.add(id);
    } else {
      newBookmarks.remove(id);
    }

    final updatedSchedules = state.allSchedules.map((schedule) {
      if (schedule.id == id) {
        return schedule.copyWith(isFavorite: isNowBookmarked);
      }
      return schedule;
    }).toList();

    state = state.copyWith(
      allSchedules: updatedSchedules,
      bookmarkedIds: newBookmarks,
    );

    // Persist to local database
    try {
      ref.read(scheduleRepositoryProvider).toggleBookmark(id, isNowBookmarked);
    } catch (e) {
      debugPrint('Error syncing bookmark with repository: $e');
    }
  }

  /// Loads schedules from SQLite database and merges with memory seeds.
  Future<void> loadFromDatabase() async {
    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final dbSchedules = await repo.getAllSchedules();
      if (dbSchedules.isNotEmpty) {
        final dbWorkoutSchedules =
            dbSchedules.map(WorkoutSchedule.fromSchedule).toList();
        final map = <String, WorkoutSchedule>{};
        for (final s in dbWorkoutSchedules) {
          map[s.id] = s;
        }
        for (final s in state.allSchedules) {
          if (!map.containsKey(s.id)) {
            map[s.id] = s;
          }
        }
        final bookmarks = await repo.getBookmarkedSchedules();
        final bookmarkIds = bookmarks.map((b) => b.id).toSet();
        final mergedBookmarks = {...state.bookmarkedIds, ...bookmarkIds};

        state = state.copyWith(
          allSchedules: map.values.toList(),
          bookmarkedIds: mergedBookmarks,
        );
      }
    } catch (e) {
      debugPrint('Could not load schedules from database: $e');
    }
  }

  /// Updates active search query and triggers reactive filtering.
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates active category / filter chip (e.g., 'All', 'Hypertrophy', 'Strength').
  void updateCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }

  /// Updates active sorting option.
  void updateSort(SortOption sort) {
    state = state.copyWith(selectedSort: sort);
  }
}

/// Backward compatibility and convenient provider alias.
final schedulesNotifierProvider = schedulesProvider;

/// Provider that loads up to 5 workout schedules directly from SQLite database.
@riverpod
Future<List<WorkoutSchedule>> dbBrowseSchedules(Ref ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  try {
    final list = await scheduleRepo.getAllSchedules();
    if (list.isNotEmpty) {
      return list.take(5).map(WorkoutSchedule.fromSchedule).toList();
    }
  } catch (e) {
    debugPrint('Error fetching dbBrowseSchedules: $e');
  }
  final all = ref.watch(schedulesProvider).allSchedules;
  return all.take(5).toList();
}

/// Provider that loads Today's Routine Spotlight with top 3 exercises from DB.
@riverpod
Future<RoutineSpotlight> routineSpotlight(Ref ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);

  List<SpotlightDrill> drills = [];
  try {
    final scheduleExercises = await scheduleRepo.getScheduleExercises('sch1');
    if (scheduleExercises.isNotEmpty) {
      final top3 = scheduleExercises.take(3).toList();
      for (int i = 0; i < top3.length; i++) {
        final se = top3[i];
        final ex = await exerciseRepo.getExerciseById(se.exerciseId);
        final name = ex?.name ?? 'Exercise ${i + 1}';
        final prescription = '${se.targetSets} × ${se.targetReps} reps';
        drills.add(SpotlightDrill(
          stepNumber: i + 1,
          exerciseName: name,
          prescription: prescription,
        ));
      }
    }
  } catch (e) {
    debugPrint('Error loading spotlight drills from DB: $e');
  }

  if (drills.isEmpty) {
    drills = const [
      SpotlightDrill(
        stepNumber: 1,
        exerciseName: 'Russian Kettlebell Swings',
        prescription: '4 × 20 reps',
      ),
      SpotlightDrill(
        stepNumber: 2,
        exerciseName: 'Goblet Squats + Press',
        prescription: '4 × 12 reps',
      ),
      SpotlightDrill(
        stepNumber: 3,
        exerciseName: 'Alternating Snatch Burpees',
        prescription: '3 × 45 sec',
      ),
    ];
  }

  return RoutineSpotlight(
    id: 'spotlight_today',
    scheduleId: 'sch1',
    title: 'Kettlebell Power Flow',
    subtitle: 'Follow 3 explosive conditioning circuits',
    categoryTag: 'METABOLIC HIIT',
    dayNumber: 14,
    durationMinutes: 32,
    estimatedCalories: 460,
    intensityLevel: 4,
    drills: drills,
  );
}

/// Provider providing Trending Programs for the Workout Library carousel.
@riverpod
List<TrendingProgram> trendingPrograms(Ref ref) {
  final schedulesState = ref.watch(schedulesProvider);
  final bookmarkedIds = schedulesState.bookmarkedIds;

  return [
    TrendingProgram(
      id: 'trend_1',
      title: 'Posterior Chain & Pull Focus',
      description:
          'Engineered for structural density, hinge power, and progressive trap & lat hypertrophy.',
      categoryTag: 'HYPERTROPHY PRO',
      rating: 4.9,
      reviewCount: '1.4k',
      durationWeeks: 4,
      daysPerWeek: 4,
      equipment: 'Full Gym',
      tags: const ['Full Gym', 'Barbell', 'Deadlift Wave'],
      intensityLabel: 'High Intensity',
      isBookmarked: bookmarkedIds.contains('trend_1'),
    ),
    TrendingProgram(
      id: 'trend_2',
      title: 'Upper Body Power / Tension',
      description:
          'Explosive bench speed sets paired with heavy horizontal pulls and rotator cuff resilience.',
      categoryTag: 'STRENGTH PEAK',
      rating: 4.8,
      reviewCount: '980',
      durationWeeks: 6,
      daysPerWeek: 3,
      equipment: 'Full Gym',
      tags: const ['Full Gym', 'Barbell & Dumbbells', 'Power Cleans'],
      intensityLabel: 'Maximum Power',
      isBookmarked: bookmarkedIds.contains('trend_2'),
    ),
    TrendingProgram(
      id: 'trend_3',
      title: 'High Intensity Wave (HIW)',
      description:
          'Rapid neurological adaptation with descending rest periods and cluster set finishers.',
      categoryTag: 'AGILITY & SPEED',
      rating: 4.9,
      reviewCount: '2.1k',
      durationWeeks: 4,
      daysPerWeek: 5,
      equipment: 'Kettlebells & Bodyweight',
      tags: const ['Kettlebells', 'Plyo', 'Cardio Waves'],
      intensityLabel: 'Peak Conditioning',
      isBookmarked: bookmarkedIds.contains('trend_3'),
    ),
  ];
}

/// Provider providing user saved/custom routines for the "My Saved & Custom" section.
@riverpod
List<CustomWorkoutRoutine> customRoutines(Ref ref) {
  final schedulesState = ref.watch(schedulesProvider);
  final bookmarkedIds = schedulesState.bookmarkedIds;

  return [
    CustomWorkoutRoutine(
      id: 'custom_push_hypertrophy',
      title: 'Push Hypertrophy Custom',
      subtitle: '4 drills · 45 min · Chest & Shoulders',
      badgeText: 'ACTIVE',
      badgeColor: const Color(0xFF7C5CFA),
      progressPercent: 0.70,
      progressLabel: '70% done',
      drillCount: 4,
      durationMinutes: 45,
      muscleFocus: 'Chest & Shoulders',
      isBookmarked: bookmarkedIds.contains('custom_push_hypertrophy'),
    ),
    CustomWorkoutRoutine(
      id: 'custom_heavy_posterior',
      title: 'Heavy Posterior Overload',
      subtitle: '6 drills · 60 min · Hamstrings & Back',
      badgeText: 'SAVED',
      badgeColor: const Color(0xFF10B981),
      progressPercent: 0.33,
      progressLabel: 'Week 2/6',
      drillCount: 6,
      durationMinutes: 60,
      muscleFocus: 'Hamstrings & Back',
      isBookmarked: bookmarkedIds.contains('custom_heavy_posterior'),
    ),
  ];
}

