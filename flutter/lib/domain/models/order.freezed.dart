// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  bool get isReturned => throw _privateConstructorUsedError;
  String? get returnReason => throw _privateConstructorUsedError;
  String get unitType =>
      throw _privateConstructorUsedError; // 'BULTO' or 'UNIT'
  int get scannedCount => throw _privateConstructorUsedError;
  bool get hasDiscrepancy => throw _privateConstructorUsedError;
  int? get actualQuantity => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call({
    String productId,
    String description,
    int quantity,
    double price,
    double total,
    bool isReturned,
    String? returnReason,
    String unitType,
    int scannedCount,
    bool hasDiscrepancy,
    int? actualQuantity,
  });
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? description = null,
    Object? quantity = null,
    Object? price = null,
    Object? total = null,
    Object? isReturned = null,
    Object? returnReason = freezed,
    Object? unitType = null,
    Object? scannedCount = null,
    Object? hasDiscrepancy = null,
    Object? actualQuantity = freezed,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
            isReturned: null == isReturned
                ? _value.isReturned
                : isReturned // ignore: cast_nullable_to_non_nullable
                      as bool,
            returnReason: freezed == returnReason
                ? _value.returnReason
                : returnReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            unitType: null == unitType
                ? _value.unitType
                : unitType // ignore: cast_nullable_to_non_nullable
                      as String,
            scannedCount: null == scannedCount
                ? _value.scannedCount
                : scannedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            hasDiscrepancy: null == hasDiscrepancy
                ? _value.hasDiscrepancy
                : hasDiscrepancy // ignore: cast_nullable_to_non_nullable
                      as bool,
            actualQuantity: freezed == actualQuantity
                ? _value.actualQuantity
                : actualQuantity // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
    _$OrderItemImpl value,
    $Res Function(_$OrderItemImpl) then,
  ) = __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String description,
    int quantity,
    double price,
    double total,
    bool isReturned,
    String? returnReason,
    String unitType,
    int scannedCount,
    bool hasDiscrepancy,
    int? actualQuantity,
  });
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
    _$OrderItemImpl _value,
    $Res Function(_$OrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? description = null,
    Object? quantity = null,
    Object? price = null,
    Object? total = null,
    Object? isReturned = null,
    Object? returnReason = freezed,
    Object? unitType = null,
    Object? scannedCount = null,
    Object? hasDiscrepancy = null,
    Object? actualQuantity = freezed,
  }) {
    return _then(
      _$OrderItemImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
        isReturned: null == isReturned
            ? _value.isReturned
            : isReturned // ignore: cast_nullable_to_non_nullable
                  as bool,
        returnReason: freezed == returnReason
            ? _value.returnReason
            : returnReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        unitType: null == unitType
            ? _value.unitType
            : unitType // ignore: cast_nullable_to_non_nullable
                  as String,
        scannedCount: null == scannedCount
            ? _value.scannedCount
            : scannedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        hasDiscrepancy: null == hasDiscrepancy
            ? _value.hasDiscrepancy
            : hasDiscrepancy // ignore: cast_nullable_to_non_nullable
                  as bool,
        actualQuantity: freezed == actualQuantity
            ? _value.actualQuantity
            : actualQuantity // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl({
    required this.productId,
    required this.description,
    required this.quantity,
    required this.price,
    required this.total,
    this.isReturned = false,
    this.returnReason,
    this.unitType = 'UNIT',
    this.scannedCount = 0,
    this.hasDiscrepancy = false,
    this.actualQuantity,
  });

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String description;
  @override
  final int quantity;
  @override
  final double price;
  @override
  final double total;
  @override
  @JsonKey()
  final bool isReturned;
  @override
  final String? returnReason;
  @override
  @JsonKey()
  final String unitType;
  // 'BULTO' or 'UNIT'
  @override
  @JsonKey()
  final int scannedCount;
  @override
  @JsonKey()
  final bool hasDiscrepancy;
  @override
  final int? actualQuantity;

  @override
  String toString() {
    return 'OrderItem(productId: $productId, description: $description, quantity: $quantity, price: $price, total: $total, isReturned: $isReturned, returnReason: $returnReason, unitType: $unitType, scannedCount: $scannedCount, hasDiscrepancy: $hasDiscrepancy, actualQuantity: $actualQuantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.isReturned, isReturned) ||
                other.isReturned == isReturned) &&
            (identical(other.returnReason, returnReason) ||
                other.returnReason == returnReason) &&
            (identical(other.unitType, unitType) ||
                other.unitType == unitType) &&
            (identical(other.scannedCount, scannedCount) ||
                other.scannedCount == scannedCount) &&
            (identical(other.hasDiscrepancy, hasDiscrepancy) ||
                other.hasDiscrepancy == hasDiscrepancy) &&
            (identical(other.actualQuantity, actualQuantity) ||
                other.actualQuantity == actualQuantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    description,
    quantity,
    price,
    total,
    isReturned,
    returnReason,
    unitType,
    scannedCount,
    hasDiscrepancy,
    actualQuantity,
  );

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(this);
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem({
    required final String productId,
    required final String description,
    required final int quantity,
    required final double price,
    required final double total,
    final bool isReturned,
    final String? returnReason,
    final String unitType,
    final int scannedCount,
    final bool hasDiscrepancy,
    final int? actualQuantity,
  }) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get description;
  @override
  int get quantity;
  @override
  double get price;
  @override
  double get total;
  @override
  bool get isReturned;
  @override
  String? get returnReason;
  @override
  String get unitType; // 'BULTO' or 'UNIT'
  @override
  int get scannedCount;
  @override
  bool get hasDiscrepancy;
  @override
  int? get actualQuantity;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) {
  return _PaymentInfo.fromJson(json);
}

