// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; Equipment get equipment; MovementClassification get movementClassification; String? get mediaUrl; String? get youtubeUrl; String? get biomechanicsNotes; bool get isCustom;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Exercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.equipment, _this.equipment) || other.equipment == _this.equipment)&&(identical(other.movementClassification, _this.movementClassification) || other.movementClassification == _this.movementClassification)&&(identical(other.mediaUrl, _this.mediaUrl) || other.mediaUrl == _this.mediaUrl)&&(identical(other.youtubeUrl, _this.youtubeUrl) || other.youtubeUrl == _this.youtubeUrl)&&(identical(other.biomechanicsNotes, _this.biomechanicsNotes) || other.biomechanicsNotes == _this.biomechanicsNotes)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Exercise;
  return Object.hash(runtimeType,_this.id,_this.name,_this.equipment,_this.movementClassification,_this.mediaUrl,_this.youtubeUrl,_this.biomechanicsNotes,_this.isCustom);
}

@override
String toString() {
  final _this = this as Exercise;
  return 'Exercise(id: ${_this.id}, name: ${_this.name}, equipment: ${_this.equipment}, movementClassification: ${_this.movementClassification}, mediaUrl: ${_this.mediaUrl}, youtubeUrl: ${_this.youtubeUrl}, biomechanicsNotes: ${_this.biomechanicsNotes}, isCustom: ${_this.isCustom})';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, Equipment equipment, MovementClassification movementClassification, String? mediaUrl, String? youtubeUrl, String? biomechanicsNotes, bool isCustom
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? equipment = null,Object? movementClassification = null,Object? mediaUrl = freezed,Object? youtubeUrl = freezed,Object? biomechanicsNotes = freezed,Object? isCustom = null,}) {
  return _then(Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Equipment,movementClassification: null == movementClassification ? _self.movementClassification : movementClassification // ignore: cast_nullable_to_non_nullable
as MovementClassification,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,biomechanicsNotes: freezed == biomechanicsNotes ? _self.biomechanicsNotes : biomechanicsNotes // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Equipment equipment,  MovementClassification movementClassification,  String? mediaUrl,  String? youtubeUrl,  String? biomechanicsNotes,  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.equipment,_that.movementClassification,_that.mediaUrl,_that.youtubeUrl,_that.biomechanicsNotes,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Equipment equipment,  MovementClassification movementClassification,  String? mediaUrl,  String? youtubeUrl,  String? biomechanicsNotes,  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.equipment,_that.movementClassification,_that.mediaUrl,_that.youtubeUrl,_that.biomechanicsNotes,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Equipment equipment,  MovementClassification movementClassification,  String? mediaUrl,  String? youtubeUrl,  String? biomechanicsNotes,  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.equipment,_that.movementClassification,_that.mediaUrl,_that.youtubeUrl,_that.biomechanicsNotes,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise implements Exercise {
  const _Exercise({required this.id, required this.name, required this.equipment, required this.movementClassification, this.mediaUrl, this.youtubeUrl, this.biomechanicsNotes, this.isCustom = false});
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
@override final  Equipment equipment;
@override final  MovementClassification movementClassification;
@override final  String? mediaUrl;
@override final  String? youtubeUrl;
@override final  String? biomechanicsNotes;
@override@JsonKey() final  bool isCustom;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.movementClassification, movementClassification) || other.movementClassification == movementClassification)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.biomechanicsNotes, biomechanicsNotes) || other.biomechanicsNotes == biomechanicsNotes)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,equipment,movementClassification,mediaUrl,youtubeUrl,biomechanicsNotes,isCustom);
}

@override
String toString() {
    return 'Exercise(id: $id, name: $name, equipment: $equipment, movementClassification: $movementClassification, mediaUrl: $mediaUrl, youtubeUrl: $youtubeUrl, biomechanicsNotes: $biomechanicsNotes, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Equipment equipment, MovementClassification movementClassification, String? mediaUrl, String? youtubeUrl, String? biomechanicsNotes, bool isCustom
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? equipment = null,Object? movementClassification = null,Object? mediaUrl = freezed,Object? youtubeUrl = freezed,Object? biomechanicsNotes = freezed,Object? isCustom = null,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Equipment,movementClassification: null == movementClassification ? _self.movementClassification : movementClassification // ignore: cast_nullable_to_non_nullable
as MovementClassification,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,biomechanicsNotes: freezed == biomechanicsNotes ? _self.biomechanicsNotes : biomechanicsNotes // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
