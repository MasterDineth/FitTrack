import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

part 'notification_settings_provider.freezed.dart';
part 'notification_settings_provider.g.dart';

/// Immutable state containing all toggle flags and interval preferences
/// for FitTrack notifications, live workout tracking, haptics, and audio alerts.
@freezed
abstract class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState({
    // Section 1: System Notifications (Master)
    @Default(true) bool systemNotifications,

    // Section 2: Live Activities
    @Default(true) bool liveWorkoutStatus,
    @Default(true) bool showScheduleProgress,
    @Default(true) bool showSetProgress,
    @Default(true) bool showRestTimerControls,

    // Section 3: Standard Notifications
    @Default(true) bool routineWorkoutReminders,
    @Default(true) bool hydrationReminders,
    @Default('Every 2 hrs') String hydrationInterval,
    @Default(true) bool scheduleStatusAlerts,
    @Default(true) bool workoutScheduleCompletion,
    @Default(true) bool historyRecordedSaved,

    // Section 4: Haptic Feedback
    @Default(true) bool hapticsEnabled,
    @Default(true) bool hapticAppNav,
    @Default(true) bool hapticWorkoutStatus,
    @Default(true) bool hapticSetStatus,
    @Default(true) bool hapticWorkoutCompletion,
    @Default(true) bool hapticTimerCountdowns,

    // Section 5: Audio Notifications
    @Default(true) bool audioEnabled,
    @Default(true) bool audioScheduleStatus,
    @Default(true) bool audioWorkoutStartFinish,
    @Default(true) bool audioSetCompletion,
    @Default(true) bool audioTimerCountdown,
  }) = _NotificationSettingsState;
}

