// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSchedule {

 String get id; String get title; String get description; String get focus; String get experience; String get equipment; int get durationWeeks; int get daysPerWeek; bool get isFavorite; bool get isCustom; List<String> get targetMuscles; int get exerciseCount; int get estimatedMinutes; List<ScheduleExercise> get exercises;
/// Create a copy of WorkoutSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutScheduleCopyWith<WorkoutSchedule> get copyWith => _$WorkoutScheduleCopyWithImpl<WorkoutSchedule>(this as WorkoutSchedule, _$identity);

  /// Serializes this WorkoutSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSchedule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.focus, _this.focus) || other.focus == _this.focus)&&(identical(other.experience, _this.experience) || other.experience == _this.experience)&&(identical(other.equipment, _this.equipment) || other.equipment == _this.equipment)&&(identical(other.durationWeeks, _this.durationWeeks) || other.durationWeeks == _this.durationWeeks)&&(identical(other.daysPerWeek, _this.daysPerWeek) || other.daysPerWeek == _this.daysPerWeek)&&(identical(other.isFavorite, _this.isFavorite) || other.isFavorite == _this.isFavorite)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom)&&const DeepCollectionEquality().equals(other.targetMuscles, _this.targetMuscles)&&(identical(other.exerciseCount, _this.exerciseCount) || other.exerciseCount == _this.exerciseCount)&&(identical(other.estimatedMinutes, _this.estimatedMinutes) || other.estimatedMinutes == _this.estimatedMinutes)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutSchedule;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.focus,_this.experience,_this.equipment,_this.durationWeeks,_this.daysPerWeek,_this.isFavorite,_this.isCustom,const DeepCollectionEquality().hash(_this.targetMuscles),_this.exerciseCount,_this.estimatedMinutes,const DeepCollectionEquality().hash(_this.exercises));
}

@override
String toString() {
  final _this = this as WorkoutSchedule;
  return 'WorkoutSchedule(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, focus: ${_this.focus}, experience: ${_this.experience}, equipment: ${_this.equipment}, durationWeeks: ${_this.durationWeeks}, daysPerWeek: ${_this.daysPerWeek}, isFavorite: ${_this.isFavorite}, isCustom: ${_this.isCustom}, targetMuscles: ${_this.targetMuscles}, exerciseCount: ${_this.exerciseCount}, estimatedMinutes: ${_this.estimatedMinutes}, exercises: ${_this.exercises})';
}


}

