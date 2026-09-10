// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_activation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleActivation {

 String get id; String get exerciseId; String get muscleName; MuscleRole get role; int get intensityPercentage;
/// Create a copy of MuscleActivation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleActivationCopyWith<MuscleActivation> get copyWith => _$MuscleActivationCopyWithImpl<MuscleActivation>(this as MuscleActivation, _$identity);

  /// Serializes this MuscleActivation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MuscleActivation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleActivation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.muscleName, _this.muscleName) || other.muscleName == _this.muscleName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.intensityPercentage, _this.intensityPercentage) || other.intensityPercentage == _this.intensityPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MuscleActivation;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.muscleName,_this.role,_this.intensityPercentage);
}

@override
String toString() {
  final _this = this as MuscleActivation;
  return 'MuscleActivation(id: ${_this.id}, exerciseId: ${_this.exerciseId}, muscleName: ${_this.muscleName}, role: ${_this.role}, intensityPercentage: ${_this.intensityPercentage})';
}


}

/// @nodoc
abstract mixin class $MuscleActivationCopyWith<$Res>  {
  factory $MuscleActivationCopyWith(MuscleActivation value, $Res Function(MuscleActivation) _then) = _$MuscleActivationCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String muscleName, MuscleRole role, int intensityPercentage
});




}
/// @nodoc
class _$MuscleActivationCopyWithImpl<$Res>
    implements $MuscleActivationCopyWith<$Res> {
  _$MuscleActivationCopyWithImpl(this._self, this._then);

  final MuscleActivation _self;
  final $Res Function(MuscleActivation) _then;

/// Create a copy of MuscleActivation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? muscleName = null,Object? role = null,Object? intensityPercentage = null,}) {
  return _then(MuscleActivation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,muscleName: null == muscleName ? _self.muscleName : muscleName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MuscleRole,intensityPercentage: null == intensityPercentage ? _self.intensityPercentage : intensityPercentage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleActivation].
extension MuscleActivationPatterns on MuscleActivation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleActivation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleActivation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleActivation value)  $default,){
final _that = this;
switch (_that) {
case _MuscleActivation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleActivation value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleActivation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String muscleName,  MuscleRole role,  int intensityPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleActivation() when $default != null:
return $default(_that.id,_that.exerciseId,_that.muscleName,_that.role,_that.intensityPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String muscleName,  MuscleRole role,  int intensityPercentage)  $default,) {final _that = this;
switch (_that) {
case _MuscleActivation():
return $default(_that.id,_that.exerciseId,_that.muscleName,_that.role,_that.intensityPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String muscleName,  MuscleRole role,  int intensityPercentage)?  $default,) {final _that = this;
switch (_that) {
case _MuscleActivation() when $default != null:
return $default(_that.id,_that.exerciseId,_that.muscleName,_that.role,_that.intensityPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleActivation implements MuscleActivation {
  const _MuscleActivation({required this.id, required this.exerciseId, required this.muscleName, required this.role, required this.intensityPercentage});
  factory _MuscleActivation.fromJson(Map<String, dynamic> json) => _$MuscleActivationFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String muscleName;
@override final  MuscleRole role;
@override final  int intensityPercentage;

/// Create a copy of MuscleActivation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleActivationCopyWith<_MuscleActivation> get copyWith => __$MuscleActivationCopyWithImpl<_MuscleActivation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleActivationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleActivation&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.muscleName, muscleName) || other.muscleName == muscleName)&&(identical(other.role, role) || other.role == role)&&(identical(other.intensityPercentage, intensityPercentage) || other.intensityPercentage == intensityPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,muscleName,role,intensityPercentage);
}

@override
String toString() {
    return 'MuscleActivation(id: $id, exerciseId: $exerciseId, muscleName: $muscleName, role: $role, intensityPercentage: $intensityPercentage)';
}


}

/// @nodoc
abstract mixin class _$MuscleActivationCopyWith<$Res> implements $MuscleActivationCopyWith<$Res> {
  factory _$MuscleActivationCopyWith(_MuscleActivation value, $Res Function(_MuscleActivation) _then) = __$MuscleActivationCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String muscleName, MuscleRole role, int intensityPercentage
});




}
/// @nodoc
class __$MuscleActivationCopyWithImpl<$Res>
    implements _$MuscleActivationCopyWith<$Res> {
  __$MuscleActivationCopyWithImpl(this._self, this._then);

  final _MuscleActivation _self;
  final $Res Function(_MuscleActivation) _then;

/// Create a copy of MuscleActivation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? muscleName = null,Object? role = null,Object? intensityPercentage = null,}) {
  return _then(_MuscleActivation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,muscleName: null == muscleName ? _self.muscleName : muscleName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MuscleRole,intensityPercentage: null == intensityPercentage ? _self.intensityPercentage : intensityPercentage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
