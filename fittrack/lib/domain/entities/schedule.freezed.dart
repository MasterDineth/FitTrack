// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Schedule {

 String get id; String get name; String get description; List<String> get targetMuscles; List<int> get assignedWeekdays; int get orderIndex; bool get isArchived; bool get isFavorite; String get focus; String get experience; String get equipment; int get durationWeeks; int get daysPerWeek; int get estimatedMinutes; bool get isCustom;
/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleCopyWith<Schedule> get copyWith => _$ScheduleCopyWithImpl<Schedule>(this as Schedule, _$identity);

  /// Serializes this Schedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Schedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Schedule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.targetMuscles, _this.targetMuscles)&&const DeepCollectionEquality().equals(other.assignedWeekdays, _this.assignedWeekdays)&&(identical(other.orderIndex, _this.orderIndex) || other.orderIndex == _this.orderIndex)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.isFavorite, _this.isFavorite) || other.isFavorite == _this.isFavorite)&&(identical(other.focus, _this.focus) || other.focus == _this.focus)&&(identical(other.experience, _this.experience) || other.experience == _this.experience)&&(identical(other.equipment, _this.equipment) || other.equipment == _this.equipment)&&(identical(other.durationWeeks, _this.durationWeeks) || other.durationWeeks == _this.durationWeeks)&&(identical(other.daysPerWeek, _this.daysPerWeek) || other.daysPerWeek == _this.daysPerWeek)&&(identical(other.estimatedMinutes, _this.estimatedMinutes) || other.estimatedMinutes == _this.estimatedMinutes)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Schedule;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,const DeepCollectionEquality().hash(_this.targetMuscles),const DeepCollectionEquality().hash(_this.assignedWeekdays),_this.orderIndex,_this.isArchived,_this.isFavorite,_this.focus,_this.experience,_this.equipment,_this.durationWeeks,_this.daysPerWeek,_this.estimatedMinutes,_this.isCustom);
}

@override
String toString() {
  final _this = this as Schedule;
  return 'Schedule(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, targetMuscles: ${_this.targetMuscles}, assignedWeekdays: ${_this.assignedWeekdays}, orderIndex: ${_this.orderIndex}, isArchived: ${_this.isArchived}, isFavorite: ${_this.isFavorite}, focus: ${_this.focus}, experience: ${_this.experience}, equipment: ${_this.equipment}, durationWeeks: ${_this.durationWeeks}, daysPerWeek: ${_this.daysPerWeek}, estimatedMinutes: ${_this.estimatedMinutes}, isCustom: ${_this.isCustom})';
}


}

