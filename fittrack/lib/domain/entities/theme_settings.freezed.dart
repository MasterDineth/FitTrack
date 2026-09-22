// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeSettings {

@ThemeModeConverter() ThemeMode get themeMode; int get accentColorValue; bool get useDynamicAccent; bool get useOledBlack; bool get useHighContrast; bool get autoDarkWorkout; bool get keepScreenAwake;
/// Create a copy of ThemeSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeSettingsCopyWith<ThemeSettings> get copyWith => _$ThemeSettingsCopyWithImpl<ThemeSettings>(this as ThemeSettings, _$identity);

  /// Serializes this ThemeSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeSettings&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.accentColorValue, _this.accentColorValue) || other.accentColorValue == _this.accentColorValue)&&(identical(other.useDynamicAccent, _this.useDynamicAccent) || other.useDynamicAccent == _this.useDynamicAccent)&&(identical(other.useOledBlack, _this.useOledBlack) || other.useOledBlack == _this.useOledBlack)&&(identical(other.useHighContrast, _this.useHighContrast) || other.useHighContrast == _this.useHighContrast)&&(identical(other.autoDarkWorkout, _this.autoDarkWorkout) || other.autoDarkWorkout == _this.autoDarkWorkout)&&(identical(other.keepScreenAwake, _this.keepScreenAwake) || other.keepScreenAwake == _this.keepScreenAwake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeSettings;
  return Object.hash(runtimeType,_this.themeMode,_this.accentColorValue,_this.useDynamicAccent,_this.useOledBlack,_this.useHighContrast,_this.autoDarkWorkout,_this.keepScreenAwake);
}

@override
String toString() {
  final _this = this as ThemeSettings;
  return 'ThemeSettings(themeMode: ${_this.themeMode}, accentColorValue: ${_this.accentColorValue}, useDynamicAccent: ${_this.useDynamicAccent}, useOledBlack: ${_this.useOledBlack}, useHighContrast: ${_this.useHighContrast}, autoDarkWorkout: ${_this.autoDarkWorkout}, keepScreenAwake: ${_this.keepScreenAwake})';
}


}

