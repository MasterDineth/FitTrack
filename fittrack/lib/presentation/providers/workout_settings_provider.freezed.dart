// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_settings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutSettingsState {

 String get defaultRestTimer; bool get autoStartRestTimer; bool get keepScreenAwake; bool get enableRPE; bool get includeWarmups; bool get plateCalculator; String get weightUnit; String get distanceUnit; String get bodyUnit; double get barbellWeight; double get ezBarWeight; String get gymProfile;
/// Create a copy of WorkoutSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSettingsStateCopyWith<WorkoutSettingsState> get copyWith => _$WorkoutSettingsStateCopyWithImpl<WorkoutSettingsState>(this as WorkoutSettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutSettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSettingsState&&(identical(other.defaultRestTimer, _this.defaultRestTimer) || other.defaultRestTimer == _this.defaultRestTimer)&&(identical(other.autoStartRestTimer, _this.autoStartRestTimer) || other.autoStartRestTimer == _this.autoStartRestTimer)&&(identical(other.keepScreenAwake, _this.keepScreenAwake) || other.keepScreenAwake == _this.keepScreenAwake)&&(identical(other.enableRPE, _this.enableRPE) || other.enableRPE == _this.enableRPE)&&(identical(other.includeWarmups, _this.includeWarmups) || other.includeWarmups == _this.includeWarmups)&&(identical(other.plateCalculator, _this.plateCalculator) || other.plateCalculator == _this.plateCalculator)&&(identical(other.weightUnit, _this.weightUnit) || other.weightUnit == _this.weightUnit)&&(identical(other.distanceUnit, _this.distanceUnit) || other.distanceUnit == _this.distanceUnit)&&(identical(other.bodyUnit, _this.bodyUnit) || other.bodyUnit == _this.bodyUnit)&&(identical(other.barbellWeight, _this.barbellWeight) || other.barbellWeight == _this.barbellWeight)&&(identical(other.ezBarWeight, _this.ezBarWeight) || other.ezBarWeight == _this.ezBarWeight)&&(identical(other.gymProfile, _this.gymProfile) || other.gymProfile == _this.gymProfile));
}


@override
int get hashCode {
  final _this = this as WorkoutSettingsState;
  return Object.hash(runtimeType,_this.defaultRestTimer,_this.autoStartRestTimer,_this.keepScreenAwake,_this.enableRPE,_this.includeWarmups,_this.plateCalculator,_this.weightUnit,_this.distanceUnit,_this.bodyUnit,_this.barbellWeight,_this.ezBarWeight,_this.gymProfile);
}

@override
String toString() {
  final _this = this as WorkoutSettingsState;
  return 'WorkoutSettingsState(defaultRestTimer: ${_this.defaultRestTimer}, autoStartRestTimer: ${_this.autoStartRestTimer}, keepScreenAwake: ${_this.keepScreenAwake}, enableRPE: ${_this.enableRPE}, includeWarmups: ${_this.includeWarmups}, plateCalculator: ${_this.plateCalculator}, weightUnit: ${_this.weightUnit}, distanceUnit: ${_this.distanceUnit}, bodyUnit: ${_this.bodyUnit}, barbellWeight: ${_this.barbellWeight}, ezBarWeight: ${_this.ezBarWeight}, gymProfile: ${_this.gymProfile})';
}


}

