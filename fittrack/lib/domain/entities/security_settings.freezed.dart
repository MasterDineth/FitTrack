// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecuritySettings {

 bool get isAppLockEnabled; bool get isBiometricEnabled; bool get isPasscodeFallbackEnabled; LockTimeout get lockTimeout; bool get hideContent; bool get requireForSensitive; bool get failedAttemptsCooldown;
/// Create a copy of SecuritySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecuritySettingsCopyWith<SecuritySettings> get copyWith => _$SecuritySettingsCopyWithImpl<SecuritySettings>(this as SecuritySettings, _$identity);

  /// Serializes this SecuritySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SecuritySettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecuritySettings&&(identical(other.isAppLockEnabled, _this.isAppLockEnabled) || other.isAppLockEnabled == _this.isAppLockEnabled)&&(identical(other.isBiometricEnabled, _this.isBiometricEnabled) || other.isBiometricEnabled == _this.isBiometricEnabled)&&(identical(other.isPasscodeFallbackEnabled, _this.isPasscodeFallbackEnabled) || other.isPasscodeFallbackEnabled == _this.isPasscodeFallbackEnabled)&&(identical(other.lockTimeout, _this.lockTimeout) || other.lockTimeout == _this.lockTimeout)&&(identical(other.hideContent, _this.hideContent) || other.hideContent == _this.hideContent)&&(identical(other.requireForSensitive, _this.requireForSensitive) || other.requireForSensitive == _this.requireForSensitive)&&(identical(other.failedAttemptsCooldown, _this.failedAttemptsCooldown) || other.failedAttemptsCooldown == _this.failedAttemptsCooldown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SecuritySettings;
  return Object.hash(runtimeType,_this.isAppLockEnabled,_this.isBiometricEnabled,_this.isPasscodeFallbackEnabled,_this.lockTimeout,_this.hideContent,_this.requireForSensitive,_this.failedAttemptsCooldown);
}

@override
String toString() {
  final _this = this as SecuritySettings;
  return 'SecuritySettings(isAppLockEnabled: ${_this.isAppLockEnabled}, isBiometricEnabled: ${_this.isBiometricEnabled}, isPasscodeFallbackEnabled: ${_this.isPasscodeFallbackEnabled}, lockTimeout: ${_this.lockTimeout}, hideContent: ${_this.hideContent}, requireForSensitive: ${_this.requireForSensitive}, failedAttemptsCooldown: ${_this.failedAttemptsCooldown})';
}


}

