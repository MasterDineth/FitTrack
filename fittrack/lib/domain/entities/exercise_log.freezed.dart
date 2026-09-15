// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseLog {

 String get id; String get sessionId; String get exerciseId; int get orderIndex; bool get isSkipped; String? get skipReason;
/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseLogCopyWith<ExerciseLog> get copyWith => _$ExerciseLogCopyWithImpl<ExerciseLog>(this as ExerciseLog, _$identity);

  /// Serializes this ExerciseLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.orderIndex, _this.orderIndex) || other.orderIndex == _this.orderIndex)&&(identical(other.isSkipped, _this.isSkipped) || other.isSkipped == _this.isSkipped)&&(identical(other.skipReason, _this.skipReason) || other.skipReason == _this.skipReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseLog;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.exerciseId,_this.orderIndex,_this.isSkipped,_this.skipReason);
}

@override
String toString() {
  final _this = this as ExerciseLog;
  return 'ExerciseLog(id: ${_this.id}, sessionId: ${_this.sessionId}, exerciseId: ${_this.exerciseId}, orderIndex: ${_this.orderIndex}, isSkipped: ${_this.isSkipped}, skipReason: ${_this.skipReason})';
}


}

/// @nodoc
abstract mixin class $ExerciseLogCopyWith<$Res>  {
  factory $ExerciseLogCopyWith(ExerciseLog value, $Res Function(ExerciseLog) _then) = _$ExerciseLogCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String exerciseId, int orderIndex, bool isSkipped, String? skipReason
});




}
/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._self, this._then);

  final ExerciseLog _self;
  final $Res Function(ExerciseLog) _then;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? exerciseId = null,Object? orderIndex = null,Object? isSkipped = null,Object? skipReason = freezed,}) {
  return _then(ExerciseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,isSkipped: null == isSkipped ? _self.isSkipped : isSkipped // ignore: cast_nullable_to_non_nullable
as bool,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseLog].
extension ExerciseLogPatterns on ExerciseLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseLog value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseLog value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String exerciseId,  int orderIndex,  bool isSkipped,  String? skipReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.orderIndex,_that.isSkipped,_that.skipReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String exerciseId,  int orderIndex,  bool isSkipped,  String? skipReason)  $default,) {final _that = this;
switch (_that) {
case _ExerciseLog():
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.orderIndex,_that.isSkipped,_that.skipReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String exerciseId,  int orderIndex,  bool isSkipped,  String? skipReason)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.orderIndex,_that.isSkipped,_that.skipReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseLog extends ExerciseLog {
  const _ExerciseLog({required this.id, required this.sessionId, required this.exerciseId, required this.orderIndex, this.isSkipped = false, this.skipReason}): super._();
  factory _ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String exerciseId;
@override final  int orderIndex;
@override@JsonKey() final  bool isSkipped;
@override final  String? skipReason;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseLogCopyWith<_ExerciseLog> get copyWith => __$ExerciseLogCopyWithImpl<_ExerciseLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.isSkipped, isSkipped) || other.isSkipped == isSkipped)&&(identical(other.skipReason, skipReason) || other.skipReason == skipReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,exerciseId,orderIndex,isSkipped,skipReason);
}

@override
String toString() {
    return 'ExerciseLog(id: $id, sessionId: $sessionId, exerciseId: $exerciseId, orderIndex: $orderIndex, isSkipped: $isSkipped, skipReason: $skipReason)';
}


}

/// @nodoc
abstract mixin class _$ExerciseLogCopyWith<$Res> implements $ExerciseLogCopyWith<$Res> {
  factory _$ExerciseLogCopyWith(_ExerciseLog value, $Res Function(_ExerciseLog) _then) = __$ExerciseLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String exerciseId, int orderIndex, bool isSkipped, String? skipReason
});




}
/// @nodoc
class __$ExerciseLogCopyWithImpl<$Res>
    implements _$ExerciseLogCopyWith<$Res> {
  __$ExerciseLogCopyWithImpl(this._self, this._then);

  final _ExerciseLog _self;
  final $Res Function(_ExerciseLog) _then;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? exerciseId = null,Object? orderIndex = null,Object? isSkipped = null,Object? skipReason = freezed,}) {
  return _then(_ExerciseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,isSkipped: null == isSkipped ? _self.isSkipped : isSkipped // ignore: cast_nullable_to_non_nullable
as bool,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
