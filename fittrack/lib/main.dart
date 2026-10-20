import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'presentation/providers/shared_preferences_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/active_workout_provider.dart';
import 'presentation/providers/notification_permission_provider.dart';
import 'presentation/providers/notification_service_provider.dart';
import 'presentation/providers/notification_coordinator_provider.dart';
import 'presentation/providers/splash_provider.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/modals/resume_workout_recovery_modal.dart';
import 'presentation/widgets/notifications/global_notification_shade_host.dart';

import 'core/debug/ft_provider_observer.dart';

final ftProviderObserver = FtProviderObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintRebuildDirtyWidgets = true;
  // Lock to portrait for now; remove when tablet layout is added.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-load SharedPreferences before mounting UI to eliminate theme flash
  final sharedPreferences = await SharedPreferences.getInstance();

  // Phase 2: initialise timezone database.
  tz_data.initializeTimeZones();
  try {
    final localTzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTzName));
  } catch (_) {
    // Fallback to UTC if timezone detection fails.
  }

  runApp(
    ProviderScope(
      observers: [
        ftProviderObserver,
      ],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends ConsumerStatefulWidget {
  const FitTrackApp({super.key});

  @override
  ConsumerState<FitTrackApp> createState() => _FitTrackAppState();
}

class _FitTrackAppState extends ConsumerState<FitTrackApp>
    with WidgetsBindingObserver {
  bool _notificationServiceInitialised = false;
  bool _recoveryModalShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialise notification service after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());

    // Check workout snapshot recovery when splash finishes (§2.3)
    ref.listenManual(splashDoneProvider, (prev, isDone) {
      if (isDone) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _checkWorkoutRecovery());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission and replan reminders on every resume.
      if (_notificationServiceInitialised) {
        ref.read(notificationPermissionProvider.notifier).refresh();
        ref.read(notificationCoordinatorProvider.notifier)
            .planAndScheduleReminders();
      }
    }
  }

  Future<void> _initNotifications() async {
    if (_notificationServiceInitialised) return;
    try {
      final svc = ref.read(notificationServiceProvider);
      await svc.init(
        onTap: (payload) async {
          // Forwarded to coordinator pending route
          ref.read(pendingNotificationRouteProvider.notifier).set(payload);
        },
      );
      // Warm up the coordinator (registers the IsolateNameServer port).
      ref.read(notificationCoordinatorProvider.notifier);
      // Schedule reminders on first launch / cold start.
      ref
          .read(notificationCoordinatorProvider.notifier)
          .planAndScheduleReminders();

      // Cold-start launch payload (§2.6)
      final launchPayload = await svc.getLaunchPayload();
      if (launchPayload != null) {
        ref.read(pendingNotificationRouteProvider.notifier).set(launchPayload);
      }

      _notificationServiceInitialised = true;
    } catch (_) {
      // Notification service init is non-fatal; the app works without it.
    }
  }

  void _checkWorkoutRecovery() {
    if (_recoveryModalShown) return;

    final snapshot = ref.read(liveSnapshotStoreProvider).load();
    if (snapshot == null) return;

    final activeState = ref.read(activeWorkoutProvider);
    if (activeState.phase == WorkoutPhase.active ||
        activeState.phase == WorkoutPhase.resting ||
        activeState.phase == WorkoutPhase.paused) {
      return;
    }

    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      _recoveryModalShown = true;
      showResumeWorkoutRecoveryModal(
        context,
        snapshot: snapshot,
        onResume: () async {
          await ref
              .read(activeWorkoutProvider.notifier)
              .restoreFromSnapshot(snapshot);
          ref
              .read(routerProvider)
              .go('/workouts/active/${snapshot.scheduleId}');
        },
        onDiscard: () {
          ref.read(liveSnapshotStoreProvider).clear();
          ref.read(notificationServiceProvider).clearLive();
          ref.read(activeWorkoutProvider.notifier).discardSession();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeSettings = ref.watch(themeNotifierProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightScheme;
        ColorScheme? darkScheme;

        if (themeSettings.useDynamicAccent &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightScheme = lightDynamic;
          darkScheme = darkDynamic;
        }

        return MaterialApp.router(
          title: 'FitTrack',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(themeSettings, lightScheme),
          darkTheme: buildDarkTheme(themeSettings, darkScheme),
          themeMode: themeSettings.themeMode,
          routerConfig: router,
          builder: (context, child) {
            return GlobalNotificationShadeHost(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

