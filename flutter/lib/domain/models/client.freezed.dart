// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClientLocation _$ClientLocationFromJson(Map<String, dynamic> json) {
  return _ClientLocation.fromJson(json);
}

/// @nodoc
mixin _$ClientLocation {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this ClientLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientLocationCopyWith<ClientLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientLocationCopyWith<$Res> {
  factory $ClientLocationCopyWith(
    ClientLocation value,
    $Res Function(ClientLocation) then,
  ) = _$ClientLocationCopyWithImpl<$Res, ClientLocation>;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$ClientLocationCopyWithImpl<$Res, $Val extends ClientLocation>
    implements $ClientLocationCopyWith<$Res> {
  _$ClientLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _value.copyWith(
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClientLocationImplCopyWith<$Res>
    implements $ClientLocationCopyWith<$Res> {
  factory _$$ClientLocationImplCopyWith(
    _$ClientLocationImpl value,
    $Res Function(_$ClientLocationImpl) then,
  ) = __$$ClientLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$$ClientLocationImplCopyWithImpl<$Res>
    extends _$ClientLocationCopyWithImpl<$Res, _$ClientLocationImpl>
    implements _$$ClientLocationImplCopyWith<$Res> {
  __$$ClientLocationImplCopyWithImpl(
    _$ClientLocationImpl _value,
    $Res Function(_$ClientLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClientLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _$ClientLocationImpl(
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientLocationImpl implements _ClientLocation {
  const _$ClientLocationImpl({required this.lat, required this.lng});

  factory _$ClientLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientLocationImplFromJson(json);

  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'ClientLocation(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientLocationImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of ClientLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientLocationImplCopyWith<_$ClientLocationImpl> get copyWith =>
      __$$ClientLocationImplCopyWithImpl<_$ClientLocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientLocationImplToJson(this);
  }
}

abstract class _ClientLocation implements ClientLocation {
  const factory _ClientLocation({
    required final double lat,
    required final double lng,
  }) = _$ClientLocationImpl;

  factory _ClientLocation.fromJson(Map<String, dynamic> json) =
      _$ClientLocationImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of ClientLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientLocationImplCopyWith<_$ClientLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Client _$ClientFromJson(Map<String, dynamic> json) {
  return _Client.fromJson(json);
}

/// @nodoc
mixin _$Client {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get zoneId => throw _privateConstructorUsedError;
  String get subZoneId => throw _privateConstructorUsedError;
  String get assignedPreventaId => throw _privateConstructorUsedError;
  double get creditLimit => throw _privateConstructorUsedError;
  double get currentDebt => throw _privateConstructorUsedError;
  String? get sectorId => throw _privateConstructorUsedError;
  ClientLocation? get location => throw _privateConstructorUsedError;

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call({
    String id,
    String storeId,
    String name,
    String phone,
    String address,
    String zoneId,
    String subZoneId,
    String assignedPreventaId,
    double creditLimit,
    double currentDebt,
    String? sectorId,
    ClientLocation? location,
  });

  $ClientLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? phone = null,
    Object? address = null,
    Object? zoneId = null,
    Object? subZoneId = null,
    Object? assignedPreventaId = null,
    Object? creditLimit = null,
    Object? currentDebt = null,
    Object? sectorId = freezed,
    Object? location = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            zoneId: null == zoneId
                ? _value.zoneId
                : zoneId // ignore: cast_nullable_to_non_nullable
                      as String,
            subZoneId: null == subZoneId
                ? _value.subZoneId
                : subZoneId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedPreventaId: null == assignedPreventaId
                ? _value.assignedPreventaId
                : assignedPreventaId // ignore: cast_nullable_to_non_nullable
                      as String,
            creditLimit: null == creditLimit
                ? _value.creditLimit
                : creditLimit // ignore: cast_nullable_to_non_nullable
                      as double,
            currentDebt: null == currentDebt
                ? _value.currentDebt
                : currentDebt // ignore: cast_nullable_to_non_nullable
                      as double,
            sectorId: freezed == sectorId
                ? _value.sectorId
                : sectorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as ClientLocation?,
          )
          as $Val,
    );
  }

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClientLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $ClientLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClientImplCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$ClientImplCopyWith(
    _$ClientImpl value,
    $Res Function(_$ClientImpl) then,
  ) = __$$ClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String storeId,
    String name,
    String phone,
    String address,
    String zoneId,
    String subZoneId,
    String assignedPreventaId,
    double creditLimit,
    double currentDebt,
    String? sectorId,
    ClientLocation? location,
  });

  @override
  $ClientLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$ClientImplCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$ClientImpl>
    implements _$$ClientImplCopyWith<$Res> {
  __$$ClientImplCopyWithImpl(
    _$ClientImpl _value,
    $Res Function(_$ClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? phone = null,
    Object? address = null,
    Object? zoneId = null,
    Object? subZoneId = null,
    Object? assignedPreventaId = null,
    Object? creditLimit = null,
    Object? currentDebt = null,
    Object? sectorId = freezed,
    Object? location = freezed,
  }) {
    return _then(
      _$ClientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        zoneId: null == zoneId
            ? _value.zoneId
            : zoneId // ignore: cast_nullable_to_non_nullable
                  as String,
        subZoneId: null == subZoneId
            ? _value.subZoneId
            : subZoneId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedPreventaId: null == assignedPreventaId
            ? _value.assignedPreventaId
            : assignedPreventaId // ignore: cast_nullable_to_non_nullable
                  as String,
        creditLimit: null == creditLimit
            ? _value.creditLimit
            : creditLimit // ignore: cast_nullable_to_non_nullable
                  as double,
        currentDebt: null == currentDebt
            ? _value.currentDebt
            : currentDebt // ignore: cast_nullable_to_non_nullable
                  as double,
        sectorId: freezed == sectorId
            ? _value.sectorId
            : sectorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as ClientLocation?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientImpl implements _Client {
  const _$ClientImpl({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phone,
    required this.address,
    required this.zoneId,
    required this.subZoneId,
    required this.assignedPreventaId,
    required this.creditLimit,
    required this.currentDebt,
    this.sectorId,
    this.location,
  });

  factory _$ClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String address;
  @override
  final String zoneId;
  @override
  final String subZoneId;
  @override
  final String assignedPreventaId;
  @override
  final double creditLimit;
  @override
  final double currentDebt;
  @override
  final String? sectorId;
  @override
  final ClientLocation? location;

  @override
  String toString() {
    return 'Client(id: $id, storeId: $storeId, name: $name, phone: $phone, address: $address, zoneId: $zoneId, subZoneId: $subZoneId, assignedPreventaId: $assignedPreventaId, creditLimit: $creditLimit, currentDebt: $currentDebt, sectorId: $sectorId, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.subZoneId, subZoneId) ||
                other.subZoneId == subZoneId) &&
            (identical(other.assignedPreventaId, assignedPreventaId) ||
                other.assignedPreventaId == assignedPreventaId) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.currentDebt, currentDebt) ||
                other.currentDebt == currentDebt) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    storeId,
    name,
    phone,
    address,
    zoneId,
    subZoneId,
    assignedPreventaId,
    creditLimit,
    currentDebt,
    sectorId,
    location,
  );

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      __$$ClientImplCopyWithImpl<_$ClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientImplToJson(this);
  }
}

abstract class _Client implements Client {
  const factory _Client({
    required final String id,
    required final String storeId,
    required final String name,
    required final String phone,
    required final String address,
    required final String zoneId,
    required final String subZoneId,
    required final String assignedPreventaId,
    required final double creditLimit,
    required final double currentDebt,
    final String? sectorId,
    final ClientLocation? location,
  }) = _$ClientImpl;

  factory _Client.fromJson(Map<String, dynamic> json) = _$ClientImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get address;
  @override
  String get zoneId;
  @override
  String get subZoneId;
  @override
  String get assignedPreventaId;
  @override
  double get creditLimit;
  @override
  double get currentDebt;
  @override
  String? get sectorId;
  @override
  ClientLocation? get location;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
