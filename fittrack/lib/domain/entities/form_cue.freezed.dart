// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'form_cue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FormCue {

 String get id; String get exerciseId; bool get isPositive; String get description;
/// Create a copy of FormCue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormCueCopyWith<FormCue> get copyWith => _$FormCueCopyWithImpl<FormCue>(this as FormCue, _$identity);

  /// Serializes this FormCue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FormCue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FormCue&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.isPositive, _this.isPositive) || other.isPositive == _this.isPositive)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FormCue;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.isPositive,_this.description);
}

@override
String toString() {
  final _this = this as FormCue;
  return 'FormCue(id: ${_this.id}, exerciseId: ${_this.exerciseId}, isPositive: ${_this.isPositive}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $FormCueCopyWith<$Res>  {
  factory $FormCueCopyWith(FormCue value, $Res Function(FormCue) _then) = _$FormCueCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, bool isPositive, String description
});




}
/// @nodoc
class _$FormCueCopyWithImpl<$Res>
    implements $FormCueCopyWith<$Res> {
  _$FormCueCopyWithImpl(this._self, this._then);

  final FormCue _self;
  final $Res Function(FormCue) _then;

/// Create a copy of FormCue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? isPositive = null,Object? description = null,}) {
  return _then(FormCue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FormCue].
extension FormCuePatterns on FormCue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FormCue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormCue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FormCue value)  $default,){
final _that = this;
switch (_that) {
case _FormCue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FormCue value)?  $default,){
final _that = this;
switch (_that) {
case _FormCue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  bool isPositive,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormCue() when $default != null:
return $default(_that.id,_that.exerciseId,_that.isPositive,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  bool isPositive,  String description)  $default,) {final _that = this;
switch (_that) {
case _FormCue():
return $default(_that.id,_that.exerciseId,_that.isPositive,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  bool isPositive,  String description)?  $default,) {final _that = this;
switch (_that) {
case _FormCue() when $default != null:
return $default(_that.id,_that.exerciseId,_that.isPositive,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FormCue extends FormCue {
  const _FormCue({required this.id, required this.exerciseId, required this.isPositive, required this.description}): super._();
  factory _FormCue.fromJson(Map<String, dynamic> json) => _$FormCueFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  bool isPositive;
@override final  String description;

/// Create a copy of FormCue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormCueCopyWith<_FormCue> get copyWith => __$FormCueCopyWithImpl<_FormCue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FormCueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormCue&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.isPositive, isPositive) || other.isPositive == isPositive)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,isPositive,description);
}

@override
String toString() {
    return 'FormCue(id: $id, exerciseId: $exerciseId, isPositive: $isPositive, description: $description)';
}


}

/// @nodoc
abstract mixin class _$FormCueCopyWith<$Res> implements $FormCueCopyWith<$Res> {
  factory _$FormCueCopyWith(_FormCue value, $Res Function(_FormCue) _then) = __$FormCueCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, bool isPositive, String description
});




}
/// @nodoc
class __$FormCueCopyWithImpl<$Res>
    implements _$FormCueCopyWith<$Res> {
  __$FormCueCopyWithImpl(this._self, this._then);

  final _FormCue _self;
  final $Res Function(_FormCue) _then;

/// Create a copy of FormCue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? isPositive = null,Object? description = null,}) {
  return _then(_FormCue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
