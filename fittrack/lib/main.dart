import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/shared_preferences_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait for now; remove when tablet layout is added.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-load SharedPreferences before mounting UI to eliminate theme flash
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends ConsumerWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        );
      },
    );
  }
}
