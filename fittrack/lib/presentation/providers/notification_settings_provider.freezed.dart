// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationSettingsState {

 bool get systemNotifications; bool get liveWorkoutStatus; bool get showScheduleProgress; bool get showSetProgress; bool get showRestTimerControls; bool get showLockScreenDetails; bool get allowCompleteSetFromNotification; bool get inAppBanners; int get bannerDurationSeconds; bool get keepLiveWorkoutPill; bool get routineWorkoutReminders; List<String> get reminderDays; String get reminderTime; bool get skipIfTrainedToday; bool get hydrationReminders; String get hydrationInterval; bool get summariesEnabled; bool get workoutScheduleCompletion; bool get weeklyRecap; bool get achievementsEnabled; bool get prAchievements; bool get streakMilestones; bool get scheduleStatusAlerts; bool get historyRecordedSaved; bool get quietHoursEnabled; String get quietHoursFrom; String get quietHoursTo; bool get quietHoursShowLive; bool get hapticsEnabled; bool get hapticAppNav; bool get hapticWorkoutStatus; bool get hapticSetStatus; bool get hapticWorkoutCompletion; bool get hapticTimerCountdowns; bool get audioEnabled; bool get audioScheduleStatus; bool get audioWorkoutStartFinish; bool get audioSetCompletion; bool get audioTimerCountdown;
/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsStateCopyWith<NotificationSettingsState> get copyWith => _$NotificationSettingsStateCopyWithImpl<NotificationSettingsState>(this as NotificationSettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationSettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsState&&(identical(other.systemNotifications, _this.systemNotifications) || other.systemNotifications == _this.systemNotifications)&&(identical(other.liveWorkoutStatus, _this.liveWorkoutStatus) || other.liveWorkoutStatus == _this.liveWorkoutStatus)&&(identical(other.showScheduleProgress, _this.showScheduleProgress) || other.showScheduleProgress == _this.showScheduleProgress)&&(identical(other.showSetProgress, _this.showSetProgress) || other.showSetProgress == _this.showSetProgress)&&(identical(other.showRestTimerControls, _this.showRestTimerControls) || other.showRestTimerControls == _this.showRestTimerControls)&&(identical(other.showLockScreenDetails, _this.showLockScreenDetails) || other.showLockScreenDetails == _this.showLockScreenDetails)&&(identical(other.allowCompleteSetFromNotification, _this.allowCompleteSetFromNotification) || other.allowCompleteSetFromNotification == _this.allowCompleteSetFromNotification)&&(identical(other.inAppBanners, _this.inAppBanners) || other.inAppBanners == _this.inAppBanners)&&(identical(other.bannerDurationSeconds, _this.bannerDurationSeconds) || other.bannerDurationSeconds == _this.bannerDurationSeconds)&&(identical(other.keepLiveWorkoutPill, _this.keepLiveWorkoutPill) || other.keepLiveWorkoutPill == _this.keepLiveWorkoutPill)&&(identical(other.routineWorkoutReminders, _this.routineWorkoutReminders) || other.routineWorkoutReminders == _this.routineWorkoutReminders)&&const DeepCollectionEquality().equals(other.reminderDays, _this.reminderDays)&&(identical(other.reminderTime, _this.reminderTime) || other.reminderTime == _this.reminderTime)&&(identical(other.skipIfTrainedToday, _this.skipIfTrainedToday) || other.skipIfTrainedToday == _this.skipIfTrainedToday)&&(identical(other.hydrationReminders, _this.hydrationReminders) || other.hydrationReminders == _this.hydrationReminders)&&(identical(other.hydrationInterval, _this.hydrationInterval) || other.hydrationInterval == _this.hydrationInterval)&&(identical(other.summariesEnabled, _this.summariesEnabled) || other.summariesEnabled == _this.summariesEnabled)&&(identical(other.workoutScheduleCompletion, _this.workoutScheduleCompletion) || other.workoutScheduleCompletion == _this.workoutScheduleCompletion)&&(identical(other.weeklyRecap, _this.weeklyRecap) || other.weeklyRecap == _this.weeklyRecap)&&(identical(other.achievementsEnabled, _this.achievementsEnabled) || other.achievementsEnabled == _this.achievementsEnabled)&&(identical(other.prAchievements, _this.prAchievements) || other.prAchievements == _this.prAchievements)&&(identical(other.streakMilestones, _this.streakMilestones) || other.streakMilestones == _this.streakMilestones)&&(identical(other.scheduleStatusAlerts, _this.scheduleStatusAlerts) || other.scheduleStatusAlerts == _this.scheduleStatusAlerts)&&(identical(other.historyRecordedSaved, _this.historyRecordedSaved) || other.historyRecordedSaved == _this.historyRecordedSaved)&&(identical(other.quietHoursEnabled, _this.quietHoursEnabled) || other.quietHoursEnabled == _this.quietHoursEnabled)&&(identical(other.quietHoursFrom, _this.quietHoursFrom) || other.quietHoursFrom == _this.quietHoursFrom)&&(identical(other.quietHoursTo, _this.quietHoursTo) || other.quietHoursTo == _this.quietHoursTo)&&(identical(other.quietHoursShowLive, _this.quietHoursShowLive) || other.quietHoursShowLive == _this.quietHoursShowLive)&&(identical(other.hapticsEnabled, _this.hapticsEnabled) || other.hapticsEnabled == _this.hapticsEnabled)&&(identical(other.hapticAppNav, _this.hapticAppNav) || other.hapticAppNav == _this.hapticAppNav)&&(identical(other.hapticWorkoutStatus, _this.hapticWorkoutStatus) || other.hapticWorkoutStatus == _this.hapticWorkoutStatus)&&(identical(other.hapticSetStatus, _this.hapticSetStatus) || other.hapticSetStatus == _this.hapticSetStatus)&&(identical(other.hapticWorkoutCompletion, _this.hapticWorkoutCompletion) || other.hapticWorkoutCompletion == _this.hapticWorkoutCompletion)&&(identical(other.hapticTimerCountdowns, _this.hapticTimerCountdowns) || other.hapticTimerCountdowns == _this.hapticTimerCountdowns)&&(identical(other.audioEnabled, _this.audioEnabled) || other.audioEnabled == _this.audioEnabled)&&(identical(other.audioScheduleStatus, _this.audioScheduleStatus) || other.audioScheduleStatus == _this.audioScheduleStatus)&&(identical(other.audioWorkoutStartFinish, _this.audioWorkoutStartFinish) || other.audioWorkoutStartFinish == _this.audioWorkoutStartFinish)&&(identical(other.audioSetCompletion, _this.audioSetCompletion) || other.audioSetCompletion == _this.audioSetCompletion)&&(identical(other.audioTimerCountdown, _this.audioTimerCountdown) || other.audioTimerCountdown == _this.audioTimerCountdown));
}