/// @nodoc
abstract mixin class $WorkoutSettingsStateCopyWith<$Res>  {
  factory $WorkoutSettingsStateCopyWith(WorkoutSettingsState value, $Res Function(WorkoutSettingsState) _then) = _$WorkoutSettingsStateCopyWithImpl;
@useResult
$Res call({
 String defaultRestTimer, bool autoStartRestTimer, bool keepScreenAwake, bool enableRPE, bool includeWarmups, bool plateCalculator, String weightUnit, String distanceUnit, String bodyUnit, double barbellWeight, double ezBarWeight, String gymProfile
});




}
/// @nodoc
class _$WorkoutSettingsStateCopyWithImpl<$Res>
    implements $WorkoutSettingsStateCopyWith<$Res> {
  _$WorkoutSettingsStateCopyWithImpl(this._self, this._then);

  final WorkoutSettingsState _self;
  final $Res Function(WorkoutSettingsState) _then;

/// Create a copy of WorkoutSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultRestTimer = null,Object? autoStartRestTimer = null,Object? keepScreenAwake = null,Object? enableRPE = null,Object? includeWarmups = null,Object? plateCalculator = null,Object? weightUnit = null,Object? distanceUnit = null,Object? bodyUnit = null,Object? barbellWeight = null,Object? ezBarWeight = null,Object? gymProfile = null,}) {
  return _then(WorkoutSettingsState(
defaultRestTimer: null == defaultRestTimer ? _self.defaultRestTimer : defaultRestTimer // ignore: cast_nullable_to_non_nullable
as String,autoStartRestTimer: null == autoStartRestTimer ? _self.autoStartRestTimer : autoStartRestTimer // ignore: cast_nullable_to_non_nullable
as bool,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,enableRPE: null == enableRPE ? _self.enableRPE : enableRPE // ignore: cast_nullable_to_non_nullable
as bool,includeWarmups: null == includeWarmups ? _self.includeWarmups : includeWarmups // ignore: cast_nullable_to_non_nullable
as bool,plateCalculator: null == plateCalculator ? _self.plateCalculator : plateCalculator // ignore: cast_nullable_to_non_nullable
as bool,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,bodyUnit: null == bodyUnit ? _self.bodyUnit : bodyUnit // ignore: cast_nullable_to_non_nullable
as String,barbellWeight: null == barbellWeight ? _self.barbellWeight : barbellWeight // ignore: cast_nullable_to_non_nullable
as double,ezBarWeight: null == ezBarWeight ? _self.ezBarWeight : ezBarWeight // ignore: cast_nullable_to_non_nullable
as double,gymProfile: null == gymProfile ? _self.gymProfile : gymProfile // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSettingsState].
extension WorkoutSettingsStatePatterns on WorkoutSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String defaultRestTimer,  bool autoStartRestTimer,  bool keepScreenAwake,  bool enableRPE,  bool includeWarmups,  bool plateCalculator,  String weightUnit,  String distanceUnit,  String bodyUnit,  double barbellWeight,  double ezBarWeight,  String gymProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSettingsState() when $default != null:
return $default(_that.defaultRestTimer,_that.autoStartRestTimer,_that.keepScreenAwake,_that.enableRPE,_that.includeWarmups,_that.plateCalculator,_that.weightUnit,_that.distanceUnit,_that.bodyUnit,_that.barbellWeight,_that.ezBarWeight,_that.gymProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String defaultRestTimer,  bool autoStartRestTimer,  bool keepScreenAwake,  bool enableRPE,  bool includeWarmups,  bool plateCalculator,  String weightUnit,  String distanceUnit,  String bodyUnit,  double barbellWeight,  double ezBarWeight,  String gymProfile)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSettingsState():
return $default(_that.defaultRestTimer,_that.autoStartRestTimer,_that.keepScreenAwake,_that.enableRPE,_that.includeWarmups,_that.plateCalculator,_that.weightUnit,_that.distanceUnit,_that.bodyUnit,_that.barbellWeight,_that.ezBarWeight,_that.gymProfile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String defaultRestTimer,  bool autoStartRestTimer,  bool keepScreenAwake,  bool enableRPE,  bool includeWarmups,  bool plateCalculator,  String weightUnit,  String distanceUnit,  String bodyUnit,  double barbellWeight,  double ezBarWeight,  String gymProfile)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSettingsState() when $default != null:
return $default(_that.defaultRestTimer,_that.autoStartRestTimer,_that.keepScreenAwake,_that.enableRPE,_that.includeWarmups,_that.plateCalculator,_that.weightUnit,_that.distanceUnit,_that.bodyUnit,_that.barbellWeight,_that.ezBarWeight,_that.gymProfile);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSettingsState implements WorkoutSettingsState {
  const _WorkoutSettingsState({this.defaultRestTimer = '01:30', this.autoStartRestTimer = true, this.keepScreenAwake = true, this.enableRPE = true, this.includeWarmups = false, this.plateCalculator = true, this.weightUnit = 'kg', this.distanceUnit = 'km', this.bodyUnit = 'cm', this.barbellWeight = 20.0, this.ezBarWeight = 10.0, this.gymProfile = 'Home Gym / Power Rack'});
  

@override@JsonKey() final  String defaultRestTimer;
@override@JsonKey() final  bool autoStartRestTimer;
@override@JsonKey() final  bool keepScreenAwake;
@override@JsonKey() final  bool enableRPE;
@override@JsonKey() final  bool includeWarmups;
@override@JsonKey() final  bool plateCalculator;
@override@JsonKey() final  String weightUnit;
@override@JsonKey() final  String distanceUnit;
@override@JsonKey() final  String bodyUnit;
@override@JsonKey() final  double barbellWeight;
@override@JsonKey() final  double ezBarWeight;
@override@JsonKey() final  String gymProfile;

/// Create a copy of WorkoutSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSettingsStateCopyWith<_WorkoutSettingsState> get copyWith => __$WorkoutSettingsStateCopyWithImpl<_WorkoutSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSettingsState&&(identical(other.defaultRestTimer, defaultRestTimer) || other.defaultRestTimer == defaultRestTimer)&&(identical(other.autoStartRestTimer, autoStartRestTimer) || other.autoStartRestTimer == autoStartRestTimer)&&(identical(other.keepScreenAwake, keepScreenAwake) || other.keepScreenAwake == keepScreenAwake)&&(identical(other.enableRPE, enableRPE) || other.enableRPE == enableRPE)&&(identical(other.includeWarmups, includeWarmups) || other.includeWarmups == includeWarmups)&&(identical(other.plateCalculator, plateCalculator) || other.plateCalculator == plateCalculator)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.bodyUnit, bodyUnit) || other.bodyUnit == bodyUnit)&&(identical(other.barbellWeight, barbellWeight) || other.barbellWeight == barbellWeight)&&(identical(other.ezBarWeight, ezBarWeight) || other.ezBarWeight == ezBarWeight)&&(identical(other.gymProfile, gymProfile) || other.gymProfile == gymProfile));
}


@override
int get hashCode {
    return Object.hash(runtimeType,defaultRestTimer,autoStartRestTimer,keepScreenAwake,enableRPE,includeWarmups,plateCalculator,weightUnit,distanceUnit,bodyUnit,barbellWeight,ezBarWeight,gymProfile);
}

@override
String toString() {
    return 'WorkoutSettingsState(defaultRestTimer: $defaultRestTimer, autoStartRestTimer: $autoStartRestTimer, keepScreenAwake: $keepScreenAwake, enableRPE: $enableRPE, includeWarmups: $includeWarmups, plateCalculator: $plateCalculator, weightUnit: $weightUnit, distanceUnit: $distanceUnit, bodyUnit: $bodyUnit, barbellWeight: $barbellWeight, ezBarWeight: $ezBarWeight, gymProfile: $gymProfile)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSettingsStateCopyWith<$Res> implements $WorkoutSettingsStateCopyWith<$Res> {
  factory _$WorkoutSettingsStateCopyWith(_WorkoutSettingsState value, $Res Function(_WorkoutSettingsState) _then) = __$WorkoutSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 String defaultRestTimer, bool autoStartRestTimer, bool keepScreenAwake, bool enableRPE, bool includeWarmups, bool plateCalculator, String weightUnit, String distanceUnit, String bodyUnit, double barbellWeight, double ezBarWeight, String gymProfile
});




}
/// @nodoc
class __$WorkoutSettingsStateCopyWithImpl<$Res>
    implements _$WorkoutSettingsStateCopyWith<$Res> {
  __$WorkoutSettingsStateCopyWithImpl(this._self, this._then);

  final _WorkoutSettingsState _self;
  final $Res Function(_WorkoutSettingsState) _then;

/// Create a copy of WorkoutSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultRestTimer = null,Object? autoStartRestTimer = null,Object? keepScreenAwake = null,Object? enableRPE = null,Object? includeWarmups = null,Object? plateCalculator = null,Object? weightUnit = null,Object? distanceUnit = null,Object? bodyUnit = null,Object? barbellWeight = null,Object? ezBarWeight = null,Object? gymProfile = null,}) {
  return _then(_WorkoutSettingsState(
defaultRestTimer: null == defaultRestTimer ? _self.defaultRestTimer : defaultRestTimer // ignore: cast_nullable_to_non_nullable
as String,autoStartRestTimer: null == autoStartRestTimer ? _self.autoStartRestTimer : autoStartRestTimer // ignore: cast_nullable_to_non_nullable
as bool,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,enableRPE: null == enableRPE ? _self.enableRPE : enableRPE // ignore: cast_nullable_to_non_nullable
as bool,includeWarmups: null == includeWarmups ? _self.includeWarmups : includeWarmups // ignore: cast_nullable_to_non_nullable
as bool,plateCalculator: null == plateCalculator ? _self.plateCalculator : plateCalculator // ignore: cast_nullable_to_non_nullable
as bool,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,bodyUnit: null == bodyUnit ? _self.bodyUnit : bodyUnit // ignore: cast_nullable_to_non_nullable
as String,barbellWeight: null == barbellWeight ? _self.barbellWeight : barbellWeight // ignore: cast_nullable_to_non_nullable
as double,ezBarWeight: null == ezBarWeight ? _self.ezBarWeight : ezBarWeight // ignore: cast_nullable_to_non_nullable
as double,gymProfile: null == gymProfile ? _self.gymProfile : gymProfile // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
