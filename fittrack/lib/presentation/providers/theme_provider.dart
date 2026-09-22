import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/theme_settings.dart';
import 'repository_providers.dart';

export '../../domain/entities/theme_settings.dart';

part 'theme_provider.g.dart';

/// Riverpod notifier managing [ThemeSettings] state and persistence.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeSettings build() {
    final repository = ref.watch(themeRepositoryProvider);
    return repository.getThemeSettings();
  }

  /// Updates the application theme mode (System, Light, or Dark).
  Future<void> setThemeMode(ThemeMode mode) async {
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Updates the accent color using a [Color] instance.
  Future<void> setAccentColor(Color color) async {
    final updated = state.copyWith(accentColorValue: color.toARGB32());
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Updates the accent color using an integer ARGB value.
  Future<void> setAccentColorValue(int colorValue) async {
    final updated = state.copyWith(accentColorValue: colorValue);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Toggles dynamic wallpaper/OS accent extraction.
  Future<void> toggleDynamicAccent(bool value) async {
    final updated = state.copyWith(useDynamicAccent: value);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Toggles pure black (#000000) OLED display mode.
  Future<void> toggleOledBlack(bool value) async {
    final updated = state.copyWith(useOledBlack: value);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Toggles high contrast text mode.
  Future<void> toggleHighContrast(bool value) async {
    final updated = state.copyWith(useHighContrast: value);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Toggles automatic dark mode during active workouts.
  Future<void> toggleAutoDarkWorkout(bool value) async {
    final updated = state.copyWith(autoDarkWorkout: value);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }

  /// Toggles keeping the screen awake during active workouts.
  Future<void> toggleKeepScreenAwake(bool value) async {
    final updated = state.copyWith(keepScreenAwake: value);
    state = updated;
    await ref.read(themeRepositoryProvider).saveThemeSettings(updated);
  }
}

/// Convenience alias matching user prompt naming.
final themeNotifierProvider = themeProvider;