@override
int get hashCode {
  final _this = this as NotificationSettingsState;
  return Object.hashAll([runtimeType,_this.systemNotifications,_this.liveWorkoutStatus,_this.showScheduleProgress,_this.showSetProgress,_this.showRestTimerControls,_this.showLockScreenDetails,_this.allowCompleteSetFromNotification,_this.inAppBanners,_this.bannerDurationSeconds,_this.keepLiveWorkoutPill,_this.routineWorkoutReminders,const DeepCollectionEquality().hash(_this.reminderDays),_this.reminderTime,_this.skipIfTrainedToday,_this.hydrationReminders,_this.hydrationInterval,_this.summariesEnabled,_this.workoutScheduleCompletion,_this.weeklyRecap,_this.achievementsEnabled,_this.prAchievements,_this.streakMilestones,_this.scheduleStatusAlerts,_this.historyRecordedSaved,_this.quietHoursEnabled,_this.quietHoursFrom,_this.quietHoursTo,_this.quietHoursShowLive,_this.hapticsEnabled,_this.hapticAppNav,_this.hapticWorkoutStatus,_this.hapticSetStatus,_this.hapticWorkoutCompletion,_this.hapticTimerCountdowns,_this.audioEnabled,_this.audioScheduleStatus,_this.audioWorkoutStartFinish,_this.audioSetCompletion,_this.audioTimerCountdown]);
}