/// @nodoc
mixin _$PaymentInfo {
  PaymentType get type => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get dueDate => throw _privateConstructorUsedError;
  double get amountCordobas => throw _privateConstructorUsedError;
  double get amountDollars => throw _privateConstructorUsedError;
  double get exchangeRate => throw _privateConstructorUsedError;

  /// Serializes this PaymentInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentInfoCopyWith<PaymentInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentInfoCopyWith<$Res> {
  factory $PaymentInfoCopyWith(
    PaymentInfo value,
    $Res Function(PaymentInfo) then,
  ) = _$PaymentInfoCopyWithImpl<$Res, PaymentInfo>;
  @useResult
  $Res call({
    PaymentType type,
    @NullableDateTimeConverter() DateTime? dueDate,
    double amountCordobas,
    double amountDollars,
    double exchangeRate,
  });
}

/// @nodoc
class _$PaymentInfoCopyWithImpl<$Res, $Val extends PaymentInfo>
    implements $PaymentInfoCopyWith<$Res> {
  _$PaymentInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? dueDate = freezed,
    Object? amountCordobas = null,
    Object? amountDollars = null,
    Object? exchangeRate = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PaymentType,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            amountCordobas: null == amountCordobas
                ? _value.amountCordobas
                : amountCordobas // ignore: cast_nullable_to_non_nullable
                      as double,
            amountDollars: null == amountDollars
                ? _value.amountDollars
                : amountDollars // ignore: cast_nullable_to_non_nullable
                      as double,
            exchangeRate: null == exchangeRate
                ? _value.exchangeRate
                : exchangeRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentInfoImplCopyWith<$Res>
    implements $PaymentInfoCopyWith<$Res> {
  factory _$$PaymentInfoImplCopyWith(
    _$PaymentInfoImpl value,
    $Res Function(_$PaymentInfoImpl) then,
  ) = __$$PaymentInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PaymentType type,
    @NullableDateTimeConverter() DateTime? dueDate,
    double amountCordobas,
    double amountDollars,
    double exchangeRate,
  });
}

