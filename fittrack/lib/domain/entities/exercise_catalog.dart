import 'exercise.dart';

/// Specification record for an exercise in the FitTrack canonical library.
class ExerciseSpec {
  const ExerciseSpec({
    required this.canonicalId,
    required this.name,
    required this.aliases,
    required this.primaryMuscle,
    required this.equipment,
    required this.movementClassification,
    required this.imageAsset,
  });

  final String canonicalId;
  final String name;
  final List<String> aliases;
  final String primaryMuscle;
  final Equipment equipment;
  final MovementClassification movementClassification;
  final String imageAsset;

  Exercise toEntity() {
    return Exercise(
      id: canonicalId,
      name: name,
      equipment: equipment,
      movementClassification: movementClassification,
      mediaUrl: imageAsset,
      isCustom: false,
    );
  }
}

/// Central repository & resolver of canonical exercises, aliases, and display metadata.
/// Eliminates raw ID fallbacks (ex11, ex12, ex20) and harmonizes IDs across SQLite,
/// Riverpod providers, and presentation screens.
class ExerciseCatalog {
  ExerciseCatalog._();

  static const List<ExerciseSpec> specs = [
    ExerciseSpec(
      canonicalId: 'ex1',
      name: 'BB Bench Press',
      aliases: ['ex_barbell_bench_press', 'e1'],
      primaryMuscle: 'Chest',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex2',
      name: 'Incline DB Press',
      aliases: ['ex_incline_dumbbell_press', 'ex_incline_barbell_press', 'e2'],
      primaryMuscle: 'Shoulders',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex3',
      name: 'Cable Chest Flyes',
      aliases: ['ex_cable_chest_flyes', 'ex_cable_flyes'],
      primaryMuscle: 'Chest',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex4',
      name: 'Standing Overhead Press',
      aliases: ['ex_standing_overhead_press', 'ex_overhead_press'],
      primaryMuscle: 'Shoulders',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex5',
      name: 'Cable Lateral Raise',
      aliases: ['ex_cable_lateral_raise', 'ex_lateral_raises'],
      primaryMuscle: 'Shoulders',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex6',
      name: 'Tricep Pushdowns',
      aliases: ['ex_tricep_pushdowns', 'ex_weighted_chest_dips'],
      primaryMuscle: 'Triceps',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex7',
      name: 'Overhead Tricep Extension',
      aliases: ['ex_overhead_triceps_extension'],
      primaryMuscle: 'Triceps',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex8',
      name: 'Barbell Squat',
      aliases: ['ex_barbell_squat', 'ex_barbell_back_squat'],
      primaryMuscle: 'Legs',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex9',
      name: 'Bent-Over Row',
      aliases: ['ex_bent_over_row', 'ex_bent_over_barbell_row'],
      primaryMuscle: 'Back',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex10',
      name: 'Deadlift',
      aliases: ['ex_conventional_deadlift', 'ex_deadlift'],
      primaryMuscle: 'Back',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex11',
      name: 'Romanian Deadlift',
      aliases: ['ex_romanian_deadlift'],
      primaryMuscle: 'Hamstrings',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex12',
      name: 'Wide-Grip Lat Pulldown',
      aliases: ['ex_lat_pulldown', 'ex_wide_grip_lat_pulldown'],
      primaryMuscle: 'Back',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex13',
      name: 'Pull-Ups',
      aliases: ['ex_pull_ups', 'ex_weighted_pull_ups'],
      primaryMuscle: 'Back',
      equipment: Equipment.bodyweight,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex14',
      name: 'Dumbbell Bicep Curl',
      aliases: ['ex_dumbbell_bicep_curl'],
      primaryMuscle: 'Arms',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex15',
      name: 'Hammer Curl',
      aliases: ['ex_hammer_curl'],
      primaryMuscle: 'Arms',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex16',
      name: 'Bulgarian Split Squat',
      aliases: ['ex_bulgarian_split_squat'],
      primaryMuscle: 'Legs',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex17',
      name: 'Seated Leg Curl',
      aliases: ['ex_seated_leg_curl'],
      primaryMuscle: 'Legs',
      equipment: Equipment.machine,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex18',
      name: 'Leg Extension',
      aliases: ['ex_leg_extension'],
      primaryMuscle: 'Legs',
      equipment: Equipment.machine,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex19',
      name: 'Standing Calf Raise',
      aliases: ['ex_standing_calf_raise'],
      primaryMuscle: 'Legs',
      equipment: Equipment.machine,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex20',
      name: 'Cable Face Pull',
      aliases: ['ex_face_pull', 'ex_cable_face_pull'],
      primaryMuscle: 'Back',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex21',
      name: 'Hanging Leg Raise',
      aliases: ['ex_hanging_leg_raise'],
      primaryMuscle: 'Core',
      equipment: Equipment.bodyweight,
      movementClassification: MovementClassification.isolation,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex22',
      name: 'Russian Kettlebell Swing',
      aliases: ['ex_kettlebell_swing', 'ex_russian_kettlebell_swing'],
      primaryMuscle: 'Full Body',
      equipment: Equipment.other,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/coaching_bench.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex23',
      name: 'Goblet Squats + Press',
      aliases: ['ex_goblet_squat'],
      primaryMuscle: 'Legs',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex24',
      name: 'Alternating Snatch Burpee',
      aliases: ['ex_snatch_burpee'],
      primaryMuscle: 'Full Body',
      equipment: Equipment.other,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
    ExerciseSpec(
      canonicalId: 'ex25',
      name: 'Dumbbell Chest Press',
      aliases: ['ex_dumbbell_chest_press'],
      primaryMuscle: 'Chest',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.compound,
      imageAsset: 'assets/images/dashboard/hero_workout.webp',
    ),
  ];

  static final Map<String, ExerciseSpec> _byCanonicalId = {
    for (final s in specs) s.canonicalId.toLowerCase(): s,
  };

  static final Map<String, ExerciseSpec> _byAlias = {
    for (final s in specs) ...{
      for (final a in s.aliases) a.toLowerCase(): s,
    },
  };

  /// Returns canonical exercise spec if recognized by ID or alias.
  static ExerciseSpec? findSpec(String idOrAlias) {
    final lower = idOrAlias.toLowerCase().trim();
    return _byCanonicalId[lower] ?? _byAlias[lower];
  }

  /// Converts any alias or ID to its canonical ID (e.g. 'ex_conventional_deadlift' -> 'ex10').
  static String? toCanonicalId(String idOrAlias) {
    return findSpec(idOrAlias)?.canonicalId;
  }

  /// Returns primary alias string for an ID (e.g. 'ex10' -> 'ex_conventional_deadlift').
  static String? toAliasId(String idOrAlias) {
    final spec = findSpec(idOrAlias);
    if (spec == null) return null;
    return spec.aliases.isNotEmpty ? spec.aliases.first : spec.canonicalId;
  }

  /// Returns a clean, human-readable name for any exercise ID or alias.
  static String resolveName(String exerciseId, {String? fallbackName}) {
    if (fallbackName != null &&
        fallbackName.trim().isNotEmpty &&
        !_isRawId(fallbackName)) {
      return fallbackName.trim();
    }
    final spec = findSpec(exerciseId);
    if (spec != null) return spec.name;

    if (exerciseId.startsWith('ex_')) {
      final raw = exerciseId.substring(3).replaceAll('_', ' ');
      return raw.split(' ').map((w) {
        if (w.isEmpty) return '';
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');
    }
    return exerciseId;
  }

  static bool _isRawId(String str) {
    final s = str.trim().toLowerCase();
    final regex = RegExp(r'^e(x)?[0-9]+$');
    return regex.hasMatch(s);
  }

  /// Returns primary muscle group for any exercise ID or name.
  static String resolveMuscle(String exerciseId, {String? exerciseName, String? fallbackMuscle}) {
    if (fallbackMuscle != null && fallbackMuscle.trim().isNotEmpty) {
      return fallbackMuscle.trim();
    }
    final spec = findSpec(exerciseId);
    if (spec != null) return spec.primaryMuscle;

    final lower = '${exerciseId}_${exerciseName ?? ''}'.toLowerCase();
    if (lower.contains('bench') || lower.contains('chest') || lower.contains('fly')) {
      return 'Chest';
    }
    if (lower.contains('overhead') ||
        lower.contains('press') ||
        lower.contains('lateral') ||
        lower.contains('shoulder')) {
      return 'Shoulders';
    }
    if (lower.contains('tricep') || lower.contains('pushdown') || lower.contains('extension')) {
      return 'Triceps';
    }
    if (lower.contains('pull') || lower.contains('row') || lower.contains('lat') || lower.contains('back')) {
      return 'Back';
    }
    if (lower.contains('deadlift')) {
      if (lower.contains('romanian')) return 'Hamstrings';
      return 'Back';
    }
    if (lower.contains('squat') ||
        lower.contains('leg') ||
        lower.contains('hamstring') ||
        lower.contains('quad') ||
        lower.contains('calf')) {
      return 'Legs';
    }
    if (lower.contains('curl') || lower.contains('bicep') || lower.contains('arm')) {
      return 'Arms';
    }
    if (lower.contains('crunch') || lower.contains('plank') || lower.contains('core') || lower.contains('ab')) {
      return 'Core';
    }
    return 'Full Body';
  }

  /// Returns appropriate thumbnail asset path for any exercise ID.
  static String resolveImage(String exerciseId) {
    final spec = findSpec(exerciseId);
    if (spec != null) return spec.imageAsset;

    final muscle = resolveMuscle(exerciseId);
    if (muscle == 'Chest' || muscle == 'Back' || muscle == 'Legs' || muscle == 'Hamstrings') {
      return 'assets/images/dashboard/hero_workout.webp';
    }
    return 'assets/images/dashboard/coaching_bench.webp';
  }

  /// Checks if two IDs or names refer to the same logical exercise.
  static bool isSameExercise(String id1, String id2, {String? name1, String? name2}) {
    if (id1.toLowerCase().trim() == id2.toLowerCase().trim()) return true;
    final c1 = toCanonicalId(id1);
    final c2 = toCanonicalId(id2);
    if (c1 != null && c2 != null && c1 == c2) return true;

    final n1 = (name1 ?? resolveName(id1)).trim().toLowerCase();
    final n2 = (name2 ?? resolveName(id2)).trim().toLowerCase();
    if (n1.isNotEmpty && n2.isNotEmpty) {
      if (n1 == n2) return true;
      if (n1.contains('deadlift') && n2.contains('deadlift')) {
        final r1 = n1.contains('romanian');
        final r2 = n2.contains('romanian');
        return r1 == r2;
      }
    }
    return false;
  }

  /// Returns full Exercise domain entity for an ID.
  static Exercise? getCanonicalExercise(String idOrAlias) {
    return findSpec(idOrAlias)?.toEntity();
  }

  /// Returns all 25 canonical exercise entities without duplicates.
  static List<Exercise> get allCanonicalExercises {
    return specs.map((s) => s.toEntity()).toList();
  }
}