@override
String toString() {
  final _this = this as NotificationSettingsState;
  return 'NotificationSettingsState(systemNotifications: ${_this.systemNotifications}, liveWorkoutStatus: ${_this.liveWorkoutStatus}, showScheduleProgress: ${_this.showScheduleProgress}, showSetProgress: ${_this.showSetProgress}, showRestTimerControls: ${_this.showRestTimerControls}, showLockScreenDetails: ${_this.showLockScreenDetails}, allowCompleteSetFromNotification: ${_this.allowCompleteSetFromNotification}, inAppBanners: ${_this.inAppBanners}, bannerDurationSeconds: ${_this.bannerDurationSeconds}, keepLiveWorkoutPill: ${_this.keepLiveWorkoutPill}, routineWorkoutReminders: ${_this.routineWorkoutReminders}, reminderDays: ${_this.reminderDays}, reminderTime: ${_this.reminderTime}, skipIfTrainedToday: ${_this.skipIfTrainedToday}, hydrationReminders: ${_this.hydrationReminders}, hydrationInterval: ${_this.hydrationInterval}, summariesEnabled: ${_this.summariesEnabled}, workoutScheduleCompletion: ${_this.workoutScheduleCompletion}, weeklyRecap: ${_this.weeklyRecap}, achievementsEnabled: ${_this.achievementsEnabled}, prAchievements: ${_this.prAchievements}, streakMilestones: ${_this.streakMilestones}, scheduleStatusAlerts: ${_this.scheduleStatusAlerts}, historyRecordedSaved: ${_this.historyRecordedSaved}, quietHoursEnabled: ${_this.quietHoursEnabled}, quietHoursFrom: ${_this.quietHoursFrom}, quietHoursTo: ${_this.quietHoursTo}, quietHoursShowLive: ${_this.quietHoursShowLive}, hapticsEnabled: ${_this.hapticsEnabled}, hapticAppNav: ${_this.hapticAppNav}, hapticWorkoutStatus: ${_this.hapticWorkoutStatus}, hapticSetStatus: ${_this.hapticSetStatus}, hapticWorkoutCompletion: ${_this.hapticWorkoutCompletion}, hapticTimerCountdowns: ${_this.hapticTimerCountdowns}, audioEnabled: ${_this.audioEnabled}, audioScheduleStatus: ${_this.audioScheduleStatus}, audioWorkoutStartFinish: ${_this.audioWorkoutStartFinish}, audioSetCompletion: ${_this.audioSetCompletion}, audioTimerCountdown: ${_this.audioTimerCountdown})';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsStateCopyWith<$Res>  {
  factory $NotificationSettingsStateCopyWith(NotificationSettingsState value, $Res Function(NotificationSettingsState) _then) = _$NotificationSettingsStateCopyWithImpl;
@useResult
$Res call({
 bool systemNotifications, bool liveWorkoutStatus, bool showScheduleProgress, bool showSetProgress, bool showRestTimerControls, bool showLockScreenDetails, bool allowCompleteSetFromNotification, bool inAppBanners, int bannerDurationSeconds, bool keepLiveWorkoutPill, bool routineWorkoutReminders, List<String> reminderDays, String reminderTime, bool skipIfTrainedToday, bool hydrationReminders, String hydrationInterval, bool summariesEnabled, bool workoutScheduleCompletion, bool weeklyRecap, bool achievementsEnabled, bool prAchievements, bool streakMilestones, bool scheduleStatusAlerts, bool historyRecordedSaved, bool quietHoursEnabled, String quietHoursFrom, String quietHoursTo, bool quietHoursShowLive, bool hapticsEnabled, bool hapticAppNav, bool hapticWorkoutStatus, bool hapticSetStatus, bool hapticWorkoutCompletion, bool hapticTimerCountdowns, bool audioEnabled, bool audioScheduleStatus, bool audioWorkoutStartFinish, bool audioSetCompletion, bool audioTimerCountdown
});




}
/// @nodoc
class _$NotificationSettingsStateCopyWithImpl<$Res>
    implements $NotificationSettingsStateCopyWith<$Res> {
  _$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final NotificationSettingsState _self;
  final $Res Function(NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemNotifications = null,Object? liveWorkoutStatus = null,Object? showScheduleProgress = null,Object? showSetProgress = null,Object? showRestTimerControls = null,Object? showLockScreenDetails = null,Object? allowCompleteSetFromNotification = null,Object? inAppBanners = null,Object? bannerDurationSeconds = null,Object? keepLiveWorkoutPill = null,Object? routineWorkoutReminders = null,Object? reminderDays = null,Object? reminderTime = null,Object? skipIfTrainedToday = null,Object? hydrationReminders = null,Object? hydrationInterval = null,Object? summariesEnabled = null,Object? workoutScheduleCompletion = null,Object? weeklyRecap = null,Object? achievementsEnabled = null,Object? prAchievements = null,Object? streakMilestones = null,Object? scheduleStatusAlerts = null,Object? historyRecordedSaved = null,Object? quietHoursEnabled = null,Object? quietHoursFrom = null,Object? quietHoursTo = null,Object? quietHoursShowLive = null,Object? hapticsEnabled = null,Object? hapticAppNav = null,Object? hapticWorkoutStatus = null,Object? hapticSetStatus = null,Object? hapticWorkoutCompletion = null,Object? hapticTimerCountdowns = null,Object? audioEnabled = null,Object? audioScheduleStatus = null,Object? audioWorkoutStartFinish = null,Object? audioSetCompletion = null,Object? audioTimerCountdown = null,}) {
  return _then(NotificationSettingsState(
systemNotifications: null == systemNotifications ? _self.systemNotifications : systemNotifications // ignore: cast_nullable_to_non_nullable
as bool,liveWorkoutStatus: null == liveWorkoutStatus ? _self.liveWorkoutStatus : liveWorkoutStatus // ignore: cast_nullable_to_non_nullable
as bool,showScheduleProgress: null == showScheduleProgress ? _self.showScheduleProgress : showScheduleProgress // ignore: cast_nullable_to_non_nullable
as bool,showSetProgress: null == showSetProgress ? _self.showSetProgress : showSetProgress // ignore: cast_nullable_to_non_nullable
as bool,showRestTimerControls: null == showRestTimerControls ? _self.showRestTimerControls : showRestTimerControls // ignore: cast_nullable_to_non_nullable
as bool,showLockScreenDetails: null == showLockScreenDetails ? _self.showLockScreenDetails : showLockScreenDetails // ignore: cast_nullable_to_non_nullable
as bool,allowCompleteSetFromNotification: null == allowCompleteSetFromNotification ? _self.allowCompleteSetFromNotification : allowCompleteSetFromNotification // ignore: cast_nullable_to_non_nullable
as bool,inAppBanners: null == inAppBanners ? _self.inAppBanners : inAppBanners // ignore: cast_nullable_to_non_nullable
as bool,bannerDurationSeconds: null == bannerDurationSeconds ? _self.bannerDurationSeconds : bannerDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,keepLiveWorkoutPill: null == keepLiveWorkoutPill ? _self.keepLiveWorkoutPill : keepLiveWorkoutPill // ignore: cast_nullable_to_non_nullable
as bool,routineWorkoutReminders: null == routineWorkoutReminders ? _self.routineWorkoutReminders : routineWorkoutReminders // ignore: cast_nullable_to_non_nullable
as bool,reminderDays: null == reminderDays ? _self.reminderDays : reminderDays // ignore: cast_nullable_to_non_nullable
as List<String>,reminderTime: null == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String,skipIfTrainedToday: null == skipIfTrainedToday ? _self.skipIfTrainedToday : skipIfTrainedToday // ignore: cast_nullable_to_non_nullable
as bool,hydrationReminders: null == hydrationReminders ? _self.hydrationReminders : hydrationReminders // ignore: cast_nullable_to_non_nullable
as bool,hydrationInterval: null == hydrationInterval ? _self.hydrationInterval : hydrationInterval // ignore: cast_nullable_to_non_nullable
as String,summariesEnabled: null == summariesEnabled ? _self.summariesEnabled : summariesEnabled // ignore: cast_nullable_to_non_nullable
as bool,workoutScheduleCompletion: null == workoutScheduleCompletion ? _self.workoutScheduleCompletion : workoutScheduleCompletion // ignore: cast_nullable_to_non_nullable
as bool,weeklyRecap: null == weeklyRecap ? _self.weeklyRecap : weeklyRecap // ignore: cast_nullable_to_non_nullable
as bool,achievementsEnabled: null == achievementsEnabled ? _self.achievementsEnabled : achievementsEnabled // ignore: cast_nullable_to_non_nullable
as bool,prAchievements: null == prAchievements ? _self.prAchievements : prAchievements // ignore: cast_nullable_to_non_nullable
as bool,streakMilestones: null == streakMilestones ? _self.streakMilestones : streakMilestones // ignore: cast_nullable_to_non_nullable
as bool,scheduleStatusAlerts: null == scheduleStatusAlerts ? _self.scheduleStatusAlerts : scheduleStatusAlerts // ignore: cast_nullable_to_non_nullable
as bool,historyRecordedSaved: null == historyRecordedSaved ? _self.historyRecordedSaved : historyRecordedSaved // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursFrom: null == quietHoursFrom ? _self.quietHoursFrom : quietHoursFrom // ignore: cast_nullable_to_non_nullable
as String,quietHoursTo: null == quietHoursTo ? _self.quietHoursTo : quietHoursTo // ignore: cast_nullable_to_non_nullable
as String,quietHoursShowLive: null == quietHoursShowLive ? _self.quietHoursShowLive : quietHoursShowLive // ignore: cast_nullable_to_non_nullable
as bool,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,hapticAppNav: null == hapticAppNav ? _self.hapticAppNav : hapticAppNav // ignore: cast_nullable_to_non_nullable
as bool,hapticWorkoutStatus: null == hapticWorkoutStatus ? _self.hapticWorkoutStatus : hapticWorkoutStatus // ignore: cast_nullable_to_non_nullable
as bool,hapticSetStatus: null == hapticSetStatus ? _self.hapticSetStatus : hapticSetStatus // ignore: cast_nullable_to_non_nullable
as bool,hapticWorkoutCompletion: null == hapticWorkoutCompletion ? _self.hapticWorkoutCompletion : hapticWorkoutCompletion // ignore: cast_nullable_to_non_nullable
as bool,hapticTimerCountdowns: null == hapticTimerCountdowns ? _self.hapticTimerCountdowns : hapticTimerCountdowns // ignore: cast_nullable_to_non_nullable
as bool,audioEnabled: null == audioEnabled ? _self.audioEnabled : audioEnabled // ignore: cast_nullable_to_non_nullable
as bool,audioScheduleStatus: null == audioScheduleStatus ? _self.audioScheduleStatus : audioScheduleStatus // ignore: cast_nullable_to_non_nullable
as bool,audioWorkoutStartFinish: null == audioWorkoutStartFinish ? _self.audioWorkoutStartFinish : audioWorkoutStartFinish // ignore: cast_nullable_to_non_nullable
as bool,audioSetCompletion: null == audioSetCompletion ? _self.audioSetCompletion : audioSetCompletion // ignore: cast_nullable_to_non_nullable
as bool,audioTimerCountdown: null == audioTimerCountdown ? _self.audioTimerCountdown : audioTimerCountdown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsState].
extension NotificationSettingsStatePatterns on NotificationSettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemNotifications,  bool liveWorkoutStatus,  bool showScheduleProgress,  bool showSetProgress,  bool showRestTimerControls,  bool showLockScreenDetails,  bool allowCompleteSetFromNotification,  bool inAppBanners,  int bannerDurationSeconds,  bool keepLiveWorkoutPill,  bool routineWorkoutReminders,  List<String> reminderDays,  String reminderTime,  bool skipIfTrainedToday,  bool hydrationReminders,  String hydrationInterval,  bool summariesEnabled,  bool workoutScheduleCompletion,  bool weeklyRecap,  bool achievementsEnabled,  bool prAchievements,  bool streakMilestones,  bool scheduleStatusAlerts,  bool historyRecordedSaved,  bool quietHoursEnabled,  String quietHoursFrom,  String quietHoursTo,  bool quietHoursShowLive,  bool hapticsEnabled,  bool hapticAppNav,  bool hapticWorkoutStatus,  bool hapticSetStatus,  bool hapticWorkoutCompletion,  bool hapticTimerCountdowns,  bool audioEnabled,  bool audioScheduleStatus,  bool audioWorkoutStartFinish,  bool audioSetCompletion,  bool audioTimerCountdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.systemNotifications,_that.liveWorkoutStatus,_that.showScheduleProgress,_that.showSetProgress,_that.showRestTimerControls,_that.showLockScreenDetails,_that.allowCompleteSetFromNotification,_that.inAppBanners,_that.bannerDurationSeconds,_that.keepLiveWorkoutPill,_that.routineWorkoutReminders,_that.reminderDays,_that.reminderTime,_that.skipIfTrainedToday,_that.hydrationReminders,_that.hydrationInterval,_that.summariesEnabled,_that.workoutScheduleCompletion,_that.weeklyRecap,_that.achievementsEnabled,_that.prAchievements,_that.streakMilestones,_that.scheduleStatusAlerts,_that.historyRecordedSaved,_that.quietHoursEnabled,_that.quietHoursFrom,_that.quietHoursTo,_that.quietHoursShowLive,_that.hapticsEnabled,_that.hapticAppNav,_that.hapticWorkoutStatus,_that.hapticSetStatus,_that.hapticWorkoutCompletion,_that.hapticTimerCountdowns,_that.audioEnabled,_that.audioScheduleStatus,_that.audioWorkoutStartFinish,_that.audioSetCompletion,_that.audioTimerCountdown);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemNotifications,  bool liveWorkoutStatus,  bool showScheduleProgress,  bool showSetProgress,  bool showRestTimerControls,  bool showLockScreenDetails,  bool allowCompleteSetFromNotification,  bool inAppBanners,  int bannerDurationSeconds,  bool keepLiveWorkoutPill,  bool routineWorkoutReminders,  List<String> reminderDays,  String reminderTime,  bool skipIfTrainedToday,  bool hydrationReminders,  String hydrationInterval,  bool summariesEnabled,  bool workoutScheduleCompletion,  bool weeklyRecap,  bool achievementsEnabled,  bool prAchievements,  bool streakMilestones,  bool scheduleStatusAlerts,  bool historyRecordedSaved,  bool quietHoursEnabled,  String quietHoursFrom,  String quietHoursTo,  bool quietHoursShowLive,  bool hapticsEnabled,  bool hapticAppNav,  bool hapticWorkoutStatus,  bool hapticSetStatus,  bool hapticWorkoutCompletion,  bool hapticTimerCountdowns,  bool audioEnabled,  bool audioScheduleStatus,  bool audioWorkoutStartFinish,  bool audioSetCompletion,  bool audioTimerCountdown)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState():
return $default(_that.systemNotifications,_that.liveWorkoutStatus,_that.showScheduleProgress,_that.showSetProgress,_that.showRestTimerControls,_that.showLockScreenDetails,_that.allowCompleteSetFromNotification,_that.inAppBanners,_that.bannerDurationSeconds,_that.keepLiveWorkoutPill,_that.routineWorkoutReminders,_that.reminderDays,_that.reminderTime,_that.skipIfTrainedToday,_that.hydrationReminders,_that.hydrationInterval,_that.summariesEnabled,_that.workoutScheduleCompletion,_that.weeklyRecap,_that.achievementsEnabled,_that.prAchievements,_that.streakMilestones,_that.scheduleStatusAlerts,_that.historyRecordedSaved,_that.quietHoursEnabled,_that.quietHoursFrom,_that.quietHoursTo,_that.quietHoursShowLive,_that.hapticsEnabled,_that.hapticAppNav,_that.hapticWorkoutStatus,_that.hapticSetStatus,_that.hapticWorkoutCompletion,_that.hapticTimerCountdowns,_that.audioEnabled,_that.audioScheduleStatus,_that.audioWorkoutStartFinish,_that.audioSetCompletion,_that.audioTimerCountdown);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemNotifications,  bool liveWorkoutStatus,  bool showScheduleProgress,  bool showSetProgress,  bool showRestTimerControls,  bool showLockScreenDetails,  bool allowCompleteSetFromNotification,  bool inAppBanners,  int bannerDurationSeconds,  bool keepLiveWorkoutPill,  bool routineWorkoutReminders,  List<String> reminderDays,  String reminderTime,  bool skipIfTrainedToday,  bool hydrationReminders,  String hydrationInterval,  bool summariesEnabled,  bool workoutScheduleCompletion,  bool weeklyRecap,  bool achievementsEnabled,  bool prAchievements,  bool streakMilestones,  bool scheduleStatusAlerts,  bool historyRecordedSaved,  bool quietHoursEnabled,  String quietHoursFrom,  String quietHoursTo,  bool quietHoursShowLive,  bool hapticsEnabled,  bool hapticAppNav,  bool hapticWorkoutStatus,  bool hapticSetStatus,  bool hapticWorkoutCompletion,  bool hapticTimerCountdowns,  bool audioEnabled,  bool audioScheduleStatus,  bool audioWorkoutStartFinish,  bool audioSetCompletion,  bool audioTimerCountdown)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.systemNotifications,_that.liveWorkoutStatus,_that.showScheduleProgress,_that.showSetProgress,_that.showRestTimerControls,_that.showLockScreenDetails,_that.allowCompleteSetFromNotification,_that.inAppBanners,_that.bannerDurationSeconds,_that.keepLiveWorkoutPill,_that.routineWorkoutReminders,_that.reminderDays,_that.reminderTime,_that.skipIfTrainedToday,_that.hydrationReminders,_that.hydrationInterval,_that.summariesEnabled,_that.workoutScheduleCompletion,_that.weeklyRecap,_that.achievementsEnabled,_that.prAchievements,_that.streakMilestones,_that.scheduleStatusAlerts,_that.historyRecordedSaved,_that.quietHoursEnabled,_that.quietHoursFrom,_that.quietHoursTo,_that.quietHoursShowLive,_that.hapticsEnabled,_that.hapticAppNav,_that.hapticWorkoutStatus,_that.hapticSetStatus,_that.hapticWorkoutCompletion,_that.hapticTimerCountdowns,_that.audioEnabled,_that.audioScheduleStatus,_that.audioWorkoutStartFinish,_that.audioSetCompletion,_that.audioTimerCountdown);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationSettingsState implements NotificationSettingsState {
  const _NotificationSettingsState({this.systemNotifications = true, this.liveWorkoutStatus = true, this.showScheduleProgress = true, this.showSetProgress = true, this.showRestTimerControls = true, this.showLockScreenDetails = true, this.allowCompleteSetFromNotification = false, this.inAppBanners = true, this.bannerDurationSeconds = 2, this.keepLiveWorkoutPill = true, this.routineWorkoutReminders = true,  List<String> reminderDays = const ['Mon', 'Wed', 'Fri'], this.reminderTime = '18:30', this.skipIfTrainedToday = true, this.hydrationReminders = true, this.hydrationInterval = '2 hrs', this.summariesEnabled = true, this.workoutScheduleCompletion = true, this.weeklyRecap = true, this.achievementsEnabled = true, this.prAchievements = true, this.streakMilestones = false, this.scheduleStatusAlerts = true, this.historyRecordedSaved = true, this.quietHoursEnabled = true, this.quietHoursFrom = '22:00', this.quietHoursTo = '06:30', this.quietHoursShowLive = true, this.hapticsEnabled = true, this.hapticAppNav = true, this.hapticWorkoutStatus = true, this.hapticSetStatus = true, this.hapticWorkoutCompletion = true, this.hapticTimerCountdowns = true, this.audioEnabled = true, this.audioScheduleStatus = true, this.audioWorkoutStartFinish = true, this.audioSetCompletion = true, this.audioTimerCountdown = true}): _reminderDays = reminderDays;
  

@override@JsonKey() final  bool systemNotifications;
@override@JsonKey() final  bool liveWorkoutStatus;
@override@JsonKey() final  bool showScheduleProgress;
@override@JsonKey() final  bool showSetProgress;
@override@JsonKey() final  bool showRestTimerControls;
@override@JsonKey() final  bool showLockScreenDetails;
@override@JsonKey() final  bool allowCompleteSetFromNotification;
@override@JsonKey() final  bool inAppBanners;
@override@JsonKey() final  int bannerDurationSeconds;
@override@JsonKey() final  bool keepLiveWorkoutPill;
@override@JsonKey() final  bool routineWorkoutReminders;
 final  List<String> _reminderDays;
@override@JsonKey() List<String> get reminderDays {
  if (_reminderDays is EqualUnmodifiableListView) return _reminderDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderDays);
}

