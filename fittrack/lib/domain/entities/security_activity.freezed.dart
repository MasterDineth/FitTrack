// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecurityActivity {

 String get id; String get title; String get timestamp; String get deviceInfo; String get location; String get statusBadge;
/// Create a copy of SecurityActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecurityActivityCopyWith<SecurityActivity> get copyWith => _$SecurityActivityCopyWithImpl<SecurityActivity>(this as SecurityActivity, _$identity);

  /// Serializes this SecurityActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SecurityActivity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecurityActivity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.deviceInfo, _this.deviceInfo) || other.deviceInfo == _this.deviceInfo)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.statusBadge, _this.statusBadge) || other.statusBadge == _this.statusBadge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SecurityActivity;
  return Object.hash(runtimeType,_this.id,_this.title,_this.timestamp,_this.deviceInfo,_this.location,_this.statusBadge);
}

@override
String toString() {
  final _this = this as SecurityActivity;
  return 'SecurityActivity(id: ${_this.id}, title: ${_this.title}, timestamp: ${_this.timestamp}, deviceInfo: ${_this.deviceInfo}, location: ${_this.location}, statusBadge: ${_this.statusBadge})';
}


}

/// @nodoc
abstract mixin class $SecurityActivityCopyWith<$Res>  {
  factory $SecurityActivityCopyWith(SecurityActivity value, $Res Function(SecurityActivity) _then) = _$SecurityActivityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String timestamp, String deviceInfo, String location, String statusBadge
});




}
/// @nodoc
class _$SecurityActivityCopyWithImpl<$Res>
    implements $SecurityActivityCopyWith<$Res> {
  _$SecurityActivityCopyWithImpl(this._self, this._then);

  final SecurityActivity _self;
  final $Res Function(SecurityActivity) _then;

/// Create a copy of SecurityActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? timestamp = null,Object? deviceInfo = null,Object? location = null,Object? statusBadge = null,}) {
  return _then(SecurityActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,statusBadge: null == statusBadge ? _self.statusBadge : statusBadge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SecurityActivity].
extension SecurityActivityPatterns on SecurityActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecurityActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecurityActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecurityActivity value)  $default,){
final _that = this;
switch (_that) {
case _SecurityActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecurityActivity value)?  $default,){
final _that = this;
switch (_that) {
case _SecurityActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String timestamp,  String deviceInfo,  String location,  String statusBadge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecurityActivity() when $default != null:
return $default(_that.id,_that.title,_that.timestamp,_that.deviceInfo,_that.location,_that.statusBadge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String timestamp,  String deviceInfo,  String location,  String statusBadge)  $default,) {final _that = this;
switch (_that) {
case _SecurityActivity():
return $default(_that.id,_that.title,_that.timestamp,_that.deviceInfo,_that.location,_that.statusBadge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String timestamp,  String deviceInfo,  String location,  String statusBadge)?  $default,) {final _that = this;
switch (_that) {
case _SecurityActivity() when $default != null:
return $default(_that.id,_that.title,_that.timestamp,_that.deviceInfo,_that.location,_that.statusBadge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecurityActivity extends SecurityActivity {
  const _SecurityActivity({required this.id, required this.title, required this.timestamp, required this.deviceInfo, required this.location, required this.statusBadge}): super._();
  factory _SecurityActivity.fromJson(Map<String, dynamic> json) => _$SecurityActivityFromJson(json);

@override final  String id;
@override final  String title;
@override final  String timestamp;
@override final  String deviceInfo;
@override final  String location;
@override final  String statusBadge;

/// Create a copy of SecurityActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecurityActivityCopyWith<_SecurityActivity> get copyWith => __$SecurityActivityCopyWithImpl<_SecurityActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecurityActivityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecurityActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.location, location) || other.location == location)&&(identical(other.statusBadge, statusBadge) || other.statusBadge == statusBadge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,timestamp,deviceInfo,location,statusBadge);
}

@override
String toString() {
    return 'SecurityActivity(id: $id, title: $title, timestamp: $timestamp, deviceInfo: $deviceInfo, location: $location, statusBadge: $statusBadge)';
}


}

/// @nodoc
abstract mixin class _$SecurityActivityCopyWith<$Res> implements $SecurityActivityCopyWith<$Res> {
  factory _$SecurityActivityCopyWith(_SecurityActivity value, $Res Function(_SecurityActivity) _then) = __$SecurityActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String timestamp, String deviceInfo, String location, String statusBadge
});




}
/// @nodoc
class __$SecurityActivityCopyWithImpl<$Res>
    implements _$SecurityActivityCopyWith<$Res> {
  __$SecurityActivityCopyWithImpl(this._self, this._then);

  final _SecurityActivity _self;
  final $Res Function(_SecurityActivity) _then;

/// Create a copy of SecurityActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? timestamp = null,Object? deviceInfo = null,Object? location = null,Object? statusBadge = null,}) {
  return _then(_SecurityActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,deviceInfo: null == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,statusBadge: null == statusBadge ? _self.statusBadge : statusBadge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