/// @nodoc
class __$$PaymentInfoImplCopyWithImpl<$Res>
    extends _$PaymentInfoCopyWithImpl<$Res, _$PaymentInfoImpl>
    implements _$$PaymentInfoImplCopyWith<$Res> {
  __$$PaymentInfoImplCopyWithImpl(
    _$PaymentInfoImpl _value,
    $Res Function(_$PaymentInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? dueDate = freezed,
    Object? amountCordobas = null,
    Object? amountDollars = null,
    Object? exchangeRate = null,
  }) {
    return _then(
      _$PaymentInfoImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PaymentType,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        amountCordobas: null == amountCordobas
            ? _value.amountCordobas
            : amountCordobas // ignore: cast_nullable_to_non_nullable
                  as double,
        amountDollars: null == amountDollars
            ? _value.amountDollars
            : amountDollars // ignore: cast_nullable_to_non_nullable
                  as double,
        exchangeRate: null == exchangeRate
            ? _value.exchangeRate
            : exchangeRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentInfoImpl implements _PaymentInfo {
  const _$PaymentInfoImpl({
    required this.type,
    @NullableDateTimeConverter() this.dueDate,
    required this.amountCordobas,
    required this.amountDollars,
    required this.exchangeRate,
  });

  factory _$PaymentInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentInfoImplFromJson(json);

  @override
  final PaymentType type;
  @override
  @NullableDateTimeConverter()
  final DateTime? dueDate;
  @override
  final double amountCordobas;
  @override
  final double amountDollars;
  @override
  final double exchangeRate;

  @override
  String toString() {
    return 'PaymentInfo(type: $type, dueDate: $dueDate, amountCordobas: $amountCordobas, amountDollars: $amountDollars, exchangeRate: $exchangeRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInfoImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.amountCordobas, amountCordobas) ||
                other.amountCordobas == amountCordobas) &&
            (identical(other.amountDollars, amountDollars) ||
                other.amountDollars == amountDollars) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    dueDate,
    amountCordobas,
    amountDollars,
    exchangeRate,
  );

  /// Create a copy of PaymentInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentInfoImplCopyWith<_$PaymentInfoImpl> get copyWith =>
      __$$PaymentInfoImplCopyWithImpl<_$PaymentInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentInfoImplToJson(this);
  }
}

abstract class _PaymentInfo implements PaymentInfo {
  const factory _PaymentInfo({
    required final PaymentType type,
    @NullableDateTimeConverter() final DateTime? dueDate,
    required final double amountCordobas,
    required final double amountDollars,
    required final double exchangeRate,
  }) = _$PaymentInfoImpl;

  factory _PaymentInfo.fromJson(Map<String, dynamic> json) =
      _$PaymentInfoImpl.fromJson;

  @override
  PaymentType get type;
  @override
  @NullableDateTimeConverter()
  DateTime? get dueDate;
  @override
  double get amountCordobas;
  @override
  double get amountDollars;
  @override
  double get exchangeRate;

  /// Create a copy of PaymentInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentInfoImplCopyWith<_$PaymentInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) {
  return _DeliveryInfo.fromJson(json);
}

/// @nodoc
mixin _$DeliveryInfo {
  String get driverId => throw _privateConstructorUsedError;
  String get routeId => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get deliveredAt => throw _privateConstructorUsedError;

  /// Serializes this DeliveryInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryInfoCopyWith<DeliveryInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryInfoCopyWith<$Res> {
  factory $DeliveryInfoCopyWith(
    DeliveryInfo value,
    $Res Function(DeliveryInfo) then,
  ) = _$DeliveryInfoCopyWithImpl<$Res, DeliveryInfo>;
  @useResult
  $Res call({
    String driverId,
    String routeId,
    double lat,
    double lng,
    @NullableDateTimeConverter() DateTime? deliveredAt,
  });
}

/// @nodoc
class _$DeliveryInfoCopyWithImpl<$Res, $Val extends DeliveryInfo>
    implements $DeliveryInfoCopyWith<$Res> {
  _$DeliveryInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? routeId = null,
    Object? lat = null,
    Object? lng = null,
    Object? deliveredAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            driverId: null == driverId
                ? _value.driverId
                : driverId // ignore: cast_nullable_to_non_nullable
                      as String,
            routeId: null == routeId
                ? _value.routeId
                : routeId // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryInfoImplCopyWith<$Res>
    implements $DeliveryInfoCopyWith<$Res> {
  factory _$$DeliveryInfoImplCopyWith(
    _$DeliveryInfoImpl value,
    $Res Function(_$DeliveryInfoImpl) then,
  ) = __$$DeliveryInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String driverId,
    String routeId,
    double lat,
    double lng,
    @NullableDateTimeConverter() DateTime? deliveredAt,
  });
}

