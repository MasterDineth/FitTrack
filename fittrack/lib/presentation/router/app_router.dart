import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/reset_verification_screen.dart';
import '../screens/set_new_password_screen.dart';
import '../screens/telemetry_setup_screen.dart';
import '../screens/fitness_profile_setup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/workout_schedules_screen.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/create_schedule_screen.dart';
import '../screens/create_custom_exercise_screen.dart';
import '../screens/active_workout_screen.dart';
import '../screens/exercise_guide_details_screen.dart';
import '../screens/workout_summary_screen.dart';
import '../screens/workout_history_screen.dart';
import '../screens/workout_history_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/settings/settings_subscreens.dart';
import '../widgets/bottom_nav_shell.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
final shellNavigatorWorkoutsKey = GlobalKey<NavigatorState>(debugLabel: 'shellWorkouts');
final shellNavigatorHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
final shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  GoRouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
    _ref.listen(userProfileProvider, (_, _) => notifyListeners());
  }
}

@riverpod
GoRouter router(Ref ref) {
  final notifier = GoRouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final userProfileState = ref.read(userProfileProvider);

      final isAuthLoading = authState.isLoading;
      final user = authState.value;
      final isAuthenticated = user != null;

      final matchedLocation = state.matchedLocation;
      final isSplash = matchedLocation == '/splash';
      final isWelcome = matchedLocation == '/welcome';
      final isAuth = matchedLocation == '/auth';
      final isReset = matchedLocation.startsWith('/reset');

      if (isAuthLoading) {
        return null;
      }

      if (!isAuthenticated) {
        if (isWelcome || isAuth || isReset) {
          return null; 
        }
        return '/welcome';
      }

      final profileComplete = userProfileState.value?.isComplete ?? false;
      final isTelemetry = matchedLocation == '/onboarding/telemetry';
      final isFitness = matchedLocation == '/onboarding/fitness';

      if (!profileComplete) {
        if (isTelemetry || isFitness) {
          return null; 
        }
        return '/onboarding/telemetry';
      }

      if (isSplash || isWelcome || isAuth || isReset || isTelemetry || isFitness) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/reset/verify',
        builder: (context, state) => const ResetVerificationScreen(),
      ),
      GoRoute(
        path: '/reset/new-password',
        builder: (context, state) => const SetNewPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding/telemetry',
        builder: (context, state) => const TelemetrySetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/fitness',
        builder: (context, state) => const FitnessProfileSetupScreen(),
      ),
      GoRoute(
        path: '/workouts/detail/:scheduleId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => WorkoutDetailScreen(
          scheduleId: state.pathParameters['scheduleId']!,
        ),
      ),
      GoRoute(
        path: '/workouts/create-schedule',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateScheduleScreen(),
      ),
      GoRoute(
        path: '/exercises/create-custom',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateCustomExerciseScreen(),
      ),
      GoRoute(
        path: '/workouts/active/:scheduleId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ActiveWorkoutScreen(
          scheduleId: state.pathParameters['scheduleId']!,
        ),
      ),
      GoRoute(
        path: '/workouts/guide/:exerciseId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ExerciseGuideDetailsScreen(
          exerciseId: state.pathParameters['exerciseId']!,
        ),
      ),
      GoRoute(
        path: '/workouts/summary',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WorkoutSummaryScreen(),
      ),
      GoRoute(
        path: '/history/detail/:sessionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => WorkoutHistoryDetailScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: '/settings/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AccountDetailsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SecurityAppLockScreen(),
      ),
      GoRoute(
        path: '/settings/password',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PasswordSecurityScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/data',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DataManagementScreen(),
      ),
      GoRoute(
        path: '/settings/workout-preferences',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WorkoutPreferencesScreen(),
      ),
      GoRoute(
        path: '/settings/units-equipment',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UnitsEquipmentScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorWorkoutsKey,
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const WorkoutSchedulesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const WorkoutHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