/// @nodoc
abstract mixin class $WorkoutScheduleCopyWith<$Res>  {
  factory $WorkoutScheduleCopyWith(WorkoutSchedule value, $Res Function(WorkoutSchedule) _then) = _$WorkoutScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String focus, String experience, String equipment, int durationWeeks, int daysPerWeek, bool isFavorite, bool isCustom, List<String> targetMuscles, int exerciseCount, int estimatedMinutes, List<ScheduleExercise> exercises
});




}
/// @nodoc
class _$WorkoutScheduleCopyWithImpl<$Res>
    implements $WorkoutScheduleCopyWith<$Res> {
  _$WorkoutScheduleCopyWithImpl(this._self, this._then);

  final WorkoutSchedule _self;
  final $Res Function(WorkoutSchedule) _then;

/// Create a copy of WorkoutSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? focus = null,Object? experience = null,Object? equipment = null,Object? durationWeeks = null,Object? daysPerWeek = null,Object? isFavorite = null,Object? isCustom = null,Object? targetMuscles = null,Object? exerciseCount = null,Object? estimatedMinutes = null,Object? exercises = null,}) {
  return _then(WorkoutSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,daysPerWeek: null == daysPerWeek ? _self.daysPerWeek : daysPerWeek // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,targetMuscles: null == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ScheduleExercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSchedule].
extension WorkoutSchedulePatterns on WorkoutSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSchedule value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  bool isFavorite,  bool isCustom,  List<String> targetMuscles,  int exerciseCount,  int estimatedMinutes,  List<ScheduleExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSchedule() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.isFavorite,_that.isCustom,_that.targetMuscles,_that.exerciseCount,_that.estimatedMinutes,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  bool isFavorite,  bool isCustom,  List<String> targetMuscles,  int exerciseCount,  int estimatedMinutes,  List<ScheduleExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSchedule():
return $default(_that.id,_that.title,_that.description,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.isFavorite,_that.isCustom,_that.targetMuscles,_that.exerciseCount,_that.estimatedMinutes,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  bool isFavorite,  bool isCustom,  List<String> targetMuscles,  int exerciseCount,  int estimatedMinutes,  List<ScheduleExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSchedule() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.isFavorite,_that.isCustom,_that.targetMuscles,_that.exerciseCount,_that.estimatedMinutes,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSchedule extends WorkoutSchedule {
  const _WorkoutSchedule({required this.id, required this.title, required this.description, required this.focus, required this.experience, required this.equipment, required this.durationWeeks, required this.daysPerWeek, this.isFavorite = false, this.isCustom = false,  List<String> targetMuscles = const <String>[], this.exerciseCount = 0, this.estimatedMinutes = 0,  List<ScheduleExercise> exercises = const <ScheduleExercise>[]}): _targetMuscles = targetMuscles,_exercises = exercises,super._();
  factory _WorkoutSchedule.fromJson(Map<String, dynamic> json) => _$WorkoutScheduleFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String focus;
@override final  String experience;
@override final  String equipment;
@override final  int durationWeeks;
@override final  int daysPerWeek;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isCustom;
 final  List<String> _targetMuscles;
@override@JsonKey() List<String> get targetMuscles {
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetMuscles);
}

@override@JsonKey() final  int exerciseCount;
@override@JsonKey() final  int estimatedMinutes;
 final  List<ScheduleExercise> _exercises;
@override@JsonKey() List<ScheduleExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of WorkoutSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutScheduleCopyWith<_WorkoutSchedule> get copyWith => __$WorkoutScheduleCopyWithImpl<_WorkoutSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.daysPerWeek, daysPerWeek) || other.daysPerWeek == daysPerWeek)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&const DeepCollectionEquality().equals(other.targetMuscles, _targetMuscles)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&const DeepCollectionEquality().equals(other.exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,focus,experience,equipment,durationWeeks,daysPerWeek,isFavorite,isCustom,const DeepCollectionEquality().hash(_targetMuscles),exerciseCount,estimatedMinutes,const DeepCollectionEquality().hash(_exercises));
}

@override
String toString() {
    return 'WorkoutSchedule(id: $id, title: $title, description: $description, focus: $focus, experience: $experience, equipment: $equipment, durationWeeks: $durationWeeks, daysPerWeek: $daysPerWeek, isFavorite: $isFavorite, isCustom: $isCustom, targetMuscles: $targetMuscles, exerciseCount: $exerciseCount, estimatedMinutes: $estimatedMinutes, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$WorkoutScheduleCopyWith<$Res> implements $WorkoutScheduleCopyWith<$Res> {
  factory _$WorkoutScheduleCopyWith(_WorkoutSchedule value, $Res Function(_WorkoutSchedule) _then) = __$WorkoutScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String focus, String experience, String equipment, int durationWeeks, int daysPerWeek, bool isFavorite, bool isCustom, List<String> targetMuscles, int exerciseCount, int estimatedMinutes, List<ScheduleExercise> exercises
});




}
/// @nodoc
class __$WorkoutScheduleCopyWithImpl<$Res>
    implements _$WorkoutScheduleCopyWith<$Res> {
  __$WorkoutScheduleCopyWithImpl(this._self, this._then);

  final _WorkoutSchedule _self;
  final $Res Function(_WorkoutSchedule) _then;

/// Create a copy of WorkoutSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? focus = null,Object? experience = null,Object? equipment = null,Object? durationWeeks = null,Object? daysPerWeek = null,Object? isFavorite = null,Object? isCustom = null,Object? targetMuscles = null,Object? exerciseCount = null,Object? estimatedMinutes = null,Object? exercises = null,}) {
  return _then(_WorkoutSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,daysPerWeek: null == daysPerWeek ? _self.daysPerWeek : daysPerWeek // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,targetMuscles: null == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ScheduleExercise>,
  ));
}


}

// dart format on
