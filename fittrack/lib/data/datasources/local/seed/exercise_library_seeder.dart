import 'package:sqflite/sqflite.dart';

import 'exercise_seed_data.dart';

/// Writes the FitTrack exercise library into the database.
///
/// Each library exercise is stored with its full recorded detail — cover
/// image, YouTube guide, description, execution steps, form cues and muscle
/// activations — and every legacy alias id receives the same content so the
/// details resolve no matter which id a workout references.
///
/// User-created exercises and their child records are never touched.
class ExerciseLibrarySeeder {
  const ExerciseLibrarySeeder._();

  /// Seeds (or refreshes) the managed library exercises.
  static Future<void> seed(DatabaseExecutor executor) async {
    final aliasesByCanonical = <String, List<String>>{};
    for (final entry in kSeedExerciseAliases.entries) {
      aliasesByCanonical.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    for (final exercise in kSeedExercises) {
      final row = <String, Object?>{
        'id': exercise.id,
        'name': exercise.name,
        'equipment': exercise.equipment,
        'movementClassification': exercise.movementClassification,
        'mediaUrl': exercise.imageAsset,
        'youtubeUrl': exercise.youtubeUrl,
        'biomechanicsNotes': exercise.description,
        'isCustom': 0,
      };

      await _upsertExercise(executor, row);

      for (final alias in aliasesByCanonical[exercise.id] ?? const <String>[]) {
        await _upsertExercise(executor, {...row, 'id': alias});
      }
    }

    for (final exercise in kSeedExercises) {
      final ids = <String>[
        exercise.id,
        ...?aliasesByCanonical[exercise.id],
      ];

      for (final id in ids) {
        await _seedDetails(executor, id, exercise);
      }
    }
  }

  /// Updates the exercise row when it already exists, otherwise inserts it.
  ///
  /// An update is used instead of `ConflictAlgorithm.replace` so the row is
  /// never deleted and re-created, which would cascade into
  /// `schedule_exercises` if foreign keys are ever enabled.
  static Future<void> _upsertExercise(
    DatabaseExecutor executor,
    Map<String, Object?> row,
  ) async {
    final id = row['id'];
    final values = Map<String, Object?>.from(row)..remove('id');

    final updated = await executor.update(
      'exercises',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updated == 0) {
      await executor.insert('exercises', row);
    }
  }

  /// Replaces the steps, cues and muscle activations recorded for one
  /// exercise id.
  static Future<void> _seedDetails(
    DatabaseExecutor executor,
    String exerciseId,
    SeedExercise exercise,
  ) async {
    await executor.delete(
      'execution_steps',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    await executor.delete(
      'form_cues',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    await executor.delete(
      'muscle_activations',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );

    for (var i = 0; i < exercise.steps.length; i++) {
      final step = exercise.steps[i];
      await executor.insert('execution_steps', {
        'id': 'seed_${exerciseId}_step_${i + 1}',
        'exerciseId': exerciseId,
        'stepNumber': i + 1,
        'title': step.title,
        'instructions': step.instructions,
      });
    }

    for (var i = 0; i < exercise.cues.length; i++) {
      final cue = exercise.cues[i];
      await executor.insert('form_cues', {
        'id': 'seed_${exerciseId}_cue_${i + 1}',
        'exerciseId': exerciseId,
        'isPositive': cue.isPositive ? 1 : 0,
        'description': cue.description,
      });
    }

    for (var i = 0; i < exercise.muscles.length; i++) {
      final muscle = exercise.muscles[i];
      await executor.insert('muscle_activations', {
        'id': 'seed_${exerciseId}_muscle_${i + 1}',
        'exerciseId': exerciseId,
        'muscleName': muscle.name,
        'role': muscle.role,
        'intensityPercentage': muscle.percentage,
      });
    }
  }
}