/// Riverpod notifier managing [NotificationSettingsState] lifecycle and persistence.
@Riverpod(keepAlive: true)
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  static const _keyPrefix = 'notif_settings_';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  NotificationSettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    String rawInterval = prefs.getString('${_keyPrefix}hydrationInterval') ?? 'Every 2 hrs';
    if (!rawInterval.startsWith('Every ') && rawInterval.endsWith('hrs')) {
      rawInterval = 'Every $rawInterval';
    }

    return NotificationSettingsState(
      systemNotifications: prefs.getBool('${_keyPrefix}systemNotifications') ?? true,
      liveWorkoutStatus: prefs.getBool('${_keyPrefix}liveWorkoutStatus') ?? true,
      showScheduleProgress: prefs.getBool('${_keyPrefix}showScheduleProgress') ?? true,
      showSetProgress: prefs.getBool('${_keyPrefix}showSetProgress') ?? true,
      showRestTimerControls: prefs.getBool('${_keyPrefix}showRestTimerControls') ?? true,
      routineWorkoutReminders: prefs.getBool('${_keyPrefix}routineWorkoutReminders') ?? true,
      hydrationReminders: prefs.getBool('${_keyPrefix}hydrationReminders') ?? true,
      hydrationInterval: rawInterval,
      scheduleStatusAlerts: prefs.getBool('${_keyPrefix}scheduleStatusAlerts') ?? true,
      workoutScheduleCompletion: prefs.getBool('${_keyPrefix}workoutScheduleCompletion') ?? true,
      historyRecordedSaved: prefs.getBool('${_keyPrefix}historyRecordedSaved') ?? true,
      hapticsEnabled: prefs.getBool('${_keyPrefix}hapticsEnabled') ?? true,
      hapticAppNav: prefs.getBool('${_keyPrefix}hapticAppNav') ?? true,
      hapticWorkoutStatus: prefs.getBool('${_keyPrefix}hapticWorkoutStatus') ?? true,
      hapticSetStatus: prefs.getBool('${_keyPrefix}hapticSetStatus') ?? true,
      hapticWorkoutCompletion: prefs.getBool('${_keyPrefix}hapticWorkoutCompletion') ?? true,
      hapticTimerCountdowns: prefs.getBool('${_keyPrefix}hapticTimerCountdowns') ?? true,
      audioEnabled: prefs.getBool('${_keyPrefix}audioEnabled') ?? true,
      audioScheduleStatus: prefs.getBool('${_keyPrefix}audioScheduleStatus') ?? true,
      audioWorkoutStartFinish: prefs.getBool('${_keyPrefix}audioWorkoutStartFinish') ?? true,
      audioSetCompletion: prefs.getBool('${_keyPrefix}audioSetCompletion') ?? true,
      audioTimerCountdown: prefs.getBool('${_keyPrefix}audioTimerCountdown') ?? true,
    );
  }

  Future<void> toggleSystemNotifications(bool value) async {
    state = state.copyWith(systemNotifications: value);
    await _prefs.setBool('${_keyPrefix}systemNotifications', value);
  }

  Future<void> toggleLiveWorkoutStatus(bool value) async {
    state = state.copyWith(liveWorkoutStatus: value);
    await _prefs.setBool('${_keyPrefix}liveWorkoutStatus', value);
  }

  Future<void> toggleShowScheduleProgress(bool value) async {
    state = state.copyWith(showScheduleProgress: value);
    await _prefs.setBool('${_keyPrefix}showScheduleProgress', value);
  }

  Future<void> toggleShowSetProgress(bool value) async {
    state = state.copyWith(showSetProgress: value);
    await _prefs.setBool('${_keyPrefix}showSetProgress', value);
  }

  Future<void> toggleShowRestTimerControls(bool value) async {
    state = state.copyWith(showRestTimerControls: value);
    await _prefs.setBool('${_keyPrefix}showRestTimerControls', value);
  }

  Future<void> toggleRoutineWorkoutReminders(bool value) async {
    state = state.copyWith(routineWorkoutReminders: value);
    await _prefs.setBool('${_keyPrefix}routineWorkoutReminders', value);
  }

  Future<void> toggleHydrationReminders(bool value) async {
    state = state.copyWith(hydrationReminders: value);
    await _prefs.setBool('${_keyPrefix}hydrationReminders', value);
  }

  Future<void> setHydrationInterval(String interval) async {
    state = state.copyWith(hydrationInterval: interval);
    await _prefs.setString('${_keyPrefix}hydrationInterval', interval);
  }

  Future<void> toggleScheduleStatusAlerts(bool value) async {
    state = state.copyWith(scheduleStatusAlerts: value);
    await _prefs.setBool('${_keyPrefix}scheduleStatusAlerts', value);
  }

  Future<void> toggleWorkoutScheduleCompletion(bool value) async {
    state = state.copyWith(workoutScheduleCompletion: value);
    await _prefs.setBool('${_keyPrefix}workoutScheduleCompletion', value);
  }

  Future<void> toggleHistoryRecordedSaved(bool value) async {
    state = state.copyWith(historyRecordedSaved: value);
    await _prefs.setBool('${_keyPrefix}historyRecordedSaved', value);
  }

  Future<void> toggleHapticsEnabled(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await _prefs.setBool('${_keyPrefix}hapticsEnabled', value);
  }

  Future<void> toggleHapticAppNav(bool value) async {
    state = state.copyWith(hapticAppNav: value);
    await _prefs.setBool('${_keyPrefix}hapticAppNav', value);
  }

  Future<void> toggleHapticWorkoutStatus(bool value) async {
    state = state.copyWith(hapticWorkoutStatus: value);
    await _prefs.setBool('${_keyPrefix}hapticWorkoutStatus', value);
  }

  Future<void> toggleHapticSetStatus(bool value) async {
    state = state.copyWith(hapticSetStatus: value);
    await _prefs.setBool('${_keyPrefix}hapticSetStatus', value);
  }

  Future<void> toggleHapticWorkoutCompletion(bool value) async {
    state = state.copyWith(hapticWorkoutCompletion: value);
    await _prefs.setBool('${_keyPrefix}hapticWorkoutCompletion', value);
  }

  Future<void> toggleHapticTimerCountdowns(bool value) async {
    state = state.copyWith(hapticTimerCountdowns: value);
    await _prefs.setBool('${_keyPrefix}hapticTimerCountdowns', value);
  }

  Future<void> toggleAudioEnabled(bool value) async {
    state = state.copyWith(audioEnabled: value);
    await _prefs.setBool('${_keyPrefix}audioEnabled', value);
  }

  Future<void> toggleAudioScheduleStatus(bool value) async {
    state = state.copyWith(audioScheduleStatus: value);
    await _prefs.setBool('${_keyPrefix}audioScheduleStatus', value);
  }

  Future<void> toggleAudioWorkoutStartFinish(bool value) async {
    state = state.copyWith(audioWorkoutStartFinish: value);
    await _prefs.setBool('${_keyPrefix}audioWorkoutStartFinish', value);
  }

  Future<void> toggleAudioSetCompletion(bool value) async {
    state = state.copyWith(audioSetCompletion: value);
    await _prefs.setBool('${_keyPrefix}audioSetCompletion', value);
  }

  Future<void> toggleAudioTimerCountdown(bool value) async {
    state = state.copyWith(audioTimerCountdown: value);
    await _prefs.setBool('${_keyPrefix}audioTimerCountdown', value);
  }
}

/// Compatibility alias matching user prompt naming specification.
final notificationSettingsNotifierProvider = notificationSettingsProvider;
