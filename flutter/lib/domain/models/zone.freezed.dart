// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Zone _$ZoneFromJson(Map<String, dynamic> json) {
  return _Zone.fromJson(json);
}

/// @nodoc
mixin _$Zone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get visitDay => throw _privateConstructorUsedError;

  /// Serializes this Zone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Zone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZoneCopyWith<Zone> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZoneCopyWith<$Res> {
  factory $ZoneCopyWith(Zone value, $Res Function(Zone) then) =
      _$ZoneCopyWithImpl<$Res, Zone>;
  @useResult
  $Res call({String id, String name, String? visitDay});
}

/// @nodoc
class _$ZoneCopyWithImpl<$Res, $Val extends Zone>
    implements $ZoneCopyWith<$Res> {
  _$ZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Zone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? visitDay = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            visitDay: freezed == visitDay
                ? _value.visitDay
                : visitDay // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ZoneImplCopyWith<$Res> implements $ZoneCopyWith<$Res> {
  factory _$$ZoneImplCopyWith(
    _$ZoneImpl value,
    $Res Function(_$ZoneImpl) then,
  ) = __$$ZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? visitDay});
}

/// @nodoc
class __$$ZoneImplCopyWithImpl<$Res>
    extends _$ZoneCopyWithImpl<$Res, _$ZoneImpl>
    implements _$$ZoneImplCopyWith<$Res> {
  __$$ZoneImplCopyWithImpl(_$ZoneImpl _value, $Res Function(_$ZoneImpl) _then)
    : super(_value, _then);

  /// Create a copy of Zone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? visitDay = freezed,
  }) {
    return _then(
      _$ZoneImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        visitDay: freezed == visitDay
            ? _value.visitDay
            : visitDay // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ZoneImpl implements _Zone {
  const _$ZoneImpl({required this.id, required this.name, this.visitDay});

  factory _$ZoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZoneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? visitDay;

  @override
  String toString() {
    return 'Zone(id: $id, name: $name, visitDay: $visitDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.visitDay, visitDay) ||
                other.visitDay == visitDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, visitDay);

  /// Create a copy of Zone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZoneImplCopyWith<_$ZoneImpl> get copyWith =>
      __$$ZoneImplCopyWithImpl<_$ZoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZoneImplToJson(this);
  }
}

abstract class _Zone implements Zone {
  const factory _Zone({
    required final String id,
    required final String name,
    final String? visitDay,
  }) = _$ZoneImpl;

  factory _Zone.fromJson(Map<String, dynamic> json) = _$ZoneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get visitDay;

  /// Create a copy of Zone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZoneImplCopyWith<_$ZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubZone _$SubZoneFromJson(Map<String, dynamic> json) {
  return _SubZone.fromJson(json);
}

/// @nodoc
mixin _$SubZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get zoneId => throw _privateConstructorUsedError;
  List<int> get deliveryDays => throw _privateConstructorUsedError;

  /// Serializes this SubZone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubZoneCopyWith<SubZone> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubZoneCopyWith<$Res> {
  factory $SubZoneCopyWith(SubZone value, $Res Function(SubZone) then) =
      _$SubZoneCopyWithImpl<$Res, SubZone>;
  @useResult
  $Res call({String id, String name, String zoneId, List<int> deliveryDays});
}

/// @nodoc
class _$SubZoneCopyWithImpl<$Res, $Val extends SubZone>
    implements $SubZoneCopyWith<$Res> {
  _$SubZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? zoneId = null,
    Object? deliveryDays = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            zoneId: null == zoneId
                ? _value.zoneId
                : zoneId // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryDays: null == deliveryDays
                ? _value.deliveryDays
                : deliveryDays // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubZoneImplCopyWith<$Res> implements $SubZoneCopyWith<$Res> {
  factory _$$SubZoneImplCopyWith(
    _$SubZoneImpl value,
    $Res Function(_$SubZoneImpl) then,
  ) = __$$SubZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String zoneId, List<int> deliveryDays});
}

/// @nodoc
class __$$SubZoneImplCopyWithImpl<$Res>
    extends _$SubZoneCopyWithImpl<$Res, _$SubZoneImpl>
    implements _$$SubZoneImplCopyWith<$Res> {
  __$$SubZoneImplCopyWithImpl(
    _$SubZoneImpl _value,
    $Res Function(_$SubZoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? zoneId = null,
    Object? deliveryDays = null,
  }) {
    return _then(
      _$SubZoneImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        zoneId: null == zoneId
            ? _value.zoneId
            : zoneId // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryDays: null == deliveryDays
            ? _value._deliveryDays
            : deliveryDays // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubZoneImpl implements _SubZone {
  const _$SubZoneImpl({
    required this.id,
    required this.name,
    required this.zoneId,
    required final List<int> deliveryDays,
  }) : _deliveryDays = deliveryDays;

  factory _$SubZoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubZoneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String zoneId;
  final List<int> _deliveryDays;
  @override
  List<int> get deliveryDays {
    if (_deliveryDays is EqualUnmodifiableListView) return _deliveryDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deliveryDays);
  }

  @override
  String toString() {
    return 'SubZone(id: $id, name: $name, zoneId: $zoneId, deliveryDays: $deliveryDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            const DeepCollectionEquality().equals(
              other._deliveryDays,
              _deliveryDays,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    zoneId,
    const DeepCollectionEquality().hash(_deliveryDays),
  );

  /// Create a copy of SubZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubZoneImplCopyWith<_$SubZoneImpl> get copyWith =>
      __$$SubZoneImplCopyWithImpl<_$SubZoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubZoneImplToJson(this);
  }
}

abstract class _SubZone implements SubZone {
  const factory _SubZone({
    required final String id,
    required final String name,
    required final String zoneId,
    required final List<int> deliveryDays,
  }) = _$SubZoneImpl;

  factory _SubZone.fromJson(Map<String, dynamic> json) = _$SubZoneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get zoneId;
  @override
  List<int> get deliveryDays;

  /// Create a copy of SubZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubZoneImplCopyWith<_$SubZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
