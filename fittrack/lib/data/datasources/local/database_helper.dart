import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "FitTrack.db";
  static const _databaseVersion = 14;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static Completer<Database>? _initCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;

    final completer = Completer<Database>();
    _initCompleter = completer;
    try {
      final db = await _initDatabase();
      _database = db;
      completer.complete(db);
      return db;
    } catch (e, st) {
      _initCompleter = null;
      completer.completeError(e, st);
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user_profile (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER,
            weightKg REAL,
            heightCm REAL,
            experienceLevel TEXT,
            primaryGoal TEXT,
            weeklyTargetDays INTEGER,
            profileImagePath TEXT
          )
        ''');
      } on DatabaseException catch (_) {
        // Table may already exist
      } catch (_) {}
    }

    if (oldVersion < 6) {
      final columns = [
        'ALTER TABLE user_profile ADD COLUMN address TEXT',
        'ALTER TABLE user_profile ADD COLUMN phone TEXT',
        'ALTER TABLE user_profile ADD COLUMN isPhoneVerified INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE user_profile ADD COLUMN dob TEXT',
        'ALTER TABLE user_profile ADD COLUMN email TEXT',
        'ALTER TABLE user_profile ADD COLUMN username TEXT',
      ];

      for (final sql in columns) {
        try {
          await db.execute(sql);
        } on DatabaseException catch (_) {
          // Column may already exist; catch DatabaseException to prevent app launch crash
        } catch (_) {}
      }
    }

    if (oldVersion < 7) {
      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(startTime)',
        );
      } on DatabaseException catch (_) {}
    }

    if (oldVersion < 9) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_habits (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            orderIndex INTEGER NOT NULL
          )
        ''');
        await db.insert('daily_habits', {
          'id': 'habit-1',
          'title': 'Morning Hydration (1L)',
          'subtitle': 'Completed at 7:45 AM',
          'isCompleted': 1,
          'status': 'done',
          'orderIndex': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('daily_habits', {
          'id': 'habit-2',
          'title': 'Target Protein Synthesis',
          'subtitle': '35g remaining for dinner',
          'isCompleted': 0,
          'status': 'pending',
          'orderIndex': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('daily_habits', {
          'id': 'habit-3',
          'title': 'Sleep Protocol (8h target)',
          'subtitle': 'Wind-down routine at 10:30 PM',
          'isCompleted': 0,
          'status': 'tonight',
          'orderIndex': 2,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } on DatabaseException catch (_) {}
    }

    if (oldVersion < 10) {
      try {
        final existingCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM workout_sessions'),
        ) ?? 0;
        if (existingCount == 0) {
          final now = DateTime.now();
          final s1Time = now.subtract(const Duration(days: 1, hours: 2));
          final s2Time = now.subtract(const Duration(days: 3, hours: 4));
          final s3Time = now.subtract(const Duration(days: 5, hours: 1));

          await db.insert('workout_sessions', {
            'id': 'sess-1',
            'scheduleId': 'sch1',
            'startTime': s1Time.toIso8601String(),
            'endTime': s1Time.add(const Duration(minutes: 52)).toIso8601String(),
            'durationSeconds': 3120,
            'totalCalories': 420,
            'notes': 'Push Hypertrophy',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('workout_sessions', {
            'id': 'sess-2',
            'scheduleId': 'sch2',
            'startTime': s2Time.toIso8601String(),
            'endTime': s2Time.add(const Duration(minutes: 44)).toIso8601String(),
            'durationSeconds': 2640,
            'totalCalories': 365,
            'notes': 'Pull & Dynamic Core',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('workout_sessions', {
            'id': 'sess-3',
            'scheduleId': 'sch3',
            'startTime': s3Time.toIso8601String(),
            'endTime': s3Time.add(const Duration(minutes: 55)).toIso8601String(),
            'durationSeconds': 3300,
            'totalCalories': 480,
            'notes': 'Legs & Posterior Chain',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      } on DatabaseException catch (_) {} catch (_) {}
    }

    if (oldVersion < 11) {
      final scheduleColumns = [
        'ALTER TABLE schedules ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE schedules ADD COLUMN focus TEXT NOT NULL DEFAULT "Hypertrophy"',
        'ALTER TABLE schedules ADD COLUMN experience TEXT NOT NULL DEFAULT "Intermediate"',
        'ALTER TABLE schedules ADD COLUMN equipment TEXT NOT NULL DEFAULT "Full Gym"',
        'ALTER TABLE schedules ADD COLUMN durationWeeks INTEGER NOT NULL DEFAULT 8',
        'ALTER TABLE schedules ADD COLUMN daysPerWeek INTEGER NOT NULL DEFAULT 4',
        'ALTER TABLE schedules ADD COLUMN estimatedMinutes INTEGER NOT NULL DEFAULT 45',
        'ALTER TABLE schedules ADD COLUMN isCustom INTEGER NOT NULL DEFAULT 0',
      ];

      for (final sql in scheduleColumns) {
        try {
          await db.execute(sql);
        } on DatabaseException catch (_) {} catch (_) {}
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookmarked_items (
            id TEXT PRIMARY KEY,
            createdAt TEXT NOT NULL
          )
        ''');
      } on DatabaseException catch (_) {} catch (_) {}

      try {
        await db.update('schedules', {
          'isFavorite': 1,
          'focus': 'Hypertrophy',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 8,
          'daysPerWeek': 4,
          'estimatedMinutes': 50,
        }, where: 'id = ?', whereArgs: ['sch1']);

        await db.update('schedules', {
          'isFavorite': 0,
          'focus': 'Strength',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 6,
          'daysPerWeek': 3,
          'estimatedMinutes': 55,
        }, where: 'id = ?', whereArgs: ['sch2']);

        await db.update('schedules', {
          'isFavorite': 1,
          'focus': 'Hypertrophy',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 10,
          'daysPerWeek': 6,
          'estimatedMinutes': 60,
        }, where: 'id = ?', whereArgs: ['sch3']);

        await db.insert('schedules', {
          'id': 'sch4',
          'name': 'German Volume Training (GVT)',
          'description': '10×10 volume protocol for high neuromuscular exhaustion and extreme hypertrophy adaptation.',
          'targetMuscles': '["Chest", "Quads", "Back"]',
          'assignedWeekdays': '[1, 2, 4, 5]',
          'orderIndex': 4,
          'isArchived': 0,
          'isFavorite': 0,
          'focus': 'Advanced',
          'experience': 'Advanced',
          'equipment': 'Full Gym',
          'durationWeeks': 6,
          'daysPerWeek': 4,
          'estimatedMinutes': 40,
          'isCustom': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedules', {
          'id': 'sch5',
          'name': 'Torso & Limb Split',
          'description': 'Separates chest/back days from arm and quad isolation for maximum recovery and tendon longevity.',
          'targetMuscles': '["Torso", "Arms", "Quads", "Hamstrings"]',
          'assignedWeekdays': '[1, 2, 4, 5]',
          'orderIndex': 5,
          'isArchived': 0,
          'isFavorite': 0,
          'focus': 'Intermediate',
          'experience': 'Intermediate',
          'equipment': 'Barbell & Cable',
          'durationWeeks': 8,
          'daysPerWeek': 4,
          'estimatedMinutes': 45,
          'isCustom': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedule_exercises', {
          'id': 'se_sch4_1', 'scheduleId': 'sch4', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 60.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch4_2', 'scheduleId': 'sch4', 'exerciseId': 'ex8', 'sortOrder': 2, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 80.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch4_3', 'scheduleId': 'sch4', 'exerciseId': 'ex9', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 50.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await db.insert('schedule_exercises', {
          'id': 'se_sch5_1', 'scheduleId': 'sch5', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch5_2', 'scheduleId': 'sch5', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await db.insert('schedule_exercises', {
          'id': 'se_sch5_3', 'scheduleId': 'sch5', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (_) {}
    }

    if (oldVersion < 12) {
      final sessionCols = [
        'ALTER TABLE workout_sessions ADD COLUMN intensity TEXT',
        'ALTER TABLE workout_sessions ADD COLUMN totalSets INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE workout_sessions ADD COLUMN totalReps INTEGER NOT NULL DEFAULT 0',
        'ALTER TABLE workout_sessions ADD COLUMN totalVolumeKg REAL NOT NULL DEFAULT 0',
      ];

      for (final sql in sessionCols) {
        try {
          await db.execute(sql);
        } on DatabaseException catch (_) {} catch (_) {}
      }

      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_exercise_logs_session_id ON exercise_logs(sessionId)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_set_logs_exercise_log_id ON set_logs(exerciseLogId)',
        );
      } on DatabaseException catch (_) {} catch (_) {}

      try {
        await _seedVersion12Data(db);
      } catch (_) {}
    }

    if (oldVersion < 13) {
      try {
        try {
          await db.execute('ALTER TABLE schedules ADD COLUMN completionCount INTEGER NOT NULL DEFAULT 0');
        } on DatabaseException catch (_) {}

        // Drop existing schedules and exercises and repopulate with complete, compatible records
        await db.delete('schedule_exercises');
        await db.delete('schedules');
        await db.delete('exercises');

        await _seedVersion13Data(db);
      } catch (_) {}
    }

    if (oldVersion < 14) {
      try {
        // Drop existing schedules and exercises and repopulate with complete, compatible records
        await db.delete('schedule_exercises');
        await db.delete('schedules');
        await db.delete('exercises');

        await _seedVersion13Data(db);
      } catch (_) {}
    }
  }

  Future _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        targetMuscles TEXT NOT NULL,
        assignedWeekdays TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        focus TEXT NOT NULL DEFAULT 'Hypertrophy',
        experience TEXT NOT NULL DEFAULT 'Intermediate',
        equipment TEXT NOT NULL DEFAULT 'Full Gym',
        durationWeeks INTEGER NOT NULL DEFAULT 8,
        daysPerWeek INTEGER NOT NULL DEFAULT 4,
        estimatedMinutes INTEGER NOT NULL DEFAULT 45,
        isCustom INTEGER NOT NULL DEFAULT 0,
        completionCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarked_items (
        id TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_exercises (
        id TEXT PRIMARY KEY,
        scheduleId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        sortOrder INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        targetWeightKg REAL NOT NULL,
        restDurationSeconds INTEGER NOT NULL,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_sessions (
        id TEXT PRIMARY KEY,
        scheduleId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER,
        totalCalories INTEGER,
        notes TEXT,
        intensity TEXT,
        totalSets INTEGER NOT NULL DEFAULT 0,
        totalReps INTEGER NOT NULL DEFAULT 0,
        totalVolumeKg REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(startTime)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS exercise_logs (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        isSkipped INTEGER NOT NULL DEFAULT 0,
        skip_reason TEXT,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS set_logs (
        id TEXT PRIMARY KEY,
        exerciseLogId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        actualReps INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        actualWeightKg REAL NOT NULL,
        targetWeightKg REAL NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        restDurationSeconds INTEGER NOT NULL,
        FOREIGN KEY (exerciseLogId) REFERENCES exercise_logs (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_exercise_logs_session_id ON exercise_logs(sessionId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_set_logs_exercise_log_id ON set_logs(exerciseLogId)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        heightCm REAL NOT NULL,
        experienceLevel TEXT NOT NULL,
        primaryGoal TEXT NOT NULL,
        weeklyTargetDays INTEGER NOT NULL,
        profileImagePath TEXT,
        address TEXT,
        phone TEXT,
        isPhoneVerified INTEGER NOT NULL DEFAULT 0,
        dob TEXT,
        email TEXT,
        username TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Default Habits
    await db.insert('daily_habits', {
      'id': 'habit-1',
      'title': 'Morning Hydration (1L)',
      'subtitle': 'Completed at 7:45 AM',
      'isCompleted': 1,
      'status': 'done',
      'orderIndex': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('daily_habits', {
      'id': 'habit-2',
      'title': 'Target Protein Synthesis',
      'subtitle': '35g remaining for dinner',
      'isCompleted': 0,
      'status': 'pending',
      'orderIndex': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('daily_habits', {
      'id': 'habit-3',
      'title': 'Sleep Protocol (8h target)',
      'subtitle': 'Wind-down routine at 10:30 PM',
      'isCompleted': 0,
      'status': 'tonight',
      'orderIndex': 2,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _seedVersion13Data(db);
    await _seedVersion12Data(db);
  }

  Future<void> _seedVersion13Data(Database db) async {
    // 1. Comprehensive Canonical Exercises
    final baseExercises = [
      {'id': 'ex1', 'name': 'BB Bench Press', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex2', 'name': 'Incline DB Press', 'equipment': 'dumbbell', 'movementClassification': 'compound'},
      {'id': 'ex3', 'name': 'Cable Chest Flyes', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex4', 'name': 'Standing Overhead Press', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex5', 'name': 'Cable Lateral Raise', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex6', 'name': 'Tricep Pushdowns', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex7', 'name': 'Overhead Tricep Extension', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex8', 'name': 'Barbell Squat', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex9', 'name': 'Bent-Over Row', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex10', 'name': 'Conventional Deadlift', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex11', 'name': 'Romanian Deadlift', 'equipment': 'barbell', 'movementClassification': 'compound'},
      {'id': 'ex12', 'name': 'Wide-Grip Lat Pulldown', 'equipment': 'cable', 'movementClassification': 'compound'},
      {'id': 'ex13', 'name': 'Pull-Ups', 'equipment': 'bodyweight', 'movementClassification': 'compound'},
      {'id': 'ex14', 'name': 'Dumbbell Bicep Curl', 'equipment': 'dumbbell', 'movementClassification': 'isolation'},
      {'id': 'ex15', 'name': 'Hammer Curl', 'equipment': 'dumbbell', 'movementClassification': 'isolation'},
      {'id': 'ex16', 'name': 'Bulgarian Split Squat', 'equipment': 'dumbbell', 'movementClassification': 'compound'},
      {'id': 'ex17', 'name': 'Seated Leg Curl', 'equipment': 'machine', 'movementClassification': 'isolation'},
      {'id': 'ex18', 'name': 'Leg Extension', 'equipment': 'machine', 'movementClassification': 'isolation'},
      {'id': 'ex19', 'name': 'Standing Calf Raise', 'equipment': 'machine', 'movementClassification': 'isolation'},
      {'id': 'ex20', 'name': 'Cable Face Pull', 'equipment': 'cable', 'movementClassification': 'isolation'},
      {'id': 'ex21', 'name': 'Hanging Leg Raise', 'equipment': 'bodyweight', 'movementClassification': 'isolation'},
      {'id': 'ex22', 'name': 'Russian Kettlebell Swing', 'equipment': 'other', 'movementClassification': 'compound'},
      {'id': 'ex23', 'name': 'Goblet Squats + Press', 'equipment': 'dumbbell', 'movementClassification': 'compound'},
      {'id': 'ex24', 'name': 'Alternating Snatch Burpee', 'equipment': 'other', 'movementClassification': 'compound'},
      {'id': 'ex25', 'name': 'Dumbbell Chest Press', 'equipment': 'dumbbell', 'movementClassification': 'compound'},
    ];

    // Descriptive string aliases to guarantee 100% compatibility across legacy & new references
    final aliasMap = {
      'ex_barbell_bench_press': 'ex1',
      'ex_incline_dumbbell_press': 'ex2',
      'ex_cable_flyes': 'ex3',
      'ex_standing_overhead_press': 'ex4',
      'ex_cable_lateral_raise': 'ex5',
      'ex_tricep_pushdowns': 'ex6',
      'ex_overhead_triceps_extension': 'ex7',
      'ex_barbell_squat': 'ex8',
      'ex_bent_over_row': 'ex9',
      'ex_conventional_deadlift': 'ex10',
      'ex_romanian_deadlift': 'ex11',
      'ex_lat_pulldown': 'ex12',
      'ex_pull_ups': 'ex13',
      'ex_dumbbell_bicep_curl': 'ex14',
      'ex_hammer_curl': 'ex15',
      'ex_bulgarian_split_squat': 'ex16',
      'ex_seated_leg_curl': 'ex17',
      'ex_leg_extension': 'ex18',
      'ex_standing_calf_raise': 'ex19',
      'ex_face_pull': 'ex20',
      'ex_hanging_leg_raise': 'ex21',
      'ex_kettlebell_swing': 'ex22',
      'ex_goblet_squat': 'ex23',
      'ex_snatch_burpee': 'ex24',
      'ex_cable_chest_flyes': 'ex3',
    };

    for (var ex in baseExercises) {
      await db.insert('exercises', ex, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var entry in aliasMap.entries) {
      final base = baseExercises.firstWhere((e) => e['id'] == entry.value);
      await db.insert('exercises', {
        ...base,
        'id': entry.key,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2. Complete, Compatible Schedules
    final schedules = [
      {
        'id': 'sch1',
        'name': 'Push–Pull–Legs Split',
        'description': 'High mechanical tension for progressive muscular overload across push and pull patterns.',
        'targetMuscles': '["Chest", "Shoulders", "Triceps"]',
        'assignedWeekdays': '[1, 4]',
        'orderIndex': 1,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 8,
        'daysPerWeek': 4,
        'estimatedMinutes': 50,
        'isCustom': 0,
        'completionCount': 342,
      },
      {
        'id': 'sch2',
        'name': 'Strength Plateau Breaker',
        'description': 'Periodized heavy singles and dynamic effort waves designed to systematically shatter plateaus.',
        'targetMuscles': '["Back", "Core", "Quads"]',
        'assignedWeekdays': '[2, 5]',
        'orderIndex': 2,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Strength',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 3,
        'estimatedMinutes': 55,
        'isCustom': 0,
        'completionCount': 285,
      },
      {
        'id': 'sch3',
        'name': 'Arnold Split Classic',
        'description': 'Chest & Back agonist/antagonist pairings followed by shoulders, arms, and leg specialization.',
        'targetMuscles': '["Chest", "Back", "Shoulders", "Arms", "Legs"]',
        'assignedWeekdays': '[3, 6]',
        'orderIndex': 3,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 10,
        'daysPerWeek': 6,
        'estimatedMinutes': 60,
        'isCustom': 0,
        'completionCount': 194,
      },
      {
        'id': 'sch4',
        'name': 'German Volume Training (GVT)',
        'description': '10×10 volume protocol for high neuromuscular exhaustion and extreme hypertrophy adaptation.',
        'targetMuscles': '["Chest", "Quads", "Back"]',
        'assignedWeekdays': '[1, 2, 4, 5]',
        'orderIndex': 4,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Advanced',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 4,
        'estimatedMinutes': 40,
        'isCustom': 0,
        'completionCount': 156,
      },
      {
        'id': 'sch5',
        'name': 'Torso & Limb Split',
        'description': 'Separates chest/back days from arm and quad isolation for maximum recovery and tendon longevity.',
        'targetMuscles': '["Torso", "Arms", "Quads", "Hamstrings"]',
        'assignedWeekdays': '[1, 2, 4, 5]',
        'orderIndex': 5,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Intermediate',
        'experience': 'Intermediate',
        'equipment': 'Barbell & Cable',
        'durationWeeks': 8,
        'daysPerWeek': 4,
        'estimatedMinutes': 45,
        'isCustom': 0,
        'completionCount': 112,
      },
      {
        'id': 'trend_1',
        'name': 'Posterior Chain & Pull Focus',
        'description': 'Engineered for structural density, hinge power, and progressive trap & lat hypertrophy.',
        'targetMuscles': '["Back", "Hamstrings", "Glutes", "Traps"]',
        'assignedWeekdays': '[1, 3, 5]',
        'orderIndex': 6,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 4,
        'daysPerWeek': 4,
        'estimatedMinutes': 55,
        'isCustom': 0,
        'completionCount': 1420,
      },
      {
        'id': 'trend_2',
        'name': 'Upper Body Power / Tension',
        'description': 'Explosive bench speed sets paired with heavy horizontal pulls and rotator cuff resilience.',
        'targetMuscles': '["Chest", "Back", "Shoulders", "Arms"]',
        'assignedWeekdays': '[1, 3, 5]',
        'orderIndex': 7,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Strength',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 3,
        'estimatedMinutes': 50,
        'isCustom': 0,
        'completionCount': 980,
      },
      {
        'id': 'trend_3',
        'name': 'High Intensity Wave (HIW)',
        'description': 'Rapid neurological adaptation with descending rest periods and cluster set finishers.',
        'targetMuscles': '["Full Body", "Core", "Cardio"]',
        'assignedWeekdays': '[1, 2, 3, 5, 6]',
        'orderIndex': 8,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Agility & Speed',
        'experience': 'Intermediate',
        'equipment': 'Kettlebells & Bodyweight',
        'durationWeeks': 4,
        'daysPerWeek': 5,
        'estimatedMinutes': 40,
        'isCustom': 0,
        'completionCount': 2100,
      },
      {
        'id': 'spotlight_today',
        'name': 'Kettlebell Power Flow',
        'description': 'Follow 3 explosive conditioning circuits for metabolic conditioning and functional power.',
        'targetMuscles': '["Full Body", "Core", "Cardio"]',
        'assignedWeekdays': '[1, 3, 5]',
        'orderIndex': 9,
        'isArchived': 0,
        'isFavorite': 0,
        'focus': 'Metabolic HIIT',
        'experience': 'Intermediate',
        'equipment': 'Kettlebells & Bodyweight',
        'durationWeeks': 4,
        'daysPerWeek': 3,
        'estimatedMinutes': 32,
        'isCustom': 0,
        'completionCount': 875,
      },
      {
        'id': 'custom_push_hypertrophy',
        'name': 'Push Hypertrophy Custom',
        'description': 'Custom routine targeting upper chest and lateral delts.',
        'targetMuscles': '["Chest", "Shoulders", "Triceps"]',
        'assignedWeekdays': '[1, 4]',
        'orderIndex': 10,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Hypertrophy',
        'experience': 'Intermediate',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 4,
        'estimatedMinutes': 45,
        'isCustom': 1,
        'completionCount': 48,
      },
      {
        'id': 'custom_heavy_posterior',
        'name': 'Heavy Posterior Overload',
        'description': 'Custom heavy deadlift and hamstring loading protocol.',
        'targetMuscles': '["Hamstrings", "Back", "Glutes"]',
        'assignedWeekdays': '[2, 5]',
        'orderIndex': 11,
        'isArchived': 0,
        'isFavorite': 1,
        'focus': 'Strength',
        'experience': 'Advanced',
        'equipment': 'Full Gym',
        'durationWeeks': 6,
        'daysPerWeek': 4,
        'estimatedMinutes': 60,
        'isCustom': 1,
        'completionCount': 22,
      },
    ];

    for (var sch in schedules) {
      await db.insert('schedules', sch, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Complete Schedule Exercise Mappings
    final scheduleExercises = [
      // sch1 (Push-Pull-Legs Split)
      {'id': 'se_sch1_1', 'scheduleId': 'sch1', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 85.0, 'restDurationSeconds': 90},
      {'id': 'se_sch1_2', 'scheduleId': 'sch1', 'exerciseId': 'ex2', 'sortOrder': 2, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 30.0, 'restDurationSeconds': 75},
      {'id': 'se_sch1_3', 'scheduleId': 'sch1', 'exerciseId': 'ex4', 'sortOrder': 3, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 52.5, 'restDurationSeconds': 90},
      {'id': 'se_sch1_4', 'scheduleId': 'sch1', 'exerciseId': 'ex5', 'sortOrder': 4, 'targetSets': 4, 'targetReps': 15, 'targetWeightKg': 10.0, 'restDurationSeconds': 60},
      {'id': 'se_sch1_5', 'scheduleId': 'sch1', 'exerciseId': 'ex3', 'sortOrder': 5, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
      {'id': 'se_sch1_6', 'scheduleId': 'sch1', 'exerciseId': 'ex7', 'sortOrder': 6, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 25.0, 'restDurationSeconds': 60},

      // sch2 (Strength Plateau Breaker)
      {'id': 'se_sch2_1', 'scheduleId': 'sch2', 'exerciseId': 'ex8', 'sortOrder': 1, 'targetSets': 5, 'targetReps': 3, 'targetWeightKg': 100.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_2', 'scheduleId': 'sch2', 'exerciseId': 'ex1', 'sortOrder': 2, 'targetSets': 5, 'targetReps': 3, 'targetWeightKg': 85.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_3', 'scheduleId': 'sch2', 'exerciseId': 'ex10', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 5, 'targetWeightKg': 120.0, 'restDurationSeconds': 180},
      {'id': 'se_sch2_4', 'scheduleId': 'sch2', 'exerciseId': 'ex9', 'sortOrder': 4, 'targetSets': 4, 'targetReps': 6, 'targetWeightKg': 65.0, 'restDurationSeconds': 120},

      // sch3 (Arnold Split Classic)
      {'id': 'se_sch3_1', 'scheduleId': 'sch3', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_2', 'scheduleId': 'sch3', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_3', 'scheduleId': 'sch3', 'exerciseId': 'ex4', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 35.0, 'restDurationSeconds': 90},
      {'id': 'se_sch3_4', 'scheduleId': 'sch3', 'exerciseId': 'ex6', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},
      {'id': 'se_sch3_5', 'scheduleId': 'sch3', 'exerciseId': 'ex14', 'sortOrder': 5, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 14.0, 'restDurationSeconds': 60},

      // sch4 (GVT)
      {'id': 'se_sch4_1', 'scheduleId': 'sch4', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 60.0, 'restDurationSeconds': 60},
      {'id': 'se_sch4_2', 'scheduleId': 'sch4', 'exerciseId': 'ex8', 'sortOrder': 2, 'targetSets': 10, 'targetReps': 10, 'targetWeightKg': 80.0, 'restDurationSeconds': 60},
      {'id': 'se_sch4_3', 'scheduleId': 'sch4', 'exerciseId': 'ex9', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 50.0, 'restDurationSeconds': 60},

      // sch5 (Torso & Limb Split)
      {'id': 'se_sch5_1', 'scheduleId': 'sch5', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_sch5_2', 'scheduleId': 'sch5', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 90},
      {'id': 'se_sch5_3', 'scheduleId': 'sch5', 'exerciseId': 'ex3', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 15.0, 'restDurationSeconds': 60},
      {'id': 'se_sch5_4', 'scheduleId': 'sch5', 'exerciseId': 'ex14', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 14.0, 'restDurationSeconds': 60},

      // trend_1 (Posterior Chain & Pull Focus)
      {'id': 'se_trend1_1', 'scheduleId': 'trend_1', 'exerciseId': 'ex10', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 6, 'targetWeightKg': 130.0, 'restDurationSeconds': 120},
      {'id': 'se_trend1_2', 'scheduleId': 'trend_1', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_trend1_3', 'scheduleId': 'trend_1', 'exerciseId': 'ex12', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 55.0, 'restDurationSeconds': 75},
      {'id': 'se_trend1_4', 'scheduleId': 'trend_1', 'exerciseId': 'ex11', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 80.0, 'restDurationSeconds': 90},
      {'id': 'se_trend1_5', 'scheduleId': 'trend_1', 'exerciseId': 'ex20', 'sortOrder': 5, 'targetSets': 4, 'targetReps': 15, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},

      // trend_2 (Upper Body Power / Tension)
      {'id': 'se_trend2_1', 'scheduleId': 'trend_2', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 5, 'targetReps': 5, 'targetWeightKg': 90.0, 'restDurationSeconds': 120},
      {'id': 'se_trend2_2', 'scheduleId': 'trend_2', 'exerciseId': 'ex9', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 6, 'targetWeightKg': 75.0, 'restDurationSeconds': 90},
      {'id': 'se_trend2_3', 'scheduleId': 'trend_2', 'exerciseId': 'ex4', 'sortOrder': 3, 'targetSets': 4, 'targetReps': 6, 'targetWeightKg': 55.0, 'restDurationSeconds': 90},
      {'id': 'se_trend2_4', 'scheduleId': 'trend_2', 'exerciseId': 'ex13', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 0.0, 'restDurationSeconds': 90},
      {'id': 'se_trend2_5', 'scheduleId': 'trend_2', 'exerciseId': 'ex15', 'sortOrder': 5, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 16.0, 'restDurationSeconds': 60},

      // trend_3 (High Intensity Wave)
      {'id': 'se_trend3_1', 'scheduleId': 'trend_3', 'exerciseId': 'ex22', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 20, 'targetWeightKg': 24.0, 'restDurationSeconds': 45},
      {'id': 'se_trend3_2', 'scheduleId': 'trend_3', 'exerciseId': 'ex23', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},
      {'id': 'se_trend3_3', 'scheduleId': 'trend_3', 'exerciseId': 'ex24', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 16.0, 'restDurationSeconds': 60},
      {'id': 'se_trend3_4', 'scheduleId': 'trend_3', 'exerciseId': 'ex21', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 15, 'targetWeightKg': 0.0, 'restDurationSeconds': 45},

      // spotlight_today (Kettlebell Power Flow)
      {'id': 'se_spotlight_1', 'scheduleId': 'spotlight_today', 'exerciseId': 'ex22', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 20, 'targetWeightKg': 24.0, 'restDurationSeconds': 45},
      {'id': 'se_spotlight_2', 'scheduleId': 'spotlight_today', 'exerciseId': 'ex23', 'sortOrder': 2, 'targetSets': 4, 'targetReps': 12, 'targetWeightKg': 20.0, 'restDurationSeconds': 60},
      {'id': 'se_spotlight_3', 'scheduleId': 'spotlight_today', 'exerciseId': 'ex24', 'sortOrder': 3, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 16.0, 'restDurationSeconds': 60},

      // custom_push_hypertrophy
      {'id': 'se_cpush_1', 'scheduleId': 'custom_push_hypertrophy', 'exerciseId': 'ex1', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 80.0, 'restDurationSeconds': 90},
      {'id': 'se_cpush_2', 'scheduleId': 'custom_push_hypertrophy', 'exerciseId': 'ex2', 'sortOrder': 2, 'targetSets': 3, 'targetReps': 10, 'targetWeightKg': 28.0, 'restDurationSeconds': 75},
      {'id': 'se_cpush_3', 'scheduleId': 'custom_push_hypertrophy', 'exerciseId': 'ex5', 'sortOrder': 3, 'targetSets': 4, 'targetReps': 12, 'targetWeightKg': 10.0, 'restDurationSeconds': 60},
      {'id': 'se_cpush_4', 'scheduleId': 'custom_push_hypertrophy', 'exerciseId': 'ex6', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 25.0, 'restDurationSeconds': 60},

      // custom_heavy_posterior
      {'id': 'se_cpost_1', 'scheduleId': 'custom_heavy_posterior', 'exerciseId': 'ex10', 'sortOrder': 1, 'targetSets': 4, 'targetReps': 5, 'targetWeightKg': 140.0, 'restDurationSeconds': 150},
      {'id': 'se_cpost_2', 'scheduleId': 'custom_heavy_posterior', 'exerciseId': 'ex11', 'sortOrder': 2, 'targetSets': 3, 'targetReps': 8, 'targetWeightKg': 90.0, 'restDurationSeconds': 90},
      {'id': 'se_cpost_3', 'scheduleId': 'custom_heavy_posterior', 'exerciseId': 'ex9', 'sortOrder': 3, 'targetSets': 4, 'targetReps': 8, 'targetWeightKg': 70.0, 'restDurationSeconds': 90},
      {'id': 'se_cpost_4', 'scheduleId': 'custom_heavy_posterior', 'exerciseId': 'ex17', 'sortOrder': 4, 'targetSets': 3, 'targetReps': 12, 'targetWeightKg': 45.0, 'restDurationSeconds': 60},
    ];

    for (var se in scheduleExercises) {
      await db.insert('schedule_exercises', se, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 4. Default Bookmarks
    final bookmarks = ['sch1', 'sch3', 'trend_1', 'custom_push_hypertrophy', 'custom_heavy_posterior'];
    for (final b in bookmarks) {
      await db.insert('bookmarked_items', {
        'id': b,
        'createdAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedVersion12Data(Database db) async {
    // 7 Workout Sessions from September 2026 matching Stitch design system
    final sessions = [
      {
        'id': 'sess-1',
        'scheduleId': 'sch1',
        'startTime': '2026-09-29T10:00:00.000Z',
        'endTime': '2026-09-29T10:50:00.000Z',
        'durationSeconds': 3000,
        'totalCalories': 380,
        'notes': 'Felt great — hit a new bench PR today!',
        'intensity': 'RPE 8.8 (Optimal)',
        'totalSets': 21,
        'totalReps': 173,
        'totalVolumeKg': 8450.0,
      },
      {
        'id': 'sess-2',
        'scheduleId': 'sch2',
        'startTime': '2026-09-27T09:30:00.000Z',
        'endTime': '2026-09-27T10:12:00.000Z',
        'durationSeconds': 2520,
        'totalCalories': 330,
        'notes': 'Solid back volume, good grip strength.',
        'intensity': 'RPE 8.2',
        'totalSets': 18,
        'totalReps': 162,
        'totalVolumeKg': 7120.0,
      },
      {
        'id': 'sess-3',
        'scheduleId': 'sch3',
        'startTime': '2026-09-25T14:00:00.000Z',
        'endTime': '2026-09-25T14:53:00.000Z',
        'durationSeconds': 3180,
        'totalCalories': 490,
        'notes': 'High fatigue, crushed the heavy squats.',
        'intensity': 'RPE 9.1',
        'totalSets': 22,
        'totalReps': 180,
        'totalVolumeKg': 11200.0,
      },
      {
        'id': 'sess-4',
        'scheduleId': 'sch1',
        'startTime': '2026-09-22T10:15:00.000Z',
        'endTime': '2026-09-22T11:05:00.000Z',
        'durationSeconds': 3000,
        'totalCalories': 380,
        'notes': 'Chest focus, progressive overload maintained.',
        'intensity': 'RPE 8.5',
        'totalSets': 20,
        'totalReps': 165,
        'totalVolumeKg': 8200.0,
      },
      {
        'id': 'sess-5',
        'scheduleId': 'sch2',
        'startTime': '2026-09-20T09:00:00.000Z',
        'endTime': '2026-09-20T09:45:00.000Z',
        'durationSeconds': 2700,
        'totalCalories': 340,
        'notes': 'Back & Biceps volume day.',
        'intensity': 'RPE 8.0',
        'totalSets': 18,
        'totalReps': 160,
        'totalVolumeKg': 7050.0,
      },
      {
        'id': 'sess-6',
        'scheduleId': 'sch3',
        'startTime': '2026-09-18T16:30:00.000Z',
        'endTime': '2026-09-18T17:22:00.000Z',
        'durationSeconds': 3120,
        'totalCalories': 485,
        'notes': 'Leg day, posterior chain specialization.',
        'intensity': 'RPE 8.8',
        'totalSets': 21,
        'totalReps': 175,
        'totalVolumeKg': 10800.0,
      },
      {
        'id': 'sess-7',
        'scheduleId': 'sch1',
        'startTime': '2026-09-15T11:00:00.000Z',
        'endTime': '2026-09-15T11:48:00.000Z',
        'durationSeconds': 2880,
        'totalCalories': 375,
        'notes': 'Shoulders and triceps pump.',
        'intensity': 'RPE 8.4',
        'totalSets': 20,
        'totalReps': 165,
        'totalVolumeKg': 8100.0,
      },
    ];

    for (final s in sessions) {
      await db.insert('workout_sessions', s, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Detailed exercise logs for sess-1 (Chest, Shoulders & Triceps) matching Stitch
    final exLogs = [
      {'id': 'log_1_1', 'sessionId': 'sess-1', 'exerciseId': 'ex1', 'orderIndex': 0, 'isSkipped': 0},
      {'id': 'log_1_2', 'sessionId': 'sess-1', 'exerciseId': 'ex2', 'orderIndex': 1, 'isSkipped': 0},
      {'id': 'log_1_3', 'sessionId': 'sess-1', 'exerciseId': 'ex3', 'orderIndex': 2, 'isSkipped': 0},
      {'id': 'log_1_4', 'sessionId': 'sess-1', 'exerciseId': 'ex4', 'orderIndex': 3, 'isSkipped': 0},
      {'id': 'log_1_5', 'sessionId': 'sess-1', 'exerciseId': 'ex5', 'orderIndex': 4, 'isSkipped': 1, 'skip_reason': 'Time constraint'},
      {'id': 'log_1_6', 'sessionId': 'sess-1', 'exerciseId': 'ex6', 'orderIndex': 5, 'isSkipped': 0},
      {'id': 'log_1_7', 'sessionId': 'sess-1', 'exerciseId': 'ex7', 'orderIndex': 6, 'isSkipped': 0},
    ];

    for (final l in exLogs) {
      await db.insert('exercise_logs', l, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final setLogs = [
      // ex1: Barbell Bench Press (3 sets · 2,338 kg)
      {'id': 's1_1', 'exerciseLogId': 'log_1_1', 'setNumber': 1, 'actualReps': 8, 'targetReps': 8, 'actualWeightKg': 100.0, 'targetWeightKg': 100.0, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's1_2', 'exerciseLogId': 'log_1_1', 'setNumber': 2, 'actualReps': 8, 'targetReps': 8, 'actualWeightKg': 102.5, 'targetWeightKg': 102.5, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's1_3', 'exerciseLogId': 'log_1_1', 'setNumber': 3, 'actualReps': 7, 'targetReps': 8, 'actualWeightKg': 102.5, 'targetWeightKg': 102.5, 'isCompleted': 1, 'restDurationSeconds': 90},

      // ex2: Incline DB Press (3 sets · 928 kg)
      {'id': 's2_1', 'exerciseLogId': 'log_1_2', 'setNumber': 1, 'actualReps': 10, 'targetReps': 10, 'actualWeightKg': 32.0, 'targetWeightKg': 32.0, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's2_2', 'exerciseLogId': 'log_1_2', 'setNumber': 2, 'actualReps': 10, 'targetReps': 10, 'actualWeightKg': 32.0, 'targetWeightKg': 32.0, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's2_3', 'exerciseLogId': 'log_1_2', 'setNumber': 3, 'actualReps': 9, 'targetReps': 10, 'actualWeightKg': 32.0, 'targetWeightKg': 32.0, 'isCompleted': 1, 'restDurationSeconds': 90},

      // ex3: Cable Incline Flyes (3 sets · 680 kg)
      {'id': 's3_1', 'exerciseLogId': 'log_1_3', 'setNumber': 1, 'actualReps': 12, 'targetReps': 12, 'actualWeightKg': 20.0, 'targetWeightKg': 20.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's3_2', 'exerciseLogId': 'log_1_3', 'setNumber': 2, 'actualReps': 11, 'targetReps': 12, 'actualWeightKg': 20.0, 'targetWeightKg': 20.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's3_3', 'exerciseLogId': 'log_1_3', 'setNumber': 3, 'actualReps': 11, 'targetReps': 12, 'actualWeightKg': 20.0, 'targetWeightKg': 20.0, 'isCompleted': 1, 'restDurationSeconds': 60},

      // ex4: Overhead Press (3 sets · 1,420 kg)
      {'id': 's4_1', 'exerciseLogId': 'log_1_4', 'setNumber': 1, 'actualReps': 8, 'targetReps': 8, 'actualWeightKg': 60.0, 'targetWeightKg': 60.0, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's4_2', 'exerciseLogId': 'log_1_4', 'setNumber': 2, 'actualReps': 8, 'targetReps': 8, 'actualWeightKg': 60.0, 'targetWeightKg': 60.0, 'isCompleted': 1, 'restDurationSeconds': 90},
      {'id': 's4_3', 'exerciseLogId': 'log_1_4', 'setNumber': 3, 'actualReps': 8, 'targetReps': 8, 'actualWeightKg': 57.5, 'targetWeightKg': 57.5, 'isCompleted': 1, 'restDurationSeconds': 90},

      // ex6: Triceps Pushdowns (3 sets · 1,360 kg)
      {'id': 's6_1', 'exerciseLogId': 'log_1_6', 'setNumber': 1, 'actualReps': 13, 'targetReps': 12, 'actualWeightKg': 35.0, 'targetWeightKg': 35.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's6_2', 'exerciseLogId': 'log_1_6', 'setNumber': 2, 'actualReps': 13, 'targetReps': 12, 'actualWeightKg': 35.0, 'targetWeightKg': 35.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's6_3', 'exerciseLogId': 'log_1_6', 'setNumber': 3, 'actualReps': 13, 'targetReps': 12, 'actualWeightKg': 35.0, 'targetWeightKg': 35.0, 'isCompleted': 1, 'restDurationSeconds': 60},

      // ex7: Skull Crushers (3 sets · 875 kg)
      {'id': 's7_1', 'exerciseLogId': 'log_1_7', 'setNumber': 1, 'actualReps': 12, 'targetReps': 12, 'actualWeightKg': 25.0, 'targetWeightKg': 25.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's7_2', 'exerciseLogId': 'log_1_7', 'setNumber': 2, 'actualReps': 12, 'targetReps': 12, 'actualWeightKg': 25.0, 'targetWeightKg': 25.0, 'isCompleted': 1, 'restDurationSeconds': 60},
      {'id': 's7_3', 'exerciseLogId': 'log_1_7', 'setNumber': 3, 'actualReps': 11, 'targetReps': 12, 'actualWeightKg': 25.0, 'targetWeightKg': 25.0, 'isCompleted': 1, 'restDurationSeconds': 60},
    ];

    for (final s in setLogs) {
      await db.insert('set_logs', s, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
