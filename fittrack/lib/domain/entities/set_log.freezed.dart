// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetLog {

 String get id; String get exerciseLogId; int get setNumber; int get actualReps; int get targetReps; double get actualWeightKg; double get targetWeightKg; bool get isCompleted; int get restDurationSeconds;
/// Create a copy of SetLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetLogCopyWith<SetLog> get copyWith => _$SetLogCopyWithImpl<SetLog>(this as SetLog, _$identity);

  /// Serializes this SetLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseLogId, _this.exerciseLogId) || other.exerciseLogId == _this.exerciseLogId)&&(identical(other.setNumber, _this.setNumber) || other.setNumber == _this.setNumber)&&(identical(other.actualReps, _this.actualReps) || other.actualReps == _this.actualReps)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&(identical(other.actualWeightKg, _this.actualWeightKg) || other.actualWeightKg == _this.actualWeightKg)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.isCompleted, _this.isCompleted) || other.isCompleted == _this.isCompleted)&&(identical(other.restDurationSeconds, _this.restDurationSeconds) || other.restDurationSeconds == _this.restDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetLog;
  return Object.hash(runtimeType,_this.id,_this.exerciseLogId,_this.setNumber,_this.actualReps,_this.targetReps,_this.actualWeightKg,_this.targetWeightKg,_this.isCompleted,_this.restDurationSeconds);
}

@override
String toString() {
  final _this = this as SetLog;
  return 'SetLog(id: ${_this.id}, exerciseLogId: ${_this.exerciseLogId}, setNumber: ${_this.setNumber}, actualReps: ${_this.actualReps}, targetReps: ${_this.targetReps}, actualWeightKg: ${_this.actualWeightKg}, targetWeightKg: ${_this.targetWeightKg}, isCompleted: ${_this.isCompleted}, restDurationSeconds: ${_this.restDurationSeconds})';
}


}

/// @nodoc
abstract mixin class $SetLogCopyWith<$Res>  {
  factory $SetLogCopyWith(SetLog value, $Res Function(SetLog) _then) = _$SetLogCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseLogId, int setNumber, int actualReps, int targetReps, double actualWeightKg, double targetWeightKg, bool isCompleted, int restDurationSeconds
});




}
/// @nodoc
class _$SetLogCopyWithImpl<$Res>
    implements $SetLogCopyWith<$Res> {
  _$SetLogCopyWithImpl(this._self, this._then);

  final SetLog _self;
  final $Res Function(SetLog) _then;

/// Create a copy of SetLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseLogId = null,Object? setNumber = null,Object? actualReps = null,Object? targetReps = null,Object? actualWeightKg = null,Object? targetWeightKg = null,Object? isCompleted = null,Object? restDurationSeconds = null,}) {
  return _then(SetLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseLogId: null == exerciseLogId ? _self.exerciseLogId : exerciseLogId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,actualReps: null == actualReps ? _self.actualReps : actualReps // ignore: cast_nullable_to_non_nullable
as int,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,actualWeightKg: null == actualWeightKg ? _self.actualWeightKg : actualWeightKg // ignore: cast_nullable_to_non_nullable
as double,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SetLog].
extension SetLogPatterns on SetLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetLog value)  $default,){
final _that = this;
switch (_that) {
case _SetLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetLog value)?  $default,){
final _that = this;
switch (_that) {
case _SetLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseLogId,  int setNumber,  int actualReps,  int targetReps,  double actualWeightKg,  double targetWeightKg,  bool isCompleted,  int restDurationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetLog() when $default != null:
return $default(_that.id,_that.exerciseLogId,_that.setNumber,_that.actualReps,_that.targetReps,_that.actualWeightKg,_that.targetWeightKg,_that.isCompleted,_that.restDurationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseLogId,  int setNumber,  int actualReps,  int targetReps,  double actualWeightKg,  double targetWeightKg,  bool isCompleted,  int restDurationSeconds)  $default,) {final _that = this;
switch (_that) {
case _SetLog():
return $default(_that.id,_that.exerciseLogId,_that.setNumber,_that.actualReps,_that.targetReps,_that.actualWeightKg,_that.targetWeightKg,_that.isCompleted,_that.restDurationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseLogId,  int setNumber,  int actualReps,  int targetReps,  double actualWeightKg,  double targetWeightKg,  bool isCompleted,  int restDurationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SetLog() when $default != null:
return $default(_that.id,_that.exerciseLogId,_that.setNumber,_that.actualReps,_that.targetReps,_that.actualWeightKg,_that.targetWeightKg,_that.isCompleted,_that.restDurationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetLog extends SetLog {
  const _SetLog({required this.id, required this.exerciseLogId, required this.setNumber, required this.actualReps, required this.targetReps, required this.actualWeightKg, required this.targetWeightKg, this.isCompleted = false, required this.restDurationSeconds}): super._();
  factory _SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);

@override final  String id;
@override final  String exerciseLogId;
@override final  int setNumber;
@override final  int actualReps;
@override final  int targetReps;
@override final  double actualWeightKg;
@override final  double targetWeightKg;
@override@JsonKey() final  bool isCompleted;
@override final  int restDurationSeconds;

/// Create a copy of SetLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetLogCopyWith<_SetLog> get copyWith => __$SetLogCopyWithImpl<_SetLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetLog&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseLogId, exerciseLogId) || other.exerciseLogId == exerciseLogId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.actualReps, actualReps) || other.actualReps == actualReps)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.actualWeightKg, actualWeightKg) || other.actualWeightKg == actualWeightKg)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseLogId,setNumber,actualReps,targetReps,actualWeightKg,targetWeightKg,isCompleted,restDurationSeconds);
}

@override
String toString() {
    return 'SetLog(id: $id, exerciseLogId: $exerciseLogId, setNumber: $setNumber, actualReps: $actualReps, targetReps: $targetReps, actualWeightKg: $actualWeightKg, targetWeightKg: $targetWeightKg, isCompleted: $isCompleted, restDurationSeconds: $restDurationSeconds)';
}


}

/// @nodoc
abstract mixin class _$SetLogCopyWith<$Res> implements $SetLogCopyWith<$Res> {
  factory _$SetLogCopyWith(_SetLog value, $Res Function(_SetLog) _then) = __$SetLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseLogId, int setNumber, int actualReps, int targetReps, double actualWeightKg, double targetWeightKg, bool isCompleted, int restDurationSeconds
});




}
/// @nodoc
class __$SetLogCopyWithImpl<$Res>
    implements _$SetLogCopyWith<$Res> {
  __$SetLogCopyWithImpl(this._self, this._then);

  final _SetLog _self;
  final $Res Function(_SetLog) _then;

/// Create a copy of SetLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseLogId = null,Object? setNumber = null,Object? actualReps = null,Object? targetReps = null,Object? actualWeightKg = null,Object? targetWeightKg = null,Object? isCompleted = null,Object? restDurationSeconds = null,}) {
  return _then(_SetLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseLogId: null == exerciseLogId ? _self.exerciseLogId : exerciseLogId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,actualReps: null == actualReps ? _self.actualReps : actualReps // ignore: cast_nullable_to_non_nullable
as int,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,actualWeightKg: null == actualWeightKg ? _self.actualWeightKg : actualWeightKg // ignore: cast_nullable_to_non_nullable
as double,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