/// @nodoc
class __$$DeliveryInfoImplCopyWithImpl<$Res>
    extends _$DeliveryInfoCopyWithImpl<$Res, _$DeliveryInfoImpl>
    implements _$$DeliveryInfoImplCopyWith<$Res> {
  __$$DeliveryInfoImplCopyWithImpl(
    _$DeliveryInfoImpl _value,
    $Res Function(_$DeliveryInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? routeId = null,
    Object? lat = null,
    Object? lng = null,
    Object? deliveredAt = freezed,
  }) {
    return _then(
      _$DeliveryInfoImpl(
        driverId: null == driverId
            ? _value.driverId
            : driverId // ignore: cast_nullable_to_non_nullable
                  as String,
        routeId: null == routeId
            ? _value.routeId
            : routeId // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryInfoImpl implements _DeliveryInfo {
  const _$DeliveryInfoImpl({
    required this.driverId,
    required this.routeId,
    required this.lat,
    required this.lng,
    @NullableDateTimeConverter() this.deliveredAt,
  });

  factory _$DeliveryInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryInfoImplFromJson(json);

  @override
  final String driverId;
  @override
  final String routeId;
  @override
  final double lat;
  @override
  final double lng;
  @override
  @NullableDateTimeConverter()
  final DateTime? deliveredAt;

  @override
  String toString() {
    return 'DeliveryInfo(driverId: $driverId, routeId: $routeId, lat: $lat, lng: $lng, deliveredAt: $deliveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryInfoImpl &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, driverId, routeId, lat, lng, deliveredAt);

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      __$$DeliveryInfoImplCopyWithImpl<_$DeliveryInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryInfoImplToJson(this);
  }
}

abstract class _DeliveryInfo implements DeliveryInfo {
  const factory _DeliveryInfo({
    required final String driverId,
    required final String routeId,
    required final double lat,
    required final double lng,
    @NullableDateTimeConverter() final DateTime? deliveredAt,
  }) = _$DeliveryInfoImpl;

  factory _DeliveryInfo.fromJson(Map<String, dynamic> json) =
      _$DeliveryInfoImpl.fromJson;

  @override
  String get driverId;
  @override
  String get routeId;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @NullableDateTimeConverter()
  DateTime? get deliveredAt;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) {
  return _AuthRequest.fromJson(json);
}

/// @nodoc
mixin _$AuthRequest {
  String get requestedBy => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get requestedAt => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, approved, rejected
  String? get approvedBy => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get approvedAt => throw _privateConstructorUsedError;

  /// Serializes this AuthRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthRequestCopyWith<AuthRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthRequestCopyWith<$Res> {
  factory $AuthRequestCopyWith(
    AuthRequest value,
    $Res Function(AuthRequest) then,
  ) = _$AuthRequestCopyWithImpl<$Res, AuthRequest>;
  @useResult
  $Res call({
    String requestedBy,
    @DateTimeConverter() DateTime requestedAt,
    String reason,
    String status,
    String? approvedBy,
    @NullableDateTimeConverter() DateTime? approvedAt,
  });
}

/// @nodoc
class _$AuthRequestCopyWithImpl<$Res, $Val extends AuthRequest>
    implements $AuthRequestCopyWith<$Res> {
  _$AuthRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestedBy = null,
    Object? requestedAt = null,
    Object? reason = null,
    Object? status = null,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            requestedBy: null == requestedBy
                ? _value.requestedBy
                : requestedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthRequestImplCopyWith<$Res>
    implements $AuthRequestCopyWith<$Res> {
  factory _$$AuthRequestImplCopyWith(
    _$AuthRequestImpl value,
    $Res Function(_$AuthRequestImpl) then,
  ) = __$$AuthRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String requestedBy,
    @DateTimeConverter() DateTime requestedAt,
    String reason,
    String status,
    String? approvedBy,
    @NullableDateTimeConverter() DateTime? approvedAt,
  });
}

/// @nodoc
class __$$AuthRequestImplCopyWithImpl<$Res>
    extends _$AuthRequestCopyWithImpl<$Res, _$AuthRequestImpl>
    implements _$$AuthRequestImplCopyWith<$Res> {
  __$$AuthRequestImplCopyWithImpl(
    _$AuthRequestImpl _value,
    $Res Function(_$AuthRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestedBy = null,
    Object? requestedAt = null,
    Object? reason = null,
    Object? status = null,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(
      _$AuthRequestImpl(
        requestedBy: null == requestedBy
            ? _value.requestedBy
            : requestedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthRequestImpl implements _AuthRequest {
  const _$AuthRequestImpl({
    required this.requestedBy,
    @DateTimeConverter() required this.requestedAt,
    required this.reason,
    this.status = 'pending',
    this.approvedBy,
    @NullableDateTimeConverter() this.approvedAt,
  });

  factory _$AuthRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthRequestImplFromJson(json);

  @override
  final String requestedBy;
  @override
  @DateTimeConverter()
  final DateTime requestedAt;
  @override
  final String reason;
  @override
  @JsonKey()
  final String status;
  // pending, approved, rejected
  @override
  final String? approvedBy;
  @override
  @NullableDateTimeConverter()
  final DateTime? approvedAt;

  @override
  String toString() {
    return 'AuthRequest(requestedBy: $requestedBy, requestedAt: $requestedAt, reason: $reason, status: $status, approvedBy: $approvedBy, approvedAt: $approvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthRequestImpl &&
            (identical(other.requestedBy, requestedBy) ||
                other.requestedBy == requestedBy) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    requestedBy,
    requestedAt,
    reason,
    status,
    approvedBy,
    approvedAt,
  );

  /// Create a copy of AuthRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthRequestImplCopyWith<_$AuthRequestImpl> get copyWith =>
      __$$AuthRequestImplCopyWithImpl<_$AuthRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthRequestImplToJson(this);
  }
}

abstract class _AuthRequest implements AuthRequest {
  const factory _AuthRequest({
    required final String requestedBy,
    @DateTimeConverter() required final DateTime requestedAt,
    required final String reason,
    final String status,
    final String? approvedBy,
    @NullableDateTimeConverter() final DateTime? approvedAt,
  }) = _$AuthRequestImpl;

  factory _AuthRequest.fromJson(Map<String, dynamic> json) =
      _$AuthRequestImpl.fromJson;

  @override
  String get requestedBy;
  @override
  @DateTimeConverter()
  DateTime get requestedAt;
  @override
  String get reason;
  @override
  String get status; // pending, approved, rejected
  @override
  String? get approvedBy;
  @override
  @NullableDateTimeConverter()
  DateTime? get approvedAt;

  /// Create a copy of AuthRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthRequestImplCopyWith<_$AuthRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get sectorId =>
      throw _privateConstructorUsedError; // Inherited from client subZone
  @NullableDateTimeConverter()
  DateTime? get scheduledDeliveryDate => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  PreparationStatus get preparationStatus => throw _privateConstructorUsedError;
  String? get preparedBy => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  PaymentInfo get payment => throw _privateConstructorUsedError;
  DeliveryInfo get delivery => throw _privateConstructorUsedError;
  AuthRequest? get authRequest => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    String clientId,
    String sectorId,
    @NullableDateTimeConverter() DateTime? scheduledDeliveryDate,
    OrderStatus status,
    PreparationStatus preparationStatus,
    String? preparedBy,
    List<OrderItem> items,
    PaymentInfo payment,
    DeliveryInfo delivery,
    AuthRequest? authRequest,
    @DateTimeConverter() DateTime createdAt,
    @DateTimeConverter() DateTime updatedAt,
  });

  $PaymentInfoCopyWith<$Res> get payment;
  $DeliveryInfoCopyWith<$Res> get delivery;
  $AuthRequestCopyWith<$Res>? get authRequest;
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? sectorId = null,
    Object? scheduledDeliveryDate = freezed,
    Object? status = null,
    Object? preparationStatus = null,
    Object? preparedBy = freezed,
    Object? items = null,
    Object? payment = null,
    Object? delivery = null,
    Object? authRequest = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            sectorId: null == sectorId
                ? _value.sectorId
                : sectorId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledDeliveryDate: freezed == scheduledDeliveryDate
                ? _value.scheduledDeliveryDate
                : scheduledDeliveryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            preparationStatus: null == preparationStatus
                ? _value.preparationStatus
                : preparationStatus // ignore: cast_nullable_to_non_nullable
                      as PreparationStatus,
            preparedBy: freezed == preparedBy
                ? _value.preparedBy
                : preparedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItem>,
            payment: null == payment
                ? _value.payment
                : payment // ignore: cast_nullable_to_non_nullable
                      as PaymentInfo,
            delivery: null == delivery
                ? _value.delivery
                : delivery // ignore: cast_nullable_to_non_nullable
                      as DeliveryInfo,
            authRequest: freezed == authRequest
                ? _value.authRequest
                : authRequest // ignore: cast_nullable_to_non_nullable
                      as AuthRequest?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentInfoCopyWith<$Res> get payment {
    return $PaymentInfoCopyWith<$Res>(_value.payment, (value) {
      return _then(_value.copyWith(payment: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryInfoCopyWith<$Res> get delivery {
    return $DeliveryInfoCopyWith<$Res>(_value.delivery, (value) {
      return _then(_value.copyWith(delivery: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthRequestCopyWith<$Res>? get authRequest {
    if (_value.authRequest == null) {
      return null;
    }

    return $AuthRequestCopyWith<$Res>(_value.authRequest!, (value) {
      return _then(_value.copyWith(authRequest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    String sectorId,
    @NullableDateTimeConverter() DateTime? scheduledDeliveryDate,
    OrderStatus status,
    PreparationStatus preparationStatus,
    String? preparedBy,
    List<OrderItem> items,
    PaymentInfo payment,
    DeliveryInfo delivery,
    AuthRequest? authRequest,
    @DateTimeConverter() DateTime createdAt,
    @DateTimeConverter() DateTime updatedAt,
  });

  @override
  $PaymentInfoCopyWith<$Res> get payment;
  @override
  $DeliveryInfoCopyWith<$Res> get delivery;
  @override
  $AuthRequestCopyWith<$Res>? get authRequest;
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? sectorId = null,
    Object? scheduledDeliveryDate = freezed,
    Object? status = null,
    Object? preparationStatus = null,
    Object? preparedBy = freezed,
    Object? items = null,
    Object? payment = null,
    Object? delivery = null,
    Object? authRequest = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        sectorId: null == sectorId
            ? _value.sectorId
            : sectorId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledDeliveryDate: freezed == scheduledDeliveryDate
            ? _value.scheduledDeliveryDate
            : scheduledDeliveryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        preparationStatus: null == preparationStatus
            ? _value.preparationStatus
            : preparationStatus // ignore: cast_nullable_to_non_nullable
                  as PreparationStatus,
        preparedBy: freezed == preparedBy
            ? _value.preparedBy
            : preparedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItem>,
        payment: null == payment
            ? _value.payment
            : payment // ignore: cast_nullable_to_non_nullable
                  as PaymentInfo,
        delivery: null == delivery
            ? _value.delivery
            : delivery // ignore: cast_nullable_to_non_nullable
                  as DeliveryInfo,
        authRequest: freezed == authRequest
            ? _value.authRequest
            : authRequest // ignore: cast_nullable_to_non_nullable
                  as AuthRequest?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    required this.clientId,
    required this.sectorId,
    @NullableDateTimeConverter() this.scheduledDeliveryDate,
    required this.status,
    this.preparationStatus = PreparationStatus.pending,
    this.preparedBy,
    required final List<OrderItem> items,
    required this.payment,
    required this.delivery,
    this.authRequest,
    @DateTimeConverter() required this.createdAt,
    @DateTimeConverter() required this.updatedAt,
  }) : _items = items;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  final String sectorId;
  // Inherited from client subZone
  @override
  @NullableDateTimeConverter()
  final DateTime? scheduledDeliveryDate;
  @override
  final OrderStatus status;
  @override
  @JsonKey()
  final PreparationStatus preparationStatus;
  @override
  final String? preparedBy;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final PaymentInfo payment;
  @override
  final DeliveryInfo delivery;
  @override
  final AuthRequest? authRequest;
  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  @DateTimeConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Order(id: $id, clientId: $clientId, sectorId: $sectorId, scheduledDeliveryDate: $scheduledDeliveryDate, status: $status, preparationStatus: $preparationStatus, preparedBy: $preparedBy, items: $items, payment: $payment, delivery: $delivery, authRequest: $authRequest, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.scheduledDeliveryDate, scheduledDeliveryDate) ||
                other.scheduledDeliveryDate == scheduledDeliveryDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.preparationStatus, preparationStatus) ||
                other.preparationStatus == preparationStatus) &&
            (identical(other.preparedBy, preparedBy) ||
                other.preparedBy == preparedBy) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.payment, payment) || other.payment == payment) &&
            (identical(other.delivery, delivery) ||
                other.delivery == delivery) &&
            (identical(other.authRequest, authRequest) ||
                other.authRequest == authRequest) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    clientId,
    sectorId,
    scheduledDeliveryDate,
    status,
    preparationStatus,
    preparedBy,
    const DeepCollectionEquality().hash(_items),
    payment,
    delivery,
    authRequest,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    required final String clientId,
    required final String sectorId,
    @NullableDateTimeConverter() final DateTime? scheduledDeliveryDate,
    required final OrderStatus status,
    final PreparationStatus preparationStatus,
    final String? preparedBy,
    required final List<OrderItem> items,
    required final PaymentInfo payment,
    required final DeliveryInfo delivery,
    final AuthRequest? authRequest,
    @DateTimeConverter() required final DateTime createdAt,
    @DateTimeConverter() required final DateTime updatedAt,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  String get sectorId; // Inherited from client subZone
  @override
  @NullableDateTimeConverter()
  DateTime? get scheduledDeliveryDate;
  @override
  OrderStatus get status;
  @override
  PreparationStatus get preparationStatus;
  @override
  String? get preparedBy;
  @override
  List<OrderItem> get items;
  @override
  PaymentInfo get payment;
  @override
  DeliveryInfo get delivery;
  @override
  AuthRequest? get authRequest;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  @DateTimeConverter()
  DateTime get updatedAt;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