@override@JsonKey() final  String reminderTime;
@override@JsonKey() final  bool skipIfTrainedToday;
@override@JsonKey() final  bool hydrationReminders;
@override@JsonKey() final  String hydrationInterval;
@override@JsonKey() final  bool summariesEnabled;
@override@JsonKey() final  bool workoutScheduleCompletion;
@override@JsonKey() final  bool weeklyRecap;
@override@JsonKey() final  bool achievementsEnabled;
@override@JsonKey() final  bool prAchievements;
@override@JsonKey() final  bool streakMilestones;
@override@JsonKey() final  bool scheduleStatusAlerts;
@override@JsonKey() final  bool historyRecordedSaved;
@override@JsonKey() final  bool quietHoursEnabled;
@override@JsonKey() final  String quietHoursFrom;
@override@JsonKey() final  String quietHoursTo;
@override@JsonKey() final  bool quietHoursShowLive;
@override@JsonKey() final  bool hapticsEnabled;
@override@JsonKey() final  bool hapticAppNav;
@override@JsonKey() final  bool hapticWorkoutStatus;
@override@JsonKey() final  bool hapticSetStatus;
@override@JsonKey() final  bool hapticWorkoutCompletion;
@override@JsonKey() final  bool hapticTimerCountdowns;
@override@JsonKey() final  bool audioEnabled;
@override@JsonKey() final  bool audioScheduleStatus;
@override@JsonKey() final  bool audioWorkoutStartFinish;
@override@JsonKey() final  bool audioSetCompletion;
@override@JsonKey() final  bool audioTimerCountdown;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsStateCopyWith<_NotificationSettingsState> get copyWith => __$NotificationSettingsStateCopyWithImpl<_NotificationSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsState&&(identical(other.systemNotifications, systemNotifications) || other.systemNotifications == systemNotifications)&&(identical(other.liveWorkoutStatus, liveWorkoutStatus) || other.liveWorkoutStatus == liveWorkoutStatus)&&(identical(other.showScheduleProgress, showScheduleProgress) || other.showScheduleProgress == showScheduleProgress)&&(identical(other.showSetProgress, showSetProgress) || other.showSetProgress == showSetProgress)&&(identical(other.showRestTimerControls, showRestTimerControls) || other.showRestTimerControls == showRestTimerControls)&&(identical(other.showLockScreenDetails, showLockScreenDetails) || other.showLockScreenDetails == showLockScreenDetails)&&(identical(other.allowCompleteSetFromNotification, allowCompleteSetFromNotification) || other.allowCompleteSetFromNotification == allowCompleteSetFromNotification)&&(identical(other.inAppBanners, inAppBanners) || other.inAppBanners == inAppBanners)&&(identical(other.bannerDurationSeconds, bannerDurationSeconds) || other.bannerDurationSeconds == bannerDurationSeconds)&&(identical(other.keepLiveWorkoutPill, keepLiveWorkoutPill) || other.keepLiveWorkoutPill == keepLiveWorkoutPill)&&(identical(other.routineWorkoutReminders, routineWorkoutReminders) || other.routineWorkoutReminders == routineWorkoutReminders)&&const DeepCollectionEquality().equals(other.reminderDays, _reminderDays)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&(identical(other.skipIfTrainedToday, skipIfTrainedToday) || other.skipIfTrainedToday == skipIfTrainedToday)&&(identical(other.hydrationReminders, hydrationReminders) || other.hydrationReminders == hydrationReminders)&&(identical(other.hydrationInterval, hydrationInterval) || other.hydrationInterval == hydrationInterval)&&(identical(other.summariesEnabled, summariesEnabled) || other.summariesEnabled == summariesEnabled)&&(identical(other.workoutScheduleCompletion, workoutScheduleCompletion) || other.workoutScheduleCompletion == workoutScheduleCompletion)&&(identical(other.weeklyRecap, weeklyRecap) || other.weeklyRecap == weeklyRecap)&&(identical(other.achievementsEnabled, achievementsEnabled) || other.achievementsEnabled == achievementsEnabled)&&(identical(other.prAchievements, prAchievements) || other.prAchievements == prAchievements)&&(identical(other.streakMilestones, streakMilestones) || other.streakMilestones == streakMilestones)&&(identical(other.scheduleStatusAlerts, scheduleStatusAlerts) || other.scheduleStatusAlerts == scheduleStatusAlerts)&&(identical(other.historyRecordedSaved, historyRecordedSaved) || other.historyRecordedSaved == historyRecordedSaved)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.quietHoursFrom, quietHoursFrom) || other.quietHoursFrom == quietHoursFrom)&&(identical(other.quietHoursTo, quietHoursTo) || other.quietHoursTo == quietHoursTo)&&(identical(other.quietHoursShowLive, quietHoursShowLive) || other.quietHoursShowLive == quietHoursShowLive)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.hapticAppNav, hapticAppNav) || other.hapticAppNav == hapticAppNav)&&(identical(other.hapticWorkoutStatus, hapticWorkoutStatus) || other.hapticWorkoutStatus == hapticWorkoutStatus)&&(identical(other.hapticSetStatus, hapticSetStatus) || other.hapticSetStatus == hapticSetStatus)&&(identical(other.hapticWorkoutCompletion, hapticWorkoutCompletion) || other.hapticWorkoutCompletion == hapticWorkoutCompletion)&&(identical(other.hapticTimerCountdowns, hapticTimerCountdowns) || other.hapticTimerCountdowns == hapticTimerCountdowns)&&(identical(other.audioEnabled, audioEnabled) || other.audioEnabled == audioEnabled)&&(identical(other.audioScheduleStatus, audioScheduleStatus) || other.audioScheduleStatus == audioScheduleStatus)&&(identical(other.audioWorkoutStartFinish, audioWorkoutStartFinish) || other.audioWorkoutStartFinish == audioWorkoutStartFinish)&&(identical(other.audioSetCompletion, audioSetCompletion) || other.audioSetCompletion == audioSetCompletion)&&(identical(other.audioTimerCountdown, audioTimerCountdown) || other.audioTimerCountdown == audioTimerCountdown));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,systemNotifications,liveWorkoutStatus,showScheduleProgress,showSetProgress,showRestTimerControls,showLockScreenDetails,allowCompleteSetFromNotification,inAppBanners,bannerDurationSeconds,keepLiveWorkoutPill,routineWorkoutReminders,const DeepCollectionEquality().hash(_reminderDays),reminderTime,skipIfTrainedToday,hydrationReminders,hydrationInterval,summariesEnabled,workoutScheduleCompletion,weeklyRecap,achievementsEnabled,prAchievements,streakMilestones,scheduleStatusAlerts,historyRecordedSaved,quietHoursEnabled,quietHoursFrom,quietHoursTo,quietHoursShowLive,hapticsEnabled,hapticAppNav,hapticWorkoutStatus,hapticSetStatus,hapticWorkoutCompletion,hapticTimerCountdowns,audioEnabled,audioScheduleStatus,audioWorkoutStartFinish,audioSetCompletion,audioTimerCountdown]);
}

