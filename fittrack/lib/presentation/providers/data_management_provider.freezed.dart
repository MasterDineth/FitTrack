// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_management_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DataManagementState {

 bool get isAutoBackupEnabled; bool get exportBackupBeforeDelete; List<BackupSnapshot> get snapshots; bool get isBackingUp; bool get isRestoring; String? get activeOperationMessage;
/// Create a copy of DataManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataManagementStateCopyWith<DataManagementState> get copyWith => _$DataManagementStateCopyWithImpl<DataManagementState>(this as DataManagementState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DataManagementState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataManagementState&&(identical(other.isAutoBackupEnabled, _this.isAutoBackupEnabled) || other.isAutoBackupEnabled == _this.isAutoBackupEnabled)&&(identical(other.exportBackupBeforeDelete, _this.exportBackupBeforeDelete) || other.exportBackupBeforeDelete == _this.exportBackupBeforeDelete)&&const DeepCollectionEquality().equals(other.snapshots, _this.snapshots)&&(identical(other.isBackingUp, _this.isBackingUp) || other.isBackingUp == _this.isBackingUp)&&(identical(other.isRestoring, _this.isRestoring) || other.isRestoring == _this.isRestoring)&&(identical(other.activeOperationMessage, _this.activeOperationMessage) || other.activeOperationMessage == _this.activeOperationMessage));
}


@override
int get hashCode {
  final _this = this as DataManagementState;
  return Object.hash(runtimeType,_this.isAutoBackupEnabled,_this.exportBackupBeforeDelete,const DeepCollectionEquality().hash(_this.snapshots),_this.isBackingUp,_this.isRestoring,_this.activeOperationMessage);
}

@override
String toString() {
  final _this = this as DataManagementState;
  return 'DataManagementState(isAutoBackupEnabled: ${_this.isAutoBackupEnabled}, exportBackupBeforeDelete: ${_this.exportBackupBeforeDelete}, snapshots: ${_this.snapshots}, isBackingUp: ${_this.isBackingUp}, isRestoring: ${_this.isRestoring}, activeOperationMessage: ${_this.activeOperationMessage})';
}


}

