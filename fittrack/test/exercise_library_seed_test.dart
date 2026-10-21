import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fittrack/data/datasources/local/seed/exercise_library_seeder.dart';
import 'package:fittrack/data/datasources/local/seed/exercise_seed_data.dart';

/// Creates the exercise tables used by the seeder, mirroring the schema in
/// `DatabaseHelper._onCreate`.
Future<Database> _openLibraryDb() async {
  sqfliteFfiInit();

  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS exercises (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            equipment TEXT NOT NULL,
            movementClassification TEXT NOT NULL,
            mediaUrl TEXT,
            youtubeUrl TEXT,
            biomechanicsNotes TEXT,
            isCustom INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS muscle_activations (
            id TEXT PRIMARY KEY,
            exerciseId TEXT NOT NULL,
            muscleName TEXT NOT NULL,
            role TEXT NOT NULL,
            intensityPercentage INTEGER NOT NULL,
            FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS execution_steps (
            id TEXT PRIMARY KEY,
            exerciseId TEXT NOT NULL,
            stepNumber INTEGER NOT NULL,
            title TEXT NOT NULL,
            instructions TEXT NOT NULL,
            FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS form_cues (
            id TEXT PRIMARY KEY,
            exerciseId TEXT NOT NULL,
            isPositive INTEGER NOT NULL,
            description TEXT NOT NULL,
            FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
          )
        ''');
      },
    ),
  );

  return db;
}

void main() {
  group('Exercise library seed content', () {
    test('every library exercise is fully populated', () {
      for (final exercise in kSeedExercises) {
        expect(
          exercise.name.trim(),
          isNotEmpty,
          reason: '${exercise.id} needs a name',
        );
        expect(
          exercise.description.trim().length,
          greaterThan(40),
          reason: '${exercise.id} needs a real description',
        );
        expect(
          exercise.youtubeUrl,
          startsWith('https://www.youtube.com/'),
          reason: '${exercise.id} needs a YouTube guide',
        );
        expect(
          exercise.imageAsset,
          startsWith('assets/images/'),
          reason: '${exercise.id} needs a bundled cover image',
        );
        expect(
          exercise.steps.length,
          inInclusiveRange(1, 3),
          reason: '${exercise.id} needs between 1 and 3 execution steps',
        );
        expect(
          exercise.cues.length,
          inInclusiveRange(1, 3),
          reason: '${exercise.id} needs between 1 and 3 form cues',
        );
        expect(
          exercise.muscles.length,
          inInclusiveRange(1, 3),
          reason: '${exercise.id} needs between 1 and 3 muscle activations',
        );

        for (final step in exercise.steps) {
          expect(step.title.trim(), isNotEmpty);
          expect(
            step.instructions.trim().length,
            greaterThan(30),
            reason: '${exercise.id} step "${step.title}" needs real instructions',
          );
        }

        for (final cue in exercise.cues) {
          expect(cue.description.trim().length, greaterThan(20));
        }

        for (final muscle in exercise.muscles) {
          expect(muscle.name.trim(), isNotEmpty);
          expect(
            muscle.role,
            anyOf('agonist', 'synergist', 'stabilizer'),
            reason: '${exercise.id} has an unknown muscle role',
          );
          expect(muscle.percentage, inInclusiveRange(1, 100));
        }
      }
    });

    test('every alias points at a known exercise', () {
      final knownIds = kSeedExercises.map((e) => e.id).toSet();
      for (final entry in kSeedExerciseAliases.entries) {
        expect(
          knownIds,
          contains(entry.value),
          reason: 'alias ${entry.key} points at an unknown exercise',
        );
      }
    });

    test('the library covers the 25 canonical exercises', () {
      expect(kSeedExercises.length, 25);
      expect(
        kSeedExercises.map((e) => e.id).toSet().length,
        25,
        reason: 'exercise ids must be unique',
      );
    });
  });

  group('ExerciseLibrarySeeder', () {
    late Database db;

    setUp(() async {
      db = await _openLibraryDb();
    });

    tearDown(() async {
      await db.close();
    });

    test('writes every exercise with its full detail', () async {
      await ExerciseLibrarySeeder.seed(db);

      for (final exercise in kSeedExercises) {
        final rows = await db.query(
          'exercises',
          where: 'id = ?',
          whereArgs: [exercise.id],
        );
        expect(rows, hasLength(1), reason: '${exercise.id} was not seeded');

        final row = rows.first;
        expect(row['name'], exercise.name);
        expect(row['equipment'], exercise.equipment);
        expect(row['movementClassification'], exercise.movementClassification);
        expect(row['mediaUrl'], exercise.imageAsset);
        expect(row['youtubeUrl'], exercise.youtubeUrl);
        expect(row['biomechanicsNotes'], exercise.description);
        expect(row['isCustom'], 0);

        final steps = await db.query(
          'execution_steps',
          where: 'exerciseId = ?',
          whereArgs: [exercise.id],
          orderBy: 'stepNumber',
        );
        expect(steps, hasLength(exercise.steps.length));
        expect(steps.first['stepNumber'], 1);
        expect(steps.first['title'], exercise.steps.first.title);
        expect(
          steps.first['instructions'],
          exercise.steps.first.instructions,
        );

        final cues = await db.query(
          'form_cues',
          where: 'exerciseId = ?',
          whereArgs: [exercise.id],
        );
        expect(cues, hasLength(exercise.cues.length));
        expect(
          cues.map((c) => c['isPositive']),
          containsAll([0, 1]),
          reason: '${exercise.id} should mix do and don\'t cues',
        );

        final muscles = await db.query(
          'muscle_activations',
          where: 'exerciseId = ?',
          whereArgs: [exercise.id],
        );
        expect(muscles, hasLength(exercise.muscles.length));
        expect(
          muscles.map((m) => m['role']),
          containsAll(['agonist', 'synergist', 'stabilizer']),
        );
        for (final muscle in muscles) {
          expect(muscle['intensityPercentage'], isA<int>());
          expect(muscle['intensityPercentage'], inInclusiveRange(1, 100));
        }
      }
    });

    test('aliases receive the same detail as their canonical exercise', () async {
      await ExerciseLibrarySeeder.seed(db);

      for (final entry in kSeedExerciseAliases.entries) {
        final alias = await db.query(
          'exercises',
          where: 'id = ?',
          whereArgs: [entry.key],
        );
        expect(alias, hasLength(1), reason: '${entry.key} was not seeded');

        final canonicalId = entry.value;
        final canonical = await db.query(
          'exercises',
          where: 'id = ?',
          whereArgs: [canonicalId],
        );

        expect(alias.first['name'], canonical.first['name']);
        expect(alias.first['biomechanicsNotes'], canonical.first['biomechanicsNotes']);
        expect(alias.first['youtubeUrl'], canonical.first['youtubeUrl']);

        final aliasSteps = await db.query(
          'execution_steps',
          where: 'exerciseId = ?',
          whereArgs: [entry.key],
        );
        final canonicalSteps = await db.query(
          'execution_steps',
          where: 'exerciseId = ?',
          whereArgs: [canonicalId],
        );
        expect(aliasSteps, hasLength(canonicalSteps.length));
        expect(aliasSteps.first['title'], canonicalSteps.first['title']);
      }
    });

    test('re-seeding does not duplicate child records', () async {
      await ExerciseLibrarySeeder.seed(db);
      await ExerciseLibrarySeeder.seed(db);

      final steps = await db.query('execution_steps');
      final cues = await db.query('form_cues');
      final muscles = await db.query('muscle_activations');

      final expectedIds = <String>{
        for (final exercise in kSeedExercises) exercise.id,
        ...kSeedExerciseAliases.keys,
      };

      expect(
        steps.length,
        expectedIds.length * kSeedExercises.first.steps.length,
      );
      expect(cues.length, expectedIds.length * kSeedExercises.first.cues.length);
      expect(
        muscles.length,
        expectedIds.length * kSeedExercises.first.muscles.length,
      );
    });

    test('user-created exercises and their details are left untouched', () async {
      await db.insert('exercises', {
        'id': 'custom-uuid',
        'name': 'My Custom Exercise',
        'equipment': 'dumbbell',
        'movementClassification': 'compound',
        'mediaUrl': '/local/path.jpg',
        'youtubeUrl': null,
        'biomechanicsNotes': 'My own notes',
        'isCustom': 1,
      });
      await db.insert('execution_steps', {
        'id': 'custom-step',
        'exerciseId': 'custom-uuid',
        'stepNumber': 1,
        'title': 'My Step',
        'instructions': 'My own instructions for the custom exercise.',
      });

      await ExerciseLibrarySeeder.seed(db);

      final custom = await db.query(
        'exercises',
        where: 'id = ?',
        whereArgs: ['custom-uuid'],
      );
      expect(custom, hasLength(1));
      expect(custom.first['name'], 'My Custom Exercise');
      expect(custom.first['mediaUrl'], '/local/path.jpg');
      expect(custom.first['isCustom'], 1);

      final customSteps = await db.query(
        'execution_steps',
        where: 'exerciseId = ?',
        whereArgs: ['custom-uuid'],
      );
      expect(customSteps, hasLength(1));
      expect(customSteps.first['title'], 'My Step');
    });

    test('upgrading an existing install enriches rows without losing schedules',
        () async {
      // Rows as written by the previous (v14) seed: no media, no video, no
      // description.
      await db.insert('exercises', {
        'id': 'ex1',
        'name': 'BB Bench Press',
        'equipment': 'barbell',
        'movementClassification': 'compound',
        'mediaUrl': null,
        'youtubeUrl': null,
        'biomechanicsNotes': null,
        'isCustom': 0,
      });
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedules (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedule_exercises (
          id TEXT PRIMARY KEY,
          scheduleId TEXT NOT NULL,
          exerciseId TEXT NOT NULL,
          FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');
      await db.insert('schedules', {'id': 'sch1', 'name': 'Push Day'});
      await db.insert('schedule_exercises', {
        'id': 'se_sch1_1',
        'scheduleId': 'sch1',
        'exerciseId': 'ex1',
      });

      await ExerciseLibrarySeeder.seed(db);

      // The existing row is enriched in place, not duplicated.
      final rows = await db.query(
        'exercises',
        where: 'id = ?',
        whereArgs: ['ex1'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['name'], 'Barbell Bench Press');
      expect(rows.first['mediaUrl'], isNotNull);
      expect(rows.first['youtubeUrl'], isNotNull);
      expect(rows.first['biomechanicsNotes'], isNotNull);

      // The schedule that references the exercise is untouched.
      final scheduleExercises = await db.query('schedule_exercises');
      expect(scheduleExercises, hasLength(1));
      expect(scheduleExercises.first['exerciseId'], 'ex1');
    });
  });
}