/// @nodoc
abstract mixin class $SecuritySettingsCopyWith<$Res>  {
  factory $SecuritySettingsCopyWith(SecuritySettings value, $Res Function(SecuritySettings) _then) = _$SecuritySettingsCopyWithImpl;
@useResult
$Res call({
 bool isAppLockEnabled, bool isBiometricEnabled, bool isPasscodeFallbackEnabled, LockTimeout lockTimeout, bool hideContent, bool requireForSensitive, bool failedAttemptsCooldown
});




}
/// @nodoc
class _$SecuritySettingsCopyWithImpl<$Res>
    implements $SecuritySettingsCopyWith<$Res> {
  _$SecuritySettingsCopyWithImpl(this._self, this._then);

  final SecuritySettings _self;
  final $Res Function(SecuritySettings) _then;

/// Create a copy of SecuritySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAppLockEnabled = null,Object? isBiometricEnabled = null,Object? isPasscodeFallbackEnabled = null,Object? lockTimeout = null,Object? hideContent = null,Object? requireForSensitive = null,Object? failedAttemptsCooldown = null,}) {
  return _then(SecuritySettings(
isAppLockEnabled: null == isAppLockEnabled ? _self.isAppLockEnabled : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,isBiometricEnabled: null == isBiometricEnabled ? _self.isBiometricEnabled : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,isPasscodeFallbackEnabled: null == isPasscodeFallbackEnabled ? _self.isPasscodeFallbackEnabled : isPasscodeFallbackEnabled // ignore: cast_nullable_to_non_nullable
as bool,lockTimeout: null == lockTimeout ? _self.lockTimeout : lockTimeout // ignore: cast_nullable_to_non_nullable
as LockTimeout,hideContent: null == hideContent ? _self.hideContent : hideContent // ignore: cast_nullable_to_non_nullable
as bool,requireForSensitive: null == requireForSensitive ? _self.requireForSensitive : requireForSensitive // ignore: cast_nullable_to_non_nullable
as bool,failedAttemptsCooldown: null == failedAttemptsCooldown ? _self.failedAttemptsCooldown : failedAttemptsCooldown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SecuritySettings].
extension SecuritySettingsPatterns on SecuritySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecuritySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecuritySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecuritySettings value)  $default,){
final _that = this;
switch (_that) {
case _SecuritySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecuritySettings value)?  $default,){
final _that = this;
switch (_that) {
case _SecuritySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isAppLockEnabled,  bool isBiometricEnabled,  bool isPasscodeFallbackEnabled,  LockTimeout lockTimeout,  bool hideContent,  bool requireForSensitive,  bool failedAttemptsCooldown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecuritySettings() when $default != null:
return $default(_that.isAppLockEnabled,_that.isBiometricEnabled,_that.isPasscodeFallbackEnabled,_that.lockTimeout,_that.hideContent,_that.requireForSensitive,_that.failedAttemptsCooldown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isAppLockEnabled,  bool isBiometricEnabled,  bool isPasscodeFallbackEnabled,  LockTimeout lockTimeout,  bool hideContent,  bool requireForSensitive,  bool failedAttemptsCooldown)  $default,) {final _that = this;
switch (_that) {
case _SecuritySettings():
return $default(_that.isAppLockEnabled,_that.isBiometricEnabled,_that.isPasscodeFallbackEnabled,_that.lockTimeout,_that.hideContent,_that.requireForSensitive,_that.failedAttemptsCooldown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isAppLockEnabled,  bool isBiometricEnabled,  bool isPasscodeFallbackEnabled,  LockTimeout lockTimeout,  bool hideContent,  bool requireForSensitive,  bool failedAttemptsCooldown)?  $default,) {final _that = this;
switch (_that) {
case _SecuritySettings() when $default != null:
return $default(_that.isAppLockEnabled,_that.isBiometricEnabled,_that.isPasscodeFallbackEnabled,_that.lockTimeout,_that.hideContent,_that.requireForSensitive,_that.failedAttemptsCooldown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecuritySettings extends SecuritySettings {
  const _SecuritySettings({this.isAppLockEnabled = true, this.isBiometricEnabled = true, this.isPasscodeFallbackEnabled = true, this.lockTimeout = LockTimeout.immediate, this.hideContent = true, this.requireForSensitive = true, this.failedAttemptsCooldown = true}): super._();
  factory _SecuritySettings.fromJson(Map<String, dynamic> json) => _$SecuritySettingsFromJson(json);

@override@JsonKey() final  bool isAppLockEnabled;
@override@JsonKey() final  bool isBiometricEnabled;
@override@JsonKey() final  bool isPasscodeFallbackEnabled;
@override@JsonKey() final  LockTimeout lockTimeout;
@override@JsonKey() final  bool hideContent;
@override@JsonKey() final  bool requireForSensitive;
@override@JsonKey() final  bool failedAttemptsCooldown;

/// Create a copy of SecuritySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecuritySettingsCopyWith<_SecuritySettings> get copyWith => __$SecuritySettingsCopyWithImpl<_SecuritySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecuritySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecuritySettings&&(identical(other.isAppLockEnabled, isAppLockEnabled) || other.isAppLockEnabled == isAppLockEnabled)&&(identical(other.isBiometricEnabled, isBiometricEnabled) || other.isBiometricEnabled == isBiometricEnabled)&&(identical(other.isPasscodeFallbackEnabled, isPasscodeFallbackEnabled) || other.isPasscodeFallbackEnabled == isPasscodeFallbackEnabled)&&(identical(other.lockTimeout, lockTimeout) || other.lockTimeout == lockTimeout)&&(identical(other.hideContent, hideContent) || other.hideContent == hideContent)&&(identical(other.requireForSensitive, requireForSensitive) || other.requireForSensitive == requireForSensitive)&&(identical(other.failedAttemptsCooldown, failedAttemptsCooldown) || other.failedAttemptsCooldown == failedAttemptsCooldown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isAppLockEnabled,isBiometricEnabled,isPasscodeFallbackEnabled,lockTimeout,hideContent,requireForSensitive,failedAttemptsCooldown);
}

@override
String toString() {
    return 'SecuritySettings(isAppLockEnabled: $isAppLockEnabled, isBiometricEnabled: $isBiometricEnabled, isPasscodeFallbackEnabled: $isPasscodeFallbackEnabled, lockTimeout: $lockTimeout, hideContent: $hideContent, requireForSensitive: $requireForSensitive, failedAttemptsCooldown: $failedAttemptsCooldown)';
}


}

/// @nodoc
abstract mixin class _$SecuritySettingsCopyWith<$Res> implements $SecuritySettingsCopyWith<$Res> {
  factory _$SecuritySettingsCopyWith(_SecuritySettings value, $Res Function(_SecuritySettings) _then) = __$SecuritySettingsCopyWithImpl;
@override @useResult
$Res call({
 bool isAppLockEnabled, bool isBiometricEnabled, bool isPasscodeFallbackEnabled, LockTimeout lockTimeout, bool hideContent, bool requireForSensitive, bool failedAttemptsCooldown
});




}
/// @nodoc
class __$SecuritySettingsCopyWithImpl<$Res>
    implements _$SecuritySettingsCopyWith<$Res> {
  __$SecuritySettingsCopyWithImpl(this._self, this._then);

  final _SecuritySettings _self;
  final $Res Function(_SecuritySettings) _then;

/// Create a copy of SecuritySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAppLockEnabled = null,Object? isBiometricEnabled = null,Object? isPasscodeFallbackEnabled = null,Object? lockTimeout = null,Object? hideContent = null,Object? requireForSensitive = null,Object? failedAttemptsCooldown = null,}) {
  return _then(_SecuritySettings(
isAppLockEnabled: null == isAppLockEnabled ? _self.isAppLockEnabled : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,isBiometricEnabled: null == isBiometricEnabled ? _self.isBiometricEnabled : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,isPasscodeFallbackEnabled: null == isPasscodeFallbackEnabled ? _self.isPasscodeFallbackEnabled : isPasscodeFallbackEnabled // ignore: cast_nullable_to_non_nullable
as bool,lockTimeout: null == lockTimeout ? _self.lockTimeout : lockTimeout // ignore: cast_nullable_to_non_nullable
as LockTimeout,hideContent: null == hideContent ? _self.hideContent : hideContent // ignore: cast_nullable_to_non_nullable
as bool,requireForSensitive: null == requireForSensitive ? _self.requireForSensitive : requireForSensitive // ignore: cast_nullable_to_non_nullable
as bool,failedAttemptsCooldown: null == failedAttemptsCooldown ? _self.failedAttemptsCooldown : failedAttemptsCooldown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
