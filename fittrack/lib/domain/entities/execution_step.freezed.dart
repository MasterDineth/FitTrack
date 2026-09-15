// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'execution_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExecutionStep {

 String get id; String get exerciseId; int get stepNumber; String get title; String get instructions;
/// Create a copy of ExecutionStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionStepCopyWith<ExecutionStep> get copyWith => _$ExecutionStepCopyWithImpl<ExecutionStep>(this as ExecutionStep, _$identity);

  /// Serializes this ExecutionStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExecutionStep;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionStep&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.stepNumber, _this.stepNumber) || other.stepNumber == _this.stepNumber)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExecutionStep;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.stepNumber,_this.title,_this.instructions);
}

@override
String toString() {
  final _this = this as ExecutionStep;
  return 'ExecutionStep(id: ${_this.id}, exerciseId: ${_this.exerciseId}, stepNumber: ${_this.stepNumber}, title: ${_this.title}, instructions: ${_this.instructions})';
}


}

/// @nodoc
abstract mixin class $ExecutionStepCopyWith<$Res>  {
  factory $ExecutionStepCopyWith(ExecutionStep value, $Res Function(ExecutionStep) _then) = _$ExecutionStepCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int stepNumber, String title, String instructions
});




}
/// @nodoc
class _$ExecutionStepCopyWithImpl<$Res>
    implements $ExecutionStepCopyWith<$Res> {
  _$ExecutionStepCopyWithImpl(this._self, this._then);

  final ExecutionStep _self;
  final $Res Function(ExecutionStep) _then;

/// Create a copy of ExecutionStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? stepNumber = null,Object? title = null,Object? instructions = null,}) {
  return _then(ExecutionStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,stepNumber: null == stepNumber ? _self.stepNumber : stepNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExecutionStep].
extension ExecutionStepPatterns on ExecutionStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionStep value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionStep value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int stepNumber,  String title,  String instructions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionStep() when $default != null:
return $default(_that.id,_that.exerciseId,_that.stepNumber,_that.title,_that.instructions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int stepNumber,  String title,  String instructions)  $default,) {final _that = this;
switch (_that) {
case _ExecutionStep():
return $default(_that.id,_that.exerciseId,_that.stepNumber,_that.title,_that.instructions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int stepNumber,  String title,  String instructions)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionStep() when $default != null:
return $default(_that.id,_that.exerciseId,_that.stepNumber,_that.title,_that.instructions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExecutionStep extends ExecutionStep {
  const _ExecutionStep({required this.id, required this.exerciseId, required this.stepNumber, required this.title, required this.instructions}): super._();
  factory _ExecutionStep.fromJson(Map<String, dynamic> json) => _$ExecutionStepFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  int stepNumber;
@override final  String title;
@override final  String instructions;

/// Create a copy of ExecutionStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionStepCopyWith<_ExecutionStep> get copyWith => __$ExecutionStepCopyWithImpl<_ExecutionStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExecutionStepToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionStep&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.stepNumber, stepNumber) || other.stepNumber == stepNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,stepNumber,title,instructions);
}

@override
String toString() {
    return 'ExecutionStep(id: $id, exerciseId: $exerciseId, stepNumber: $stepNumber, title: $title, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class _$ExecutionStepCopyWith<$Res> implements $ExecutionStepCopyWith<$Res> {
  factory _$ExecutionStepCopyWith(_ExecutionStep value, $Res Function(_ExecutionStep) _then) = __$ExecutionStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int stepNumber, String title, String instructions
});




}
/// @nodoc
class __$ExecutionStepCopyWithImpl<$Res>
    implements _$ExecutionStepCopyWith<$Res> {
  __$ExecutionStepCopyWithImpl(this._self, this._then);

  final _ExecutionStep _self;
  final $Res Function(_ExecutionStep) _then;

/// Create a copy of ExecutionStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? stepNumber = null,Object? title = null,Object? instructions = null,}) {
  return _then(_ExecutionStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,stepNumber: null == stepNumber ? _self.stepNumber : stepNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