/// @nodoc
abstract mixin class $ThemeSettingsCopyWith<$Res>  {
  factory $ThemeSettingsCopyWith(ThemeSettings value, $Res Function(ThemeSettings) _then) = _$ThemeSettingsCopyWithImpl;
@useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, int accentColorValue, bool useDynamicAccent, bool useOledBlack, bool useHighContrast, bool autoDarkWorkout, bool keepScreenAwake
});




}
/// @nodoc
class _$ThemeSettingsCopyWithImpl<$Res>
    implements $ThemeSettingsCopyWith<$Res> {
  _$ThemeSettingsCopyWithImpl(this._self, this._then);

  final ThemeSettings _self;
  final $Res Function(ThemeSettings) _then;

/// Create a copy of ThemeSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? accentColorValue = null,Object? useDynamicAccent = null,Object? useOledBlack = null,Object? useHighContrast = null,Object? autoDarkWorkout = null,Object? keepScreenAwake = null,}) {
  return _then(ThemeSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accentColorValue: null == accentColorValue ? _self.accentColorValue : accentColorValue // ignore: cast_nullable_to_non_nullable
as int,useDynamicAccent: null == useDynamicAccent ? _self.useDynamicAccent : useDynamicAccent // ignore: cast_nullable_to_non_nullable
as bool,useOledBlack: null == useOledBlack ? _self.useOledBlack : useOledBlack // ignore: cast_nullable_to_non_nullable
as bool,useHighContrast: null == useHighContrast ? _self.useHighContrast : useHighContrast // ignore: cast_nullable_to_non_nullable
as bool,autoDarkWorkout: null == autoDarkWorkout ? _self.autoDarkWorkout : autoDarkWorkout // ignore: cast_nullable_to_non_nullable
as bool,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeSettings].
extension ThemeSettingsPatterns on ThemeSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeSettings value)  $default,){
final _that = this;
switch (_that) {
case _ThemeSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  int accentColorValue,  bool useDynamicAccent,  bool useOledBlack,  bool useHighContrast,  bool autoDarkWorkout,  bool keepScreenAwake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeSettings() when $default != null:
return $default(_that.themeMode,_that.accentColorValue,_that.useDynamicAccent,_that.useOledBlack,_that.useHighContrast,_that.autoDarkWorkout,_that.keepScreenAwake);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  int accentColorValue,  bool useDynamicAccent,  bool useOledBlack,  bool useHighContrast,  bool autoDarkWorkout,  bool keepScreenAwake)  $default,) {final _that = this;
switch (_that) {
case _ThemeSettings():
return $default(_that.themeMode,_that.accentColorValue,_that.useDynamicAccent,_that.useOledBlack,_that.useHighContrast,_that.autoDarkWorkout,_that.keepScreenAwake);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ThemeModeConverter()  ThemeMode themeMode,  int accentColorValue,  bool useDynamicAccent,  bool useOledBlack,  bool useHighContrast,  bool autoDarkWorkout,  bool keepScreenAwake)?  $default,) {final _that = this;
switch (_that) {
case _ThemeSettings() when $default != null:
return $default(_that.themeMode,_that.accentColorValue,_that.useDynamicAccent,_that.useOledBlack,_that.useHighContrast,_that.autoDarkWorkout,_that.keepScreenAwake);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeSettings extends ThemeSettings {
  const _ThemeSettings({@ThemeModeConverter() this.themeMode = ThemeMode.system, this.accentColorValue = 0xFF00D68F, this.useDynamicAccent = false, this.useOledBlack = false, this.useHighContrast = false, this.autoDarkWorkout = true, this.keepScreenAwake = true}): super._();
  factory _ThemeSettings.fromJson(Map<String, dynamic> json) => _$ThemeSettingsFromJson(json);

@override@JsonKey()@ThemeModeConverter() final  ThemeMode themeMode;
@override@JsonKey() final  int accentColorValue;
@override@JsonKey() final  bool useDynamicAccent;
@override@JsonKey() final  bool useOledBlack;
@override@JsonKey() final  bool useHighContrast;
@override@JsonKey() final  bool autoDarkWorkout;
@override@JsonKey() final  bool keepScreenAwake;

/// Create a copy of ThemeSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeSettingsCopyWith<_ThemeSettings> get copyWith => __$ThemeSettingsCopyWithImpl<_ThemeSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.accentColorValue, accentColorValue) || other.accentColorValue == accentColorValue)&&(identical(other.useDynamicAccent, useDynamicAccent) || other.useDynamicAccent == useDynamicAccent)&&(identical(other.useOledBlack, useOledBlack) || other.useOledBlack == useOledBlack)&&(identical(other.useHighContrast, useHighContrast) || other.useHighContrast == useHighContrast)&&(identical(other.autoDarkWorkout, autoDarkWorkout) || other.autoDarkWorkout == autoDarkWorkout)&&(identical(other.keepScreenAwake, keepScreenAwake) || other.keepScreenAwake == keepScreenAwake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,themeMode,accentColorValue,useDynamicAccent,useOledBlack,useHighContrast,autoDarkWorkout,keepScreenAwake);
}

@override
String toString() {
    return 'ThemeSettings(themeMode: $themeMode, accentColorValue: $accentColorValue, useDynamicAccent: $useDynamicAccent, useOledBlack: $useOledBlack, useHighContrast: $useHighContrast, autoDarkWorkout: $autoDarkWorkout, keepScreenAwake: $keepScreenAwake)';
}


}

/// @nodoc
abstract mixin class _$ThemeSettingsCopyWith<$Res> implements $ThemeSettingsCopyWith<$Res> {
  factory _$ThemeSettingsCopyWith(_ThemeSettings value, $Res Function(_ThemeSettings) _then) = __$ThemeSettingsCopyWithImpl;
@override @useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, int accentColorValue, bool useDynamicAccent, bool useOledBlack, bool useHighContrast, bool autoDarkWorkout, bool keepScreenAwake
});




}
/// @nodoc
class __$ThemeSettingsCopyWithImpl<$Res>
    implements _$ThemeSettingsCopyWith<$Res> {
  __$ThemeSettingsCopyWithImpl(this._self, this._then);

  final _ThemeSettings _self;
  final $Res Function(_ThemeSettings) _then;

/// Create a copy of ThemeSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? accentColorValue = null,Object? useDynamicAccent = null,Object? useOledBlack = null,Object? useHighContrast = null,Object? autoDarkWorkout = null,Object? keepScreenAwake = null,}) {
  return _then(_ThemeSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accentColorValue: null == accentColorValue ? _self.accentColorValue : accentColorValue // ignore: cast_nullable_to_non_nullable
as int,useDynamicAccent: null == useDynamicAccent ? _self.useDynamicAccent : useDynamicAccent // ignore: cast_nullable_to_non_nullable
as bool,useOledBlack: null == useOledBlack ? _self.useOledBlack : useOledBlack // ignore: cast_nullable_to_non_nullable
as bool,useHighContrast: null == useHighContrast ? _self.useHighContrast : useHighContrast // ignore: cast_nullable_to_non_nullable
as bool,autoDarkWorkout: null == autoDarkWorkout ? _self.autoDarkWorkout : autoDarkWorkout // ignore: cast_nullable_to_non_nullable
as bool,keepScreenAwake: null == keepScreenAwake ? _self.keepScreenAwake : keepScreenAwake // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
