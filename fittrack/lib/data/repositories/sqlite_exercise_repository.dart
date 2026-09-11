import 'package:sqflite/sqflite.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_activation.dart';
import '../../domain/entities/execution_step.dart';
import '../../domain/entities/form_cue.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../datasources/local/database_helper.dart';

class SqliteExerciseRepository implements IExerciseRepository {
  final DatabaseHelper _dbHelper;

  SqliteExerciseRepository(this._dbHelper);

  @override
  Future<List<Exercise>> getAllExercises() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return maps.map(_mapToExercise).toList();
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToExercise(maps.first);
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(
    String exerciseId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'muscle_activations',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) => MuscleActivation.fromJson(map)).toList();
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'execution_steps',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) => ExecutionStep.fromJson(map)).toList();
  }

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'form_cues',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return maps.map((map) {
      final modMap = Map<String, dynamic>.from(map);
      modMap['isPositive'] = modMap['isPositive'] == 1;
      return FormCue.fromJson(modMap);
    }).toList();
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    final db = await _dbHelper.database;
    await db.insert(
      'exercises',
      {
        'id': exercise.id,
        'name': exercise.name,
        'equipment': exercise.equipment.name,
        'movementClassification': exercise.movementClassification.name,
        'mediaUrl': exercise.mediaUrl,
        'youtubeUrl': exercise.youtubeUrl,
        'biomechanicsNotes': exercise.biomechanicsNotes,
        'isCustom': exercise.isCustom ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveMuscleActivations(
    String exerciseId,
    List<MuscleActivation> activations,
  ) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'muscle_activations',
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
      );
      for (final a in activations) {
        await txn.insert(
          'muscle_activations',
          a.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> saveExecutionSteps(
    String exerciseId,
    List<ExecutionStep> steps,
  ) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'execution_steps',
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
      );
      for (final s in steps) {
        await txn.insert(
          'execution_steps',
          s.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> saveFormCues(String exerciseId, List<FormCue> cues) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'form_cues',
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
      );
      for (final c in cues) {
        await txn.insert(
          'form_cues',
          {
            'id': c.id,
            'exerciseId': c.exerciseId,
            'isPositive': c.isPositive ? 1 : 0,
            'description': c.description,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Exercise _mapToExercise(Map<String, dynamic> map) {
    final modMap = Map<String, dynamic>.from(map);
    modMap['isCustom'] = modMap['isCustom'] == 1;
    return Exercise.fromJson(modMap);
  }
}
