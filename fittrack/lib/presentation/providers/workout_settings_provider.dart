import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

part 'workout_settings_provider.freezed.dart';
part 'workout_settings_provider.g.dart';

/// Immutable state containing all workout preferences, timer configs,
/// measurement units, and hardware/equipment defaults.
@freezed
abstract class WorkoutSettingsState with _$WorkoutSettingsState {
  const factory WorkoutSettingsState({
    @Default('01:30') String defaultRestTimer,
    @Default(true) bool autoStartRestTimer,
    @Default(true) bool keepScreenAwake,
    @Default(true) bool enableRPE,
    @Default(false) bool includeWarmups,
    @Default(true) bool plateCalculator,
    @Default('kg') String weightUnit,
    @Default('km') String distanceUnit,
    @Default('cm') String bodyUnit,
    @Default(20.0) double barbellWeight,
    @Default(10.0) double ezBarWeight,
    @Default('Home Gym / Power Rack') String gymProfile,
  }) = _WorkoutSettingsState;
}

/// Riverpod notifier managing [WorkoutSettingsState] persistence and reactive updates.
@Riverpod(keepAlive: true)
class WorkoutSettingsNotifier extends _$WorkoutSettingsNotifier {
  static const _keyPrefix = 'workout_settings_';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  WorkoutSettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    return WorkoutSettingsState(
      defaultRestTimer:
          prefs.getString('${_keyPrefix}defaultRestTimer') ?? '01:30',
      autoStartRestTimer:
          prefs.getBool('${_keyPrefix}autoStartRestTimer') ?? true,
      keepScreenAwake:
          prefs.getBool('${_keyPrefix}keepScreenAwake') ?? true,
      enableRPE: prefs.getBool('${_keyPrefix}enableRPE') ?? true,
      includeWarmups:
          prefs.getBool('${_keyPrefix}includeWarmups') ?? false,
      plateCalculator:
          prefs.getBool('${_keyPrefix}plateCalculator') ?? true,
      weightUnit: prefs.getString('${_keyPrefix}weightUnit') ?? 'kg',
      distanceUnit: prefs.getString('${_keyPrefix}distanceUnit') ?? 'km',
      bodyUnit: prefs.getString('${_keyPrefix}bodyUnit') ?? 'cm',
      barbellWeight:
          prefs.getDouble('${_keyPrefix}barbellWeight') ?? 20.0,
      ezBarWeight:
          prefs.getDouble('${_keyPrefix}ezBarWeight') ?? 10.0,
      gymProfile: prefs.getString('${_keyPrefix}gymProfile') ??
          'Home Gym / Power Rack',
    );
  }

  Future<void> setDefaultRestTimer(String timer) async {
    state = state.copyWith(defaultRestTimer: timer);
    await _prefs.setString('${_keyPrefix}defaultRestTimer', timer);
  }

  Future<void> toggleAutoStartRestTimer(bool value) async {
    state = state.copyWith(autoStartRestTimer: value);
    await _prefs.setBool('${_keyPrefix}autoStartRestTimer', value);
  }

  Future<void> toggleKeepScreenAwake(bool value) async {
    state = state.copyWith(keepScreenAwake: value);
    await _prefs.setBool('${_keyPrefix}keepScreenAwake', value);
  }

  Future<void> toggleEnableRPE(bool value) async {
    state = state.copyWith(enableRPE: value);
    await _prefs.setBool('${_keyPrefix}enableRPE', value);
  }

  Future<void> toggleIncludeWarmups(bool value) async {
    state = state.copyWith(includeWarmups: value);
    await _prefs.setBool('${_keyPrefix}includeWarmups', value);
  }

  Future<void> togglePlateCalculator(bool value) async {
    state = state.copyWith(plateCalculator: value);
    await _prefs.setBool('${_keyPrefix}plateCalculator', value);
  }

  Future<void> setWeightUnit(String unit) async {
    state = state.copyWith(weightUnit: unit);
    await _prefs.setString('${_keyPrefix}weightUnit', unit);
  }

  Future<void> setDistanceUnit(String unit) async {
    state = state.copyWith(distanceUnit: unit);
    await _prefs.setString('${_keyPrefix}distanceUnit', unit);
  }

  Future<void> setBodyUnit(String unit) async {
    state = state.copyWith(bodyUnit: unit);
    await _prefs.setString('${_keyPrefix}bodyUnit', unit);
  }

  Future<void> setBarbellWeight(double weight) async {
    state = state.copyWith(barbellWeight: weight);
    await _prefs.setDouble('${_keyPrefix}barbellWeight', weight);
  }

  Future<void> setEzBarWeight(double weight) async {
    state = state.copyWith(ezBarWeight: weight);
    await _prefs.setDouble('${_keyPrefix}ezBarWeight', weight);
  }

  Future<void> setGymProfile(String profile) async {
    state = state.copyWith(gymProfile: profile);
    await _prefs.setString('${_keyPrefix}gymProfile', profile);
  }

  Future<void> resetToDefaults() async {
    const defaults = WorkoutSettingsState();
    state = defaults;
    await Future.wait([
      _prefs.setString('${_keyPrefix}defaultRestTimer', defaults.defaultRestTimer),
      _prefs.setBool('${_keyPrefix}autoStartRestTimer', defaults.autoStartRestTimer),
      _prefs.setBool('${_keyPrefix}keepScreenAwake', defaults.keepScreenAwake),
      _prefs.setBool('${_keyPrefix}enableRPE', defaults.enableRPE),
      _prefs.setBool('${_keyPrefix}includeWarmups', defaults.includeWarmups),
      _prefs.setBool('${_keyPrefix}plateCalculator', defaults.plateCalculator),
      _prefs.setString('${_keyPrefix}weightUnit', defaults.weightUnit),
      _prefs.setString('${_keyPrefix}distanceUnit', defaults.distanceUnit),
      _prefs.setString('${_keyPrefix}bodyUnit', defaults.bodyUnit),
      _prefs.setDouble('${_keyPrefix}barbellWeight', defaults.barbellWeight),
      _prefs.setDouble('${_keyPrefix}ezBarWeight', defaults.ezBarWeight),
      _prefs.setString('${_keyPrefix}gymProfile', defaults.gymProfile),
    ]);
  }
}

/// Backward compatibility alias for the generated workoutSettingsProvider.
final workoutSettingsNotifierProvider = workoutSettingsProvider;
