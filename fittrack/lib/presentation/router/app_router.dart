import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  GoRouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
    _ref.listen(userProfileProvider, (_, __) => notifyListeners());
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
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
