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
import 'shared_preferences_provider.dart';

part 'repository_providers.g.dart';

@riverpod
IAuthRepository authRepository(Ref ref) {
  return MockAuthRepository();
}

@riverpod
IUserRepository userRepository(Ref ref) {
  return SqliteUserRepository(DatabaseHelper.instance);
}

@riverpod
IScheduleRepository scheduleRepository(Ref ref) {
  return SqliteScheduleRepository(DatabaseHelper.instance);
}

@riverpod
IWorkoutSessionRepository workoutSessionRepository(Ref ref) {
  return SqliteWorkoutSessionRepository(DatabaseHelper.instance);
}

@riverpod
IExerciseRepository exerciseRepository(Ref ref) {
  return SqliteExerciseRepository(DatabaseHelper.instance);
}

@riverpod
ISecurityRepository securityRepository(Ref ref) {
  return SecurityRepositoryImpl();
}

@riverpod
IThemeRepository themeRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeRepositoryImpl(prefs);
}