/// @nodoc
abstract mixin class $DataManagementStateCopyWith<$Res>  {
  factory $DataManagementStateCopyWith(DataManagementState value, $Res Function(DataManagementState) _then) = _$DataManagementStateCopyWithImpl;
@useResult
$Res call({
 bool isAutoBackupEnabled, bool exportBackupBeforeDelete, List<BackupSnapshot> snapshots, bool isBackingUp, bool isRestoring, String? activeOperationMessage
});




}
/// @nodoc
class _$DataManagementStateCopyWithImpl<$Res>
    implements $DataManagementStateCopyWith<$Res> {
  _$DataManagementStateCopyWithImpl(this._self, this._then);

  final DataManagementState _self;
  final $Res Function(DataManagementState) _then;

/// Create a copy of DataManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAutoBackupEnabled = null,Object? exportBackupBeforeDelete = null,Object? snapshots = null,Object? isBackingUp = null,Object? isRestoring = null,Object? activeOperationMessage = freezed,}) {
  return _then(DataManagementState(
isAutoBackupEnabled: null == isAutoBackupEnabled ? _self.isAutoBackupEnabled : isAutoBackupEnabled // ignore: cast_nullable_to_non_nullable
as bool,exportBackupBeforeDelete: null == exportBackupBeforeDelete ? _self.exportBackupBeforeDelete : exportBackupBeforeDelete // ignore: cast_nullable_to_non_nullable
as bool,snapshots: null == snapshots ? _self.snapshots : snapshots // ignore: cast_nullable_to_non_nullable
as List<BackupSnapshot>,isBackingUp: null == isBackingUp ? _self.isBackingUp : isBackingUp // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,activeOperationMessage: freezed == activeOperationMessage ? _self.activeOperationMessage : activeOperationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DataManagementState].
extension DataManagementStatePatterns on DataManagementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataManagementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataManagementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataManagementState value)  $default,){
final _that = this;
switch (_that) {
case _DataManagementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataManagementState value)?  $default,){
final _that = this;
switch (_that) {
case _DataManagementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isAutoBackupEnabled,  bool exportBackupBeforeDelete,  List<BackupSnapshot> snapshots,  bool isBackingUp,  bool isRestoring,  String? activeOperationMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataManagementState() when $default != null:
return $default(_that.isAutoBackupEnabled,_that.exportBackupBeforeDelete,_that.snapshots,_that.isBackingUp,_that.isRestoring,_that.activeOperationMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isAutoBackupEnabled,  bool exportBackupBeforeDelete,  List<BackupSnapshot> snapshots,  bool isBackingUp,  bool isRestoring,  String? activeOperationMessage)  $default,) {final _that = this;
switch (_that) {
case _DataManagementState():
return $default(_that.isAutoBackupEnabled,_that.exportBackupBeforeDelete,_that.snapshots,_that.isBackingUp,_that.isRestoring,_that.activeOperationMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isAutoBackupEnabled,  bool exportBackupBeforeDelete,  List<BackupSnapshot> snapshots,  bool isBackingUp,  bool isRestoring,  String? activeOperationMessage)?  $default,) {final _that = this;
switch (_that) {
case _DataManagementState() when $default != null:
return $default(_that.isAutoBackupEnabled,_that.exportBackupBeforeDelete,_that.snapshots,_that.isBackingUp,_that.isRestoring,_that.activeOperationMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DataManagementState implements DataManagementState {
  const _DataManagementState({this.isAutoBackupEnabled = true, this.exportBackupBeforeDelete = false,  List<BackupSnapshot> snapshots = const <BackupSnapshot>[], this.isBackingUp = false, this.isRestoring = false, this.activeOperationMessage = null}): _snapshots = snapshots;
  

@override@JsonKey() final  bool isAutoBackupEnabled;
@override@JsonKey() final  bool exportBackupBeforeDelete;
 final  List<BackupSnapshot> _snapshots;
@override@JsonKey() List<BackupSnapshot> get snapshots {
  if (_snapshots is EqualUnmodifiableListView) return _snapshots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_snapshots);
}

@override@JsonKey() final  bool isBackingUp;
@override@JsonKey() final  bool isRestoring;
@override@JsonKey() final  String? activeOperationMessage;

/// Create a copy of DataManagementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataManagementStateCopyWith<_DataManagementState> get copyWith => __$DataManagementStateCopyWithImpl<_DataManagementState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataManagementState&&(identical(other.isAutoBackupEnabled, isAutoBackupEnabled) || other.isAutoBackupEnabled == isAutoBackupEnabled)&&(identical(other.exportBackupBeforeDelete, exportBackupBeforeDelete) || other.exportBackupBeforeDelete == exportBackupBeforeDelete)&&const DeepCollectionEquality().equals(other.snapshots, _snapshots)&&(identical(other.isBackingUp, isBackingUp) || other.isBackingUp == isBackingUp)&&(identical(other.isRestoring, isRestoring) || other.isRestoring == isRestoring)&&(identical(other.activeOperationMessage, activeOperationMessage) || other.activeOperationMessage == activeOperationMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isAutoBackupEnabled,exportBackupBeforeDelete,const DeepCollectionEquality().hash(_snapshots),isBackingUp,isRestoring,activeOperationMessage);
}

@override
String toString() {
    return 'DataManagementState(isAutoBackupEnabled: $isAutoBackupEnabled, exportBackupBeforeDelete: $exportBackupBeforeDelete, snapshots: $snapshots, isBackingUp: $isBackingUp, isRestoring: $isRestoring, activeOperationMessage: $activeOperationMessage)';
}


}

/// @nodoc
abstract mixin class _$DataManagementStateCopyWith<$Res> implements $DataManagementStateCopyWith<$Res> {
  factory _$DataManagementStateCopyWith(_DataManagementState value, $Res Function(_DataManagementState) _then) = __$DataManagementStateCopyWithImpl;
@override @useResult
$Res call({
 bool isAutoBackupEnabled, bool exportBackupBeforeDelete, List<BackupSnapshot> snapshots, bool isBackingUp, bool isRestoring, String? activeOperationMessage
});




}
/// @nodoc
class __$DataManagementStateCopyWithImpl<$Res>
    implements _$DataManagementStateCopyWith<$Res> {
  __$DataManagementStateCopyWithImpl(this._self, this._then);

  final _DataManagementState _self;
  final $Res Function(_DataManagementState) _then;

/// Create a copy of DataManagementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAutoBackupEnabled = null,Object? exportBackupBeforeDelete = null,Object? snapshots = null,Object? isBackingUp = null,Object? isRestoring = null,Object? activeOperationMessage = freezed,}) {
  return _then(_DataManagementState(
isAutoBackupEnabled: null == isAutoBackupEnabled ? _self.isAutoBackupEnabled : isAutoBackupEnabled // ignore: cast_nullable_to_non_nullable
as bool,exportBackupBeforeDelete: null == exportBackupBeforeDelete ? _self.exportBackupBeforeDelete : exportBackupBeforeDelete // ignore: cast_nullable_to_non_nullable
as bool,snapshots: null == snapshots ? _self._snapshots : snapshots // ignore: cast_nullable_to_non_nullable
as List<BackupSnapshot>,isBackingUp: null == isBackingUp ? _self.isBackingUp : isBackingUp // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,activeOperationMessage: freezed == activeOperationMessage ? _self.activeOperationMessage : activeOperationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