/// @nodoc
abstract mixin class $ScheduleCopyWith<$Res>  {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) _then) = _$ScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, List<String> targetMuscles, List<int> assignedWeekdays, int orderIndex, bool isArchived, bool isFavorite, String focus, String experience, String equipment, int durationWeeks, int daysPerWeek, int estimatedMinutes, bool isCustom
});




}
/// @nodoc
class _$ScheduleCopyWithImpl<$Res>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._self, this._then);

  final Schedule _self;
  final $Res Function(Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? targetMuscles = null,Object? assignedWeekdays = null,Object? orderIndex = null,Object? isArchived = null,Object? isFavorite = null,Object? focus = null,Object? experience = null,Object? equipment = null,Object? durationWeeks = null,Object? daysPerWeek = null,Object? estimatedMinutes = null,Object? isCustom = null,}) {
  return _then(Schedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetMuscles: null == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,assignedWeekdays: null == assignedWeekdays ? _self.assignedWeekdays : assignedWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,daysPerWeek: null == daysPerWeek ? _self.daysPerWeek : daysPerWeek // ignore: cast_nullable_to_non_nullable
as int,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Schedule].
extension SchedulePatterns on Schedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Schedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Schedule value)  $default,){
final _that = this;
switch (_that) {
case _Schedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Schedule value)?  $default,){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  List<String> targetMuscles,  List<int> assignedWeekdays,  int orderIndex,  bool isArchived,  bool isFavorite,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  int estimatedMinutes,  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.targetMuscles,_that.assignedWeekdays,_that.orderIndex,_that.isArchived,_that.isFavorite,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.estimatedMinutes,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  List<String> targetMuscles,  List<int> assignedWeekdays,  int orderIndex,  bool isArchived,  bool isFavorite,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  int estimatedMinutes,  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _Schedule():
return $default(_that.id,_that.name,_that.description,_that.targetMuscles,_that.assignedWeekdays,_that.orderIndex,_that.isArchived,_that.isFavorite,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.estimatedMinutes,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  List<String> targetMuscles,  List<int> assignedWeekdays,  int orderIndex,  bool isArchived,  bool isFavorite,  String focus,  String experience,  String equipment,  int durationWeeks,  int daysPerWeek,  int estimatedMinutes,  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.targetMuscles,_that.assignedWeekdays,_that.orderIndex,_that.isArchived,_that.isFavorite,_that.focus,_that.experience,_that.equipment,_that.durationWeeks,_that.daysPerWeek,_that.estimatedMinutes,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Schedule extends Schedule {
  const _Schedule({required this.id, required this.name, required this.description, required  List<String> targetMuscles, required  List<int> assignedWeekdays, required this.orderIndex, this.isArchived = false, this.isFavorite = false, this.focus = 'Hypertrophy', this.experience = 'Intermediate', this.equipment = 'Full Gym', this.durationWeeks = 8, this.daysPerWeek = 4, this.estimatedMinutes = 45, this.isCustom = false}): _targetMuscles = targetMuscles,_assignedWeekdays = assignedWeekdays,super._();
  factory _Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
 final  List<String> _targetMuscles;
@override List<String> get targetMuscles {
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetMuscles);
}

 final  List<int> _assignedWeekdays;
@override List<int> get assignedWeekdays {
  if (_assignedWeekdays is EqualUnmodifiableListView) return _assignedWeekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedWeekdays);
}

@override final  int orderIndex;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  String focus;
@override@JsonKey() final  String experience;
@override@JsonKey() final  String equipment;
@override@JsonKey() final  int durationWeeks;
@override@JsonKey() final  int daysPerWeek;
@override@JsonKey() final  int estimatedMinutes;
@override@JsonKey() final  bool isCustom;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleCopyWith<_Schedule> get copyWith => __$ScheduleCopyWithImpl<_Schedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Schedule&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.targetMuscles, _targetMuscles)&&const DeepCollectionEquality().equals(other.assignedWeekdays, _assignedWeekdays)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.daysPerWeek, daysPerWeek) || other.daysPerWeek == daysPerWeek)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_targetMuscles),const DeepCollectionEquality().hash(_assignedWeekdays),orderIndex,isArchived,isFavorite,focus,experience,equipment,durationWeeks,daysPerWeek,estimatedMinutes,isCustom);
}

@override
String toString() {
    return 'Schedule(id: $id, name: $name, description: $description, targetMuscles: $targetMuscles, assignedWeekdays: $assignedWeekdays, orderIndex: $orderIndex, isArchived: $isArchived, isFavorite: $isFavorite, focus: $focus, experience: $experience, equipment: $equipment, durationWeeks: $durationWeeks, daysPerWeek: $daysPerWeek, estimatedMinutes: $estimatedMinutes, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$ScheduleCopyWith<$Res> implements $ScheduleCopyWith<$Res> {
  factory _$ScheduleCopyWith(_Schedule value, $Res Function(_Schedule) _then) = __$ScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, List<String> targetMuscles, List<int> assignedWeekdays, int orderIndex, bool isArchived, bool isFavorite, String focus, String experience, String equipment, int durationWeeks, int daysPerWeek, int estimatedMinutes, bool isCustom
});




}
/// @nodoc
class __$ScheduleCopyWithImpl<$Res>
    implements _$ScheduleCopyWith<$Res> {
  __$ScheduleCopyWithImpl(this._self, this._then);

  final _Schedule _self;
  final $Res Function(_Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? targetMuscles = null,Object? assignedWeekdays = null,Object? orderIndex = null,Object? isArchived = null,Object? isFavorite = null,Object? focus = null,Object? experience = null,Object? equipment = null,Object? durationWeeks = null,Object? daysPerWeek = null,Object? estimatedMinutes = null,Object? isCustom = null,}) {
  return _then(_Schedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetMuscles: null == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,assignedWeekdays: null == assignedWeekdays ? _self._assignedWeekdays : assignedWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,daysPerWeek: null == daysPerWeek ? _self.daysPerWeek : daysPerWeek // ignore: cast_nullable_to_non_nullable
as int,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
