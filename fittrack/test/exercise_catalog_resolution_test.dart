import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/domain/entities/exercise_catalog.dart';

void main() {
  group('ExerciseCatalog Resolution Tests', () {
    test('Resolves names for all exercises without raw ID fallbacks', () {
      expect(ExerciseCatalog.resolveName('ex10'), equals('Deadlift'));
      expect(ExerciseCatalog.resolveName('ex9'), equals('Bent-Over Row'));
      expect(ExerciseCatalog.resolveName('ex12'), equals('Wide-Grip Lat Pulldown'));
      expect(ExerciseCatalog.resolveName('ex11'), equals('Romanian Deadlift'));
      expect(ExerciseCatalog.resolveName('ex20'), equals('Cable Face Pull'));
      expect(ExerciseCatalog.resolveName('ex1'), equals('BB Bench Press'));
      expect(ExerciseCatalog.resolveName('ex2'), equals('Incline DB Press'));
      expect(ExerciseCatalog.resolveName('ex3'), equals('Cable Chest Flyes'));
      expect(ExerciseCatalog.resolveName('ex4'), equals('Standing Overhead Press'));
      expect(ExerciseCatalog.resolveName('ex5'), equals('Cable Lateral Raise'));
      expect(ExerciseCatalog.resolveName('ex6'), equals('Tricep Pushdowns'));
      expect(ExerciseCatalog.resolveName('ex7'), equals('Overhead Tricep Extension'));
      expect(ExerciseCatalog.resolveName('ex8'), equals('Barbell Squat'));
      expect(ExerciseCatalog.resolveName('ex13'), equals('Pull-Ups'));
      expect(ExerciseCatalog.resolveName('ex14'), equals('Dumbbell Bicep Curl'));
      expect(ExerciseCatalog.resolveName('ex15'), equals('Hammer Curl'));
      expect(ExerciseCatalog.resolveName('ex16'), equals('Bulgarian Split Squat'));
      expect(ExerciseCatalog.resolveName('ex17'), equals('Seated Leg Curl'));
      expect(ExerciseCatalog.resolveName('ex18'), equals('Leg Extension'));
      expect(ExerciseCatalog.resolveName('ex19'), equals('Standing Calf Raise'));
      expect(ExerciseCatalog.resolveName('ex21'), equals('Hanging Leg Raise'));
      expect(ExerciseCatalog.resolveName('ex22'), equals('Russian Kettlebell Swing'));
      expect(ExerciseCatalog.resolveName('ex23'), equals('Goblet Squats + Press'));
      expect(ExerciseCatalog.resolveName('ex24'), equals('Alternating Snatch Burpee'));
      expect(ExerciseCatalog.resolveName('ex25'), equals('Dumbbell Chest Press'));
    });

    test('Resolves correct primary muscles for Posterior Chain exercises', () {
      expect(ExerciseCatalog.resolveMuscle('ex10'), equals('Back'));
      expect(ExerciseCatalog.resolveMuscle('ex9'), equals('Back'));
      expect(ExerciseCatalog.resolveMuscle('ex12'), equals('Back'));
      expect(ExerciseCatalog.resolveMuscle('ex11'), equals('Hamstrings'));
      expect(ExerciseCatalog.resolveMuscle('ex20'), equals('Back'));
    });

    test('Identifies alias equality and distinguishes different deadlift variations', () {
      // Conventional deadlift canonical vs alias
      expect(
        ExerciseCatalog.isSameExercise('ex10', 'ex_conventional_deadlift'),
        isTrue,
      );
      expect(
        ExerciseCatalog.isSameExercise('ex_conventional_deadlift', 'ex10'),
        isTrue,
      );

      // Deadlift vs Romanian deadlift MUST NOT match
      expect(
        ExerciseCatalog.isSameExercise('ex10', 'ex11'),
        isFalse,
      );
      expect(
        ExerciseCatalog.isSameExercise('ex10', 'ex_romanian_deadlift'),
        isFalse,
      );
      expect(
        ExerciseCatalog.isSameExercise('ex_conventional_deadlift', 'ex_romanian_deadlift'),
        isFalse,
      );

      // Romanian deadlift canonical vs alias
      expect(
        ExerciseCatalog.isSameExercise('ex11', 'ex_romanian_deadlift'),
        isTrue,
      );
    });

    test('All 25 canonical specs are complete and valid', () {
      expect(ExerciseCatalog.specs.length, equals(25));
      for (final spec in ExerciseCatalog.specs) {
        expect(spec.canonicalId, isNotEmpty);
        expect(spec.name, isNotEmpty);
        expect(spec.primaryMuscle, isNotEmpty);
        expect(spec.imageAsset, isNotEmpty);
      }
    });

    test('toCanonicalId converts aliases properly', () {
      expect(ExerciseCatalog.toCanonicalId('ex_conventional_deadlift'), equals('ex10'));
      expect(ExerciseCatalog.toCanonicalId('ex_barbell_bench_press'), equals('ex1'));
      expect(ExerciseCatalog.toCanonicalId('ex_bent_over_row'), equals('ex9'));
      expect(ExerciseCatalog.toCanonicalId('ex_romanian_deadlift'), equals('ex11'));
      expect(ExerciseCatalog.toCanonicalId('ex_lat_pulldown'), equals('ex12'));
      expect(ExerciseCatalog.toCanonicalId('ex_face_pull'), equals('ex20'));
    });
  });
}
