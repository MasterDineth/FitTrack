import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/workout_schedule.dart';

export '../../domain/entities/schedule_exercise.dart';
export '../../domain/entities/workout_schedule.dart';

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
  });

  final List<WorkoutSchedule> allSchedules;
  final String searchQuery;
  final String selectedCategoryFilter;
  final SortOption selectedSort;

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
      allSchedules.where((s) => s.isFavorite).toList();

  /// Returns user-created custom schedules.
  List<WorkoutSchedule> get customSchedules =>
      allSchedules.where((s) => s.isCustom).toList();

  /// Returns schedules filtered by both the selected category chip and search query,
  /// sorted according to [selectedSort].
  List<WorkoutSchedule> get filteredSchedules {
    final list = allSchedules.where((schedule) {
      // 1. Category / Filter Chip matching
      if (selectedCategoryFilter != 'All') {
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
  }) {
    return SchedulesState(
      allSchedules: allSchedules ?? this.allSchedules,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedSort: selectedSort ?? this.selectedSort,
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
          selectedSort == other.selectedSort;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(allSchedules),
        searchQuery,
        selectedCategoryFilter,
        selectedSort,
      );
}

/// Initial robust mock seed data covering Hypertrophy, Strength, Custom, and Bookmarks,
/// equipped with complete deep exercises and routine breakdowns.
const _initialSeedSchedules = <WorkoutSchedule>[
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
    );
  }

  /// Convenience getters mirroring state
  List<WorkoutSchedule> get recommendedSchedules => state.recommendedSchedules;
  List<WorkoutSchedule> get bookmarkedSchedules => state.bookmarkedSchedules;
  List<WorkoutSchedule> get customSchedules => state.customSchedules;
  List<WorkoutSchedule> get filteredSchedules => state.filteredSchedules;

  /// Toggles favorite/bookmark status for a given schedule [id].
  void toggleBookmark(String id) {
    state = state.copyWith(
      allSchedules: state.allSchedules.map((schedule) {
        if (schedule.id == id) {
          return schedule.copyWith(isFavorite: !schedule.isFavorite);
        }
        return schedule;
      }).toList(),
    );
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
