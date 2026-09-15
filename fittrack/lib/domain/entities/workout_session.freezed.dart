// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSession {

 String get id; String get scheduleId; DateTime get startTime; DateTime? get endTime; int? get durationSeconds; int? get totalCalories; String? get notes; String? get intensity; int get totalSets; int get totalReps; double get totalVolumeKg;
/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<WorkoutSession> get copyWith => _$WorkoutSessionCopyWithImpl<WorkoutSession>(this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scheduleId, _this.scheduleId) || other.scheduleId == _this.scheduleId)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.totalCalories, _this.totalCalories) || other.totalCalories == _this.totalCalories)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.intensity, _this.intensity) || other.intensity == _this.intensity)&&(identical(other.totalSets, _this.totalSets) || other.totalSets == _this.totalSets)&&(identical(other.totalReps, _this.totalReps) || other.totalReps == _this.totalReps)&&(identical(other.totalVolumeKg, _this.totalVolumeKg) || other.totalVolumeKg == _this.totalVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutSession;
  return Object.hash(runtimeType,_this.id,_this.scheduleId,_this.startTime,_this.endTime,_this.durationSeconds,_this.totalCalories,_this.notes,_this.intensity,_this.totalSets,_this.totalReps,_this.totalVolumeKg);
}

@override
String toString() {
  final _this = this as WorkoutSession;
  return 'WorkoutSession(id: ${_this.id}, scheduleId: ${_this.scheduleId}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, durationSeconds: ${_this.durationSeconds}, totalCalories: ${_this.totalCalories}, notes: ${_this.notes}, intensity: ${_this.intensity}, totalSets: ${_this.totalSets}, totalReps: ${_this.totalReps}, totalVolumeKg: ${_this.totalVolumeKg})';
}


}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res>  {
  factory $WorkoutSessionCopyWith(WorkoutSession value, $Res Function(WorkoutSession) _then) = _$WorkoutSessionCopyWithImpl;
@useResult
$Res call({
 String id, String scheduleId, DateTime startTime, DateTime? endTime, int? durationSeconds, int? totalCalories, String? notes, String? intensity, int totalSets, int totalReps, double totalVolumeKg
});




}
/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scheduleId = null,Object? startTime = null,Object? endTime = freezed,Object? durationSeconds = freezed,Object? totalCalories = freezed,Object? notes = freezed,Object? intensity = freezed,Object? totalSets = null,Object? totalReps = null,Object? totalVolumeKg = null,}) {
  return _then(WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,totalCalories: freezed == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,intensity: freezed == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as String?,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String scheduleId,  DateTime startTime,  DateTime? endTime,  int? durationSeconds,  int? totalCalories,  String? notes,  String? intensity,  int totalSets,  int totalReps,  double totalVolumeKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.scheduleId,_that.startTime,_that.endTime,_that.durationSeconds,_that.totalCalories,_that.notes,_that.intensity,_that.totalSets,_that.totalReps,_that.totalVolumeKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String scheduleId,  DateTime startTime,  DateTime? endTime,  int? durationSeconds,  int? totalCalories,  String? notes,  String? intensity,  int totalSets,  int totalReps,  double totalVolumeKg)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession():
return $default(_that.id,_that.scheduleId,_that.startTime,_that.endTime,_that.durationSeconds,_that.totalCalories,_that.notes,_that.intensity,_that.totalSets,_that.totalReps,_that.totalVolumeKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String scheduleId,  DateTime startTime,  DateTime? endTime,  int? durationSeconds,  int? totalCalories,  String? notes,  String? intensity,  int totalSets,  int totalReps,  double totalVolumeKg)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.scheduleId,_that.startTime,_that.endTime,_that.durationSeconds,_that.totalCalories,_that.notes,_that.intensity,_that.totalSets,_that.totalReps,_that.totalVolumeKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSession extends WorkoutSession {
  const _WorkoutSession({required this.id, required this.scheduleId, required this.startTime, this.endTime, this.durationSeconds, this.totalCalories, this.notes, this.intensity, this.totalSets = 0, this.totalReps = 0, this.totalVolumeKg = 0.0}): super._();
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

@override final  String id;
@override final  String scheduleId;
@override final  DateTime startTime;
@override final  DateTime? endTime;
@override final  int? durationSeconds;
@override final  int? totalCalories;
@override final  String? notes;
@override final  String? intensity;
@override@JsonKey() final  int totalSets;
@override@JsonKey() final  int totalReps;
@override@JsonKey() final  double totalVolumeKg;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSessionCopyWith<_WorkoutSession> get copyWith => __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,scheduleId,startTime,endTime,durationSeconds,totalCalories,notes,intensity,totalSets,totalReps,totalVolumeKg);
}

@override
String toString() {
    return 'WorkoutSession(id: $id, scheduleId: $scheduleId, startTime: $startTime, endTime: $endTime, durationSeconds: $durationSeconds, totalCalories: $totalCalories, notes: $notes, intensity: $intensity, totalSets: $totalSets, totalReps: $totalReps, totalVolumeKg: $totalVolumeKg)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res> implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(_WorkoutSession value, $Res Function(_WorkoutSession) _then) = __$WorkoutSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String scheduleId, DateTime startTime, DateTime? endTime, int? durationSeconds, int? totalCalories, String? notes, String? intensity, int totalSets, int totalReps, double totalVolumeKg
});




}
/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scheduleId = null,Object? startTime = null,Object? endTime = freezed,Object? durationSeconds = freezed,Object? totalCalories = freezed,Object? notes = freezed,Object? intensity = freezed,Object? totalSets = null,Object? totalReps = null,Object? totalVolumeKg = null,}) {
  return _then(_WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,totalCalories: freezed == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,intensity: freezed == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as String?,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
