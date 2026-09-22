// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackupSnapshot {

 String get id; String get title; String get date; String get time; String get size; bool get isLatest;
/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupSnapshotCopyWith<BackupSnapshot> get copyWith => _$BackupSnapshotCopyWithImpl<BackupSnapshot>(this as BackupSnapshot, _$identity);

  /// Serializes this BackupSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BackupSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupSnapshot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.isLatest, _this.isLatest) || other.isLatest == _this.isLatest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BackupSnapshot;
  return Object.hash(runtimeType,_this.id,_this.title,_this.date,_this.time,_this.size,_this.isLatest);
}

@override
String toString() {
  final _this = this as BackupSnapshot;
  return 'BackupSnapshot(id: ${_this.id}, title: ${_this.title}, date: ${_this.date}, time: ${_this.time}, size: ${_this.size}, isLatest: ${_this.isLatest})';
}


}

/// @nodoc
abstract mixin class $BackupSnapshotCopyWith<$Res>  {
  factory $BackupSnapshotCopyWith(BackupSnapshot value, $Res Function(BackupSnapshot) _then) = _$BackupSnapshotCopyWithImpl;
@useResult
$Res call({
 String id, String title, String date, String time, String size, bool isLatest
});




}
/// @nodoc
class _$BackupSnapshotCopyWithImpl<$Res>
    implements $BackupSnapshotCopyWith<$Res> {
  _$BackupSnapshotCopyWithImpl(this._self, this._then);

  final BackupSnapshot _self;
  final $Res Function(BackupSnapshot) _then;

/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? time = null,Object? size = null,Object? isLatest = null,}) {
  return _then(BackupSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,isLatest: null == isLatest ? _self.isLatest : isLatest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupSnapshot].
extension BackupSnapshotPatterns on BackupSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _BackupSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String date,  String time,  String size,  bool isLatest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.time,_that.size,_that.isLatest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String date,  String time,  String size,  bool isLatest)  $default,) {final _that = this;
switch (_that) {
case _BackupSnapshot():
return $default(_that.id,_that.title,_that.date,_that.time,_that.size,_that.isLatest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String date,  String time,  String size,  bool isLatest)?  $default,) {final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.time,_that.size,_that.isLatest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BackupSnapshot extends BackupSnapshot {
  const _BackupSnapshot({required this.id, required this.title, required this.date, required this.time, required this.size, this.isLatest = false}): super._();
  factory _BackupSnapshot.fromJson(Map<String, dynamic> json) => _$BackupSnapshotFromJson(json);

@override final  String id;
@override final  String title;
@override final  String date;
@override final  String time;
@override final  String size;
@override@JsonKey() final  bool isLatest;

/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupSnapshotCopyWith<_BackupSnapshot> get copyWith => __$BackupSnapshotCopyWithImpl<_BackupSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BackupSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.size, size) || other.size == size)&&(identical(other.isLatest, isLatest) || other.isLatest == isLatest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,date,time,size,isLatest);
}

@override
String toString() {
    return 'BackupSnapshot(id: $id, title: $title, date: $date, time: $time, size: $size, isLatest: $isLatest)';
}


}

/// @nodoc
abstract mixin class _$BackupSnapshotCopyWith<$Res> implements $BackupSnapshotCopyWith<$Res> {
  factory _$BackupSnapshotCopyWith(_BackupSnapshot value, $Res Function(_BackupSnapshot) _then) = __$BackupSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String date, String time, String size, bool isLatest
});




}
/// @nodoc
class __$BackupSnapshotCopyWithImpl<$Res>
    implements _$BackupSnapshotCopyWith<$Res> {
  __$BackupSnapshotCopyWithImpl(this._self, this._then);

  final _BackupSnapshot _self;
  final $Res Function(_BackupSnapshot) _then;

/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? time = null,Object? size = null,Object? isLatest = null,}) {
  return _then(_BackupSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,isLatest: null == isLatest ? _self.isLatest : isLatest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
