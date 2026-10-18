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

    // Section 2: Live Activities & In-App Dynamic Island
    @Default(true) bool liveWorkoutStatus,
    @Default(true) bool showScheduleProgress,
    @Default(true) bool showSetProgress,
    @Default(true) bool showRestTimerControls,
    @Default(true) bool showLockScreenDetails,

    // In-app Dynamic Island Banners
    @Default(true) bool inAppBanners,
    @Default(2) int bannerDurationSeconds, // 1s, 2s, 3s
    @Default(true) bool keepLiveWorkoutPill,

    // Section 3: Standard & Device Notifications
    @Default(true) bool routineWorkoutReminders,
    @Default(['Mon', 'Wed', 'Fri']) List<String> reminderDays,
    @Default('18:30') String reminderTime,
    @Default(true) bool skipIfTrainedToday,

    @Default(true) bool hydrationReminders,
    @Default('2 hrs') String hydrationInterval,

    @Default(true) bool summariesEnabled,
    @Default(true) bool workoutScheduleCompletion,
    @Default(true) bool weeklyRecap,

    @Default(true) bool achievementsEnabled,
    @Default(true) bool prAchievements,
    @Default(false) bool streakMilestones,

    @Default(true) bool scheduleStatusAlerts,
    @Default(true) bool historyRecordedSaved,

    // Section 4: Quiet Hours
    @Default(true) bool quietHoursEnabled,
    @Default('22:00') String quietHoursFrom,
    @Default('06:30') String quietHoursTo,
    @Default(true) bool quietHoursShowLive,

    // Section 5: Haptic Feedback
    @Default(true) bool hapticsEnabled,
    @Default(true) bool hapticAppNav,
    @Default(true) bool hapticWorkoutStatus,
    @Default(true) bool hapticSetStatus,
    @Default(true) bool hapticWorkoutCompletion,
    @Default(true) bool hapticTimerCountdowns,

    // Section 6: Audio Notifications
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

  SharedPreferences? get _prefs {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  @override
  NotificationSettingsState build() {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);

      String rawInterval = prefs.getString('${_keyPrefix}hydrationInterval') ?? '2 hrs';
      if (rawInterval.startsWith('Every ')) {
        rawInterval = rawInterval.replaceFirst('Every ', '');
      }

      return NotificationSettingsState(
        systemNotifications: prefs.getBool('${_keyPrefix}systemNotifications') ?? true,
        liveWorkoutStatus: prefs.getBool('${_keyPrefix}liveWorkoutStatus') ?? true,
        showScheduleProgress: prefs.getBool('${_keyPrefix}showScheduleProgress') ?? true,
        showSetProgress: prefs.getBool('${_keyPrefix}showSetProgress') ?? true,
        showRestTimerControls: prefs.getBool('${_keyPrefix}showRestTimerControls') ?? true,
        showLockScreenDetails: prefs.getBool('${_keyPrefix}showLockScreenDetails') ?? true,
        inAppBanners: prefs.getBool('${_keyPrefix}inAppBanners') ?? true,
        bannerDurationSeconds: prefs.getInt('${_keyPrefix}bannerDurationSeconds') ?? 2,
        keepLiveWorkoutPill: prefs.getBool('${_keyPrefix}keepLiveWorkoutPill') ?? true,
        routineWorkoutReminders: prefs.getBool('${_keyPrefix}routineWorkoutReminders') ?? true,
        reminderDays: prefs.getStringList('${_keyPrefix}reminderDays') ?? const ['Mon', 'Wed', 'Fri'],
        reminderTime: prefs.getString('${_keyPrefix}reminderTime') ?? '18:30',
        skipIfTrainedToday: prefs.getBool('${_keyPrefix}skipIfTrainedToday') ?? true,
        hydrationReminders: prefs.getBool('${_keyPrefix}hydrationReminders') ?? true,
        hydrationInterval: rawInterval,
        summariesEnabled: prefs.getBool('${_keyPrefix}summariesEnabled') ?? true,
        workoutScheduleCompletion: prefs.getBool('${_keyPrefix}workoutScheduleCompletion') ?? true,
        weeklyRecap: prefs.getBool('${_keyPrefix}weeklyRecap') ?? true,
        achievementsEnabled: prefs.getBool('${_keyPrefix}achievementsEnabled') ?? true,
        prAchievements: prefs.getBool('${_keyPrefix}prAchievements') ?? true,
        streakMilestones: prefs.getBool('${_keyPrefix}streakMilestones') ?? false,
        scheduleStatusAlerts: prefs.getBool('${_keyPrefix}scheduleStatusAlerts') ?? true,
        historyRecordedSaved: prefs.getBool('${_keyPrefix}historyRecordedSaved') ?? true,
        quietHoursEnabled: prefs.getBool('${_keyPrefix}quietHoursEnabled') ?? true,
        quietHoursFrom: prefs.getString('${_keyPrefix}quietHoursFrom') ?? '22:00',
        quietHoursTo: prefs.getString('${_keyPrefix}quietHoursTo') ?? '06:30',
        quietHoursShowLive: prefs.getBool('${_keyPrefix}quietHoursShowLive') ?? true,
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
    } catch (_) {
      return const NotificationSettingsState();
    }
  }

  Future<void> toggleSystemNotifications(bool value) async {
    state = state.copyWith(systemNotifications: value);
    await _prefs?.setBool('${_keyPrefix}systemNotifications', value);
  }

  Future<void> toggleLiveWorkoutStatus(bool value) async {
    state = state.copyWith(liveWorkoutStatus: value);
    await _prefs?.setBool('${_keyPrefix}liveWorkoutStatus', value);
  }

  Future<void> toggleShowScheduleProgress(bool value) async {
    state = state.copyWith(showScheduleProgress: value);
    await _prefs?.setBool('${_keyPrefix}showScheduleProgress', value);
  }

  Future<void> toggleShowSetProgress(bool value) async {
    state = state.copyWith(showSetProgress: value);
    await _prefs?.setBool('${_keyPrefix}showSetProgress', value);
  }

  Future<void> toggleShowRestTimerControls(bool value) async {
    state = state.copyWith(showRestTimerControls: value);
    await _prefs?.setBool('${_keyPrefix}showRestTimerControls', value);
  }

  Future<void> toggleShowLockScreenDetails(bool value) async {
    state = state.copyWith(showLockScreenDetails: value);
    await _prefs?.setBool('${_keyPrefix}showLockScreenDetails', value);
  }

  Future<void> toggleInAppBanners(bool value) async {
    state = state.copyWith(inAppBanners: value);
    await _prefs?.setBool('${_keyPrefix}inAppBanners', value);
  }

  Future<void> setBannerDurationSeconds(int seconds) async {
    state = state.copyWith(bannerDurationSeconds: seconds);
    await _prefs?.setInt('${_keyPrefix}bannerDurationSeconds', seconds);
  }

  Future<void> toggleKeepLiveWorkoutPill(bool value) async {
    state = state.copyWith(keepLiveWorkoutPill: value);
    await _prefs?.setBool('${_keyPrefix}keepLiveWorkoutPill', value);
  }

  Future<void> toggleRoutineWorkoutReminders(bool value) async {
    state = state.copyWith(routineWorkoutReminders: value);
    await _prefs?.setBool('${_keyPrefix}routineWorkoutReminders', value);
  }

  Future<void> toggleReminderDay(String day) async {
    final days = List<String>.from(state.reminderDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    state = state.copyWith(reminderDays: days);
    await _prefs?.setStringList('${_keyPrefix}reminderDays', days);
  }

  Future<void> setReminderTime(String time) async {
    state = state.copyWith(reminderTime: time);
    await _prefs?.setString('${_keyPrefix}reminderTime', time);
  }

  Future<void> toggleSkipIfTrainedToday(bool value) async {
    state = state.copyWith(skipIfTrainedToday: value);
    await _prefs?.setBool('${_keyPrefix}skipIfTrainedToday', value);
  }

  Future<void> toggleHydrationReminders(bool value) async {
    state = state.copyWith(hydrationReminders: value);
    await _prefs?.setBool('${_keyPrefix}hydrationReminders', value);
  }

  Future<void> setHydrationInterval(String interval) async {
    state = state.copyWith(hydrationInterval: interval);
    await _prefs?.setString('${_keyPrefix}hydrationInterval', interval);
  }

  Future<void> toggleSummariesEnabled(bool value) async {
    state = state.copyWith(summariesEnabled: value);
    await _prefs?.setBool('${_keyPrefix}summariesEnabled', value);
  }

  Future<void> toggleWorkoutScheduleCompletion(bool value) async {
    state = state.copyWith(workoutScheduleCompletion: value);
    await _prefs?.setBool('${_keyPrefix}workoutScheduleCompletion', value);
  }

  Future<void> toggleWeeklyRecap(bool value) async {
    state = state.copyWith(weeklyRecap: value);
    await _prefs?.setBool('${_keyPrefix}weeklyRecap', value);
  }

  Future<void> toggleAchievementsEnabled(bool value) async {
    state = state.copyWith(achievementsEnabled: value);
    await _prefs?.setBool('${_keyPrefix}achievementsEnabled', value);
  }

  Future<void> togglePrAchievements(bool value) async {
    state = state.copyWith(prAchievements: value);
    await _prefs?.setBool('${_keyPrefix}prAchievements', value);
  }

  Future<void> toggleStreakMilestones(bool value) async {
    state = state.copyWith(streakMilestones: value);
    await _prefs?.setBool('${_keyPrefix}streakMilestones', value);
  }

  Future<void> toggleScheduleStatusAlerts(bool value) async {
    state = state.copyWith(scheduleStatusAlerts: value);
    await _prefs?.setBool('${_keyPrefix}scheduleStatusAlerts', value);
  }

  Future<void> toggleHistoryRecordedSaved(bool value) async {
    state = state.copyWith(historyRecordedSaved: value);
    await _prefs?.setBool('${_keyPrefix}historyRecordedSaved', value);
  }

  Future<void> toggleQuietHoursEnabled(bool value) async {
    state = state.copyWith(quietHoursEnabled: value);
    await _prefs?.setBool('${_keyPrefix}quietHoursEnabled', value);
  }

  Future<void> setQuietHoursRange(String from, String to) async {
    state = state.copyWith(quietHoursFrom: from, quietHoursTo: to);
    await _prefs?.setString('${_keyPrefix}quietHoursFrom', from);
    await _prefs?.setString('${_keyPrefix}quietHoursTo', to);
  }

  Future<void> toggleQuietHoursShowLive(bool value) async {
    state = state.copyWith(quietHoursShowLive: value);
    await _prefs?.setBool('${_keyPrefix}quietHoursShowLive', value);
  }

  Future<void> toggleHapticsEnabled(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await _prefs?.setBool('${_keyPrefix}hapticsEnabled', value);
  }

  Future<void> toggleHapticAppNav(bool value) async {
    state = state.copyWith(hapticAppNav: value);
    await _prefs?.setBool('${_keyPrefix}hapticAppNav', value);
  }

  Future<void> toggleHapticWorkoutStatus(bool value) async {
    state = state.copyWith(hapticWorkoutStatus: value);
    await _prefs?.setBool('${_keyPrefix}hapticWorkoutStatus', value);
  }

  Future<void> toggleHapticSetStatus(bool value) async {
    state = state.copyWith(hapticSetStatus: value);
    await _prefs?.setBool('${_keyPrefix}hapticSetStatus', value);
  }

  Future<void> toggleHapticWorkoutCompletion(bool value) async {
    state = state.copyWith(hapticWorkoutCompletion: value);
    await _prefs?.setBool('${_keyPrefix}hapticWorkoutCompletion', value);
  }

  Future<void> toggleHapticTimerCountdowns(bool value) async {
    state = state.copyWith(hapticTimerCountdowns: value);
    await _prefs?.setBool('${_keyPrefix}hapticTimerCountdowns', value);
  }

  Future<void> toggleAudioEnabled(bool value) async {
    state = state.copyWith(audioEnabled: value);
    await _prefs?.setBool('${_keyPrefix}audioEnabled', value);
  }

  Future<void> toggleAudioScheduleStatus(bool value) async {
    state = state.copyWith(audioScheduleStatus: value);
    await _prefs?.setBool('${_keyPrefix}audioScheduleStatus', value);
  }

  Future<void> toggleAudioWorkoutStartFinish(bool value) async {
    state = state.copyWith(audioWorkoutStartFinish: value);
    await _prefs?.setBool('${_keyPrefix}audioWorkoutStartFinish', value);
  }

  Future<void> toggleAudioSetCompletion(bool value) async {
    state = state.copyWith(audioSetCompletion: value);
    await _prefs?.setBool('${_keyPrefix}audioSetCompletion', value);
  }

  Future<void> toggleAudioTimerCountdown(bool value) async {
    state = state.copyWith(audioTimerCountdown: value);
    await _prefs?.setBool('${_keyPrefix}audioTimerCountdown', value);
  }
}

/// Compatibility alias matching user prompt naming specification.
final notificationSettingsNotifierProvider = notificationSettingsProvider;