@override
String toString() {
    return 'NotificationSettingsState(systemNotifications: $systemNotifications, liveWorkoutStatus: $liveWorkoutStatus, showScheduleProgress: $showScheduleProgress, showSetProgress: $showSetProgress, showRestTimerControls: $showRestTimerControls, showLockScreenDetails: $showLockScreenDetails, allowCompleteSetFromNotification: $allowCompleteSetFromNotification, inAppBanners: $inAppBanners, bannerDurationSeconds: $bannerDurationSeconds, keepLiveWorkoutPill: $keepLiveWorkoutPill, routineWorkoutReminders: $routineWorkoutReminders, reminderDays: $reminderDays, reminderTime: $reminderTime, skipIfTrainedToday: $skipIfTrainedToday, hydrationReminders: $hydrationReminders, hydrationInterval: $hydrationInterval, summariesEnabled: $summariesEnabled, workoutScheduleCompletion: $workoutScheduleCompletion, weeklyRecap: $weeklyRecap, achievementsEnabled: $achievementsEnabled, prAchievements: $prAchievements, streakMilestones: $streakMilestones, scheduleStatusAlerts: $scheduleStatusAlerts, historyRecordedSaved: $historyRecordedSaved, quietHoursEnabled: $quietHoursEnabled, quietHoursFrom: $quietHoursFrom, quietHoursTo: $quietHoursTo, quietHoursShowLive: $quietHoursShowLive, hapticsEnabled: $hapticsEnabled, hapticAppNav: $hapticAppNav, hapticWorkoutStatus: $hapticWorkoutStatus, hapticSetStatus: $hapticSetStatus, hapticWorkoutCompletion: $hapticWorkoutCompletion, hapticTimerCountdowns: $hapticTimerCountdowns, audioEnabled: $audioEnabled, audioScheduleStatus: $audioScheduleStatus, audioWorkoutStartFinish: $audioWorkoutStartFinish, audioSetCompletion: $audioSetCompletion, audioTimerCountdown: $audioTimerCountdown)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsStateCopyWith<$Res> implements $NotificationSettingsStateCopyWith<$Res> {
  factory _$NotificationSettingsStateCopyWith(_NotificationSettingsState value, $Res Function(_NotificationSettingsState) _then) = __$NotificationSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool systemNotifications, bool liveWorkoutStatus, bool showScheduleProgress, bool showSetProgress, bool showRestTimerControls, bool showLockScreenDetails, bool allowCompleteSetFromNotification, bool inAppBanners, int bannerDurationSeconds, bool keepLiveWorkoutPill, bool routineWorkoutReminders, List<String> reminderDays, String reminderTime, bool skipIfTrainedToday, bool hydrationReminders, String hydrationInterval, bool summariesEnabled, bool workoutScheduleCompletion, bool weeklyRecap, bool achievementsEnabled, bool prAchievements, bool streakMilestones, bool scheduleStatusAlerts, bool historyRecordedSaved, bool quietHoursEnabled, String quietHoursFrom, String quietHoursTo, bool quietHoursShowLive, bool hapticsEnabled, bool hapticAppNav, bool hapticWorkoutStatus, bool hapticSetStatus, bool hapticWorkoutCompletion, bool hapticTimerCountdowns, bool audioEnabled, bool audioScheduleStatus, bool audioWorkoutStartFinish, bool audioSetCompletion, bool audioTimerCountdown
});




}
/// @nodoc
class __$NotificationSettingsStateCopyWithImpl<$Res>
    implements _$NotificationSettingsStateCopyWith<$Res> {
  __$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final _NotificationSettingsState _self;
  final $Res Function(_NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemNotifications = null,Object? liveWorkoutStatus = null,Object? showScheduleProgress = null,Object? showSetProgress = null,Object? showRestTimerControls = null,Object? showLockScreenDetails = null,Object? allowCompleteSetFromNotification = null,Object? inAppBanners = null,Object? bannerDurationSeconds = null,Object? keepLiveWorkoutPill = null,Object? routineWorkoutReminders = null,Object? reminderDays = null,Object? reminderTime = null,Object? skipIfTrainedToday = null,Object? hydrationReminders = null,Object? hydrationInterval = null,Object? summariesEnabled = null,Object? workoutScheduleCompletion = null,Object? weeklyRecap = null,Object? achievementsEnabled = null,Object? prAchievements = null,Object? streakMilestones = null,Object? scheduleStatusAlerts = null,Object? historyRecordedSaved = null,Object? quietHoursEnabled = null,Object? quietHoursFrom = null,Object? quietHoursTo = null,Object? quietHoursShowLive = null,Object? hapticsEnabled = null,Object? hapticAppNav = null,Object? hapticWorkoutStatus = null,Object? hapticSetStatus = null,Object? hapticWorkoutCompletion = null,Object? hapticTimerCountdowns = null,Object? audioEnabled = null,Object? audioScheduleStatus = null,Object? audioWorkoutStartFinish = null,Object? audioSetCompletion = null,Object? audioTimerCountdown = null,}) {
  return _then(_NotificationSettingsState(
systemNotifications: null == systemNotifications ? _self.systemNotifications : systemNotifications // ignore: cast_nullable_to_non_nullable
as bool,liveWorkoutStatus: null == liveWorkoutStatus ? _self.liveWorkoutStatus : liveWorkoutStatus // ignore: cast_nullable_to_non_nullable
as bool,showScheduleProgress: null == showScheduleProgress ? _self.showScheduleProgress : showScheduleProgress // ignore: cast_nullable_to_non_nullable
as bool,showSetProgress: null == showSetProgress ? _self.showSetProgress : showSetProgress // ignore: cast_nullable_to_non_nullable
as bool,showRestTimerControls: null == showRestTimerControls ? _self.showRestTimerControls : showRestTimerControls // ignore: cast_nullable_to_non_nullable
as bool,showLockScreenDetails: null == showLockScreenDetails ? _self.showLockScreenDetails : showLockScreenDetails // ignore: cast_nullable_to_non_nullable
as bool,allowCompleteSetFromNotification: null == allowCompleteSetFromNotification ? _self.allowCompleteSetFromNotification : allowCompleteSetFromNotification // ignore: cast_nullable_to_non_nullable
as bool,inAppBanners: null == inAppBanners ? _self.inAppBanners : inAppBanners // ignore: cast_nullable_to_non_nullable
as bool,bannerDurationSeconds: null == bannerDurationSeconds ? _self.bannerDurationSeconds : bannerDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,keepLiveWorkoutPill: null == keepLiveWorkoutPill ? _self.keepLiveWorkoutPill : keepLiveWorkoutPill // ignore: cast_nullable_to_non_nullable
as bool,routineWorkoutReminders: null == routineWorkoutReminders ? _self.routineWorkoutReminders : routineWorkoutReminders // ignore: cast_nullable_to_non_nullable
as bool,reminderDays: null == reminderDays ? _self._reminderDays : reminderDays // ignore: cast_nullable_to_non_nullable
as List<String>,reminderTime: null == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String,skipIfTrainedToday: null == skipIfTrainedToday ? _self.skipIfTrainedToday : skipIfTrainedToday // ignore: cast_nullable_to_non_nullable
as bool,hydrationReminders: null == hydrationReminders ? _self.hydrationReminders : hydrationReminders // ignore: cast_nullable_to_non_nullable
as bool,hydrationInterval: null == hydrationInterval ? _self.hydrationInterval : hydrationInterval // ignore: cast_nullable_to_non_nullable
as String,summariesEnabled: null == summariesEnabled ? _self.summariesEnabled : summariesEnabled // ignore: cast_nullable_to_non_nullable
as bool,workoutScheduleCompletion: null == workoutScheduleCompletion ? _self.workoutScheduleCompletion : workoutScheduleCompletion // ignore: cast_nullable_to_non_nullable
as bool,weeklyRecap: null == weeklyRecap ? _self.weeklyRecap : weeklyRecap // ignore: cast_nullable_to_non_nullable
as bool,achievementsEnabled: null == achievementsEnabled ? _self.achievementsEnabled : achievementsEnabled // ignore: cast_nullable_to_non_nullable
as bool,prAchievements: null == prAchievements ? _self.prAchievements : prAchievements // ignore: cast_nullable_to_non_nullable
as bool,streakMilestones: null == streakMilestones ? _self.streakMilestones : streakMilestones // ignore: cast_nullable_to_non_nullable
as bool,scheduleStatusAlerts: null == scheduleStatusAlerts ? _self.scheduleStatusAlerts : scheduleStatusAlerts // ignore: cast_nullable_to_non_nullable
as bool,historyRecordedSaved: null == historyRecordedSaved ? _self.historyRecordedSaved : historyRecordedSaved // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursFrom: null == quietHoursFrom ? _self.quietHoursFrom : quietHoursFrom // ignore: cast_nullable_to_non_nullable
as String,quietHoursTo: null == quietHoursTo ? _self.quietHoursTo : quietHoursTo // ignore: cast_nullable_to_non_nullable
as String,quietHoursShowLive: null == quietHoursShowLive ? _self.quietHoursShowLive : quietHoursShowLive // ignore: cast_nullable_to_non_nullable
as bool,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,hapticAppNav: null == hapticAppNav ? _self.hapticAppNav : hapticAppNav // ignore: cast_nullable_to_non_nullable
as bool,hapticWorkoutStatus: null == hapticWorkoutStatus ? _self.hapticWorkoutStatus : hapticWorkoutStatus // ignore: cast_nullable_to_non_nullable
as bool,hapticSetStatus: null == hapticSetStatus ? _self.hapticSetStatus : hapticSetStatus // ignore: cast_nullable_to_non_nullable
as bool,hapticWorkoutCompletion: null == hapticWorkoutCompletion ? _self.hapticWorkoutCompletion : hapticWorkoutCompletion // ignore: cast_nullable_to_non_nullable
as bool,hapticTimerCountdowns: null == hapticTimerCountdowns ? _self.hapticTimerCountdowns : hapticTimerCountdowns // ignore: cast_nullable_to_non_nullable
as bool,audioEnabled: null == audioEnabled ? _self.audioEnabled : audioEnabled // ignore: cast_nullable_to_non_nullable
as bool,audioScheduleStatus: null == audioScheduleStatus ? _self.audioScheduleStatus : audioScheduleStatus // ignore: cast_nullable_to_non_nullable
as bool,audioWorkoutStartFinish: null == audioWorkoutStartFinish ? _self.audioWorkoutStartFinish : audioWorkoutStartFinish // ignore: cast_nullable_to_non_nullable
as bool,audioSetCompletion: null == audioSetCompletion ? _self.audioSetCompletion : audioSetCompletion // ignore: cast_nullable_to_non_nullable
as bool,audioTimerCountdown: null == audioTimerCountdown ? _self.audioTimerCountdown : audioTimerCountdown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
