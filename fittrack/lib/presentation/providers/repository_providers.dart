import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../../domain/repositories/i_workout_session_repository.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/sqlite_user_repository.dart';
import '../../data/repositories/sqlite_schedule_repository.dart';
import '../../data/repositories/sqlite_workout_session_repository.dart';
import '../../data/repositories/sqlite_exercise_repository.dart';
import '../../data/datasources/local/database_helper.dart';

import '../../domain/repositories/i_security_repository.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../domain/repositories/i_theme_repository.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/i_bio_metrics_repository.dart';
import '../../data/repositories/bio_metrics_repository_impl.dart';
import '../../domain/repositories/i_habits_repository.dart';
import '../../data/repositories/habits_repository_impl.dart';
import '../../domain/repositories/i_lifestyle_content_repository.dart';
import '../../data/repositories/lifestyle_content_repository_impl.dart';
import 'shared_preferences_provider.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return MockAuthRepository();
}

@Riverpod(keepAlive: true)
IUserRepository userRepository(Ref ref) {
  return SqliteUserRepository(DatabaseHelper.instance);
}

@Riverpod(keepAlive: true)
IScheduleRepository scheduleRepository(Ref ref) {
  return SqliteScheduleRepository(DatabaseHelper.instance);
}

@Riverpod(keepAlive: true)
IWorkoutSessionRepository workoutSessionRepository(Ref ref) {
  return SqliteWorkoutSessionRepository(DatabaseHelper.instance);
}

@Riverpod(keepAlive: true)
IExerciseRepository exerciseRepository(Ref ref) {
  return SqliteExerciseRepository(DatabaseHelper.instance);
}

@Riverpod(keepAlive: true)
ISecurityRepository securityRepository(Ref ref) {
  return SecurityRepositoryImpl();
}

@Riverpod(keepAlive: true)
IThemeRepository themeRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeRepositoryImpl(prefs);
}

@Riverpod(keepAlive: true)
IBioMetricsRepository bioMetricsRepository(Ref ref) {
  return const BioMetricsRepositoryImpl();
}

@Riverpod(keepAlive: true)
IHabitsRepository habitsRepository(Ref ref) {
  return HabitsRepositoryImpl();
}

@Riverpod(keepAlive: true)
ILifestyleContentRepository lifestyleContentRepository(Ref ref) {
  return const LifestyleContentRepositoryImpl();
}

