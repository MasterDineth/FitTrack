// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleExercise {

 String get id; String get scheduleId; String get exerciseId; int get sortOrder; int get targetSets; int get targetReps; double get targetWeightKg; int get restDurationSeconds;
/// Create a copy of ScheduleExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleExerciseCopyWith<ScheduleExercise> get copyWith => _$ScheduleExerciseCopyWithImpl<ScheduleExercise>(this as ScheduleExercise, _$identity);

  /// Serializes this ScheduleExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scheduleId, _this.scheduleId) || other.scheduleId == _this.scheduleId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.targetSets, _this.targetSets) || other.targetSets == _this.targetSets)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.restDurationSeconds, _this.restDurationSeconds) || other.restDurationSeconds == _this.restDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleExercise;
  return Object.hash(runtimeType,_this.id,_this.scheduleId,_this.exerciseId,_this.sortOrder,_this.targetSets,_this.targetReps,_this.targetWeightKg,_this.restDurationSeconds);
}

@override
String toString() {
  final _this = this as ScheduleExercise;
  return 'ScheduleExercise(id: ${_this.id}, scheduleId: ${_this.scheduleId}, exerciseId: ${_this.exerciseId}, sortOrder: ${_this.sortOrder}, targetSets: ${_this.targetSets}, targetReps: ${_this.targetReps}, targetWeightKg: ${_this.targetWeightKg}, restDurationSeconds: ${_this.restDurationSeconds})';
}


}

/// @nodoc
abstract mixin class $ScheduleExerciseCopyWith<$Res>  {
  factory $ScheduleExerciseCopyWith(ScheduleExercise value, $Res Function(ScheduleExercise) _then) = _$ScheduleExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String scheduleId, String exerciseId, int sortOrder, int targetSets, int targetReps, double targetWeightKg, int restDurationSeconds
});




}
/// @nodoc
class _$ScheduleExerciseCopyWithImpl<$Res>
    implements $ScheduleExerciseCopyWith<$Res> {
  _$ScheduleExerciseCopyWithImpl(this._self, this._then);

  final ScheduleExercise _self;
  final $Res Function(ScheduleExercise) _then;

/// Create a copy of ScheduleExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scheduleId = null,Object? exerciseId = null,Object? sortOrder = null,Object? targetSets = null,Object? targetReps = null,Object? targetWeightKg = null,Object? restDurationSeconds = null,}) {
  return _then(ScheduleExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,targetSets: null == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleExercise].
extension ScheduleExercisePatterns on ScheduleExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleExercise value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleExercise value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String scheduleId,  String exerciseId,  int sortOrder,  int targetSets,  int targetReps,  double targetWeightKg,  int restDurationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleExercise() when $default != null:
return $default(_that.id,_that.scheduleId,_that.exerciseId,_that.sortOrder,_that.targetSets,_that.targetReps,_that.targetWeightKg,_that.restDurationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String scheduleId,  String exerciseId,  int sortOrder,  int targetSets,  int targetReps,  double targetWeightKg,  int restDurationSeconds)  $default,) {final _that = this;
switch (_that) {
case _ScheduleExercise():
return $default(_that.id,_that.scheduleId,_that.exerciseId,_that.sortOrder,_that.targetSets,_that.targetReps,_that.targetWeightKg,_that.restDurationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String scheduleId,  String exerciseId,  int sortOrder,  int targetSets,  int targetReps,  double targetWeightKg,  int restDurationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleExercise() when $default != null:
return $default(_that.id,_that.scheduleId,_that.exerciseId,_that.sortOrder,_that.targetSets,_that.targetReps,_that.targetWeightKg,_that.restDurationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleExercise extends ScheduleExercise {
  const _ScheduleExercise({required this.id, required this.scheduleId, required this.exerciseId, required this.sortOrder, required this.targetSets, required this.targetReps, required this.targetWeightKg, required this.restDurationSeconds}): super._();
  factory _ScheduleExercise.fromJson(Map<String, dynamic> json) => _$ScheduleExerciseFromJson(json);

@override final  String id;
@override final  String scheduleId;
@override final  String exerciseId;
@override final  int sortOrder;
@override final  int targetSets;
@override final  int targetReps;
@override final  double targetWeightKg;
@override final  int restDurationSeconds;

/// Create a copy of ScheduleExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleExerciseCopyWith<_ScheduleExercise> get copyWith => __$ScheduleExerciseCopyWithImpl<_ScheduleExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.targetSets, targetSets) || other.targetSets == targetSets)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,scheduleId,exerciseId,sortOrder,targetSets,targetReps,targetWeightKg,restDurationSeconds);
}

@override
String toString() {
    return 'ScheduleExercise(id: $id, scheduleId: $scheduleId, exerciseId: $exerciseId, sortOrder: $sortOrder, targetSets: $targetSets, targetReps: $targetReps, targetWeightKg: $targetWeightKg, restDurationSeconds: $restDurationSeconds)';
}


}

/// @nodoc
abstract mixin class _$ScheduleExerciseCopyWith<$Res> implements $ScheduleExerciseCopyWith<$Res> {
  factory _$ScheduleExerciseCopyWith(_ScheduleExercise value, $Res Function(_ScheduleExercise) _then) = __$ScheduleExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String scheduleId, String exerciseId, int sortOrder, int targetSets, int targetReps, double targetWeightKg, int restDurationSeconds
});




}
/// @nodoc
class __$ScheduleExerciseCopyWithImpl<$Res>
    implements _$ScheduleExerciseCopyWith<$Res> {
  __$ScheduleExerciseCopyWithImpl(this._self, this._then);

  final _ScheduleExercise _self;
  final $Res Function(_ScheduleExercise) _then;

/// Create a copy of ScheduleExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scheduleId = null,Object? exerciseId = null,Object? sortOrder = null,Object? targetSets = null,Object? targetReps = null,Object? targetWeightKg = null,Object? restDurationSeconds = null,}) {
  return _then(_ScheduleExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,targetSets: null == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
