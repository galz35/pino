// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get barcode => throw _privateConstructorUsedError;
  double get price1 => throw _privateConstructorUsedError; // Public Price
  double get price2 => throw _privateConstructorUsedError; // Client Price
  double get price3 => throw _privateConstructorUsedError; // Mayorista
  double get price4 =>
      throw _privateConstructorUsedError; // Super Mayorista (Restricted)
  double get price5 =>
      throw _privateConstructorUsedError; // Distribuidor (Restricted)
  double? get salePrice =>
      throw _privateConstructorUsedError; // Base Sale Price (Web compatibility)
  double get costPrice => throw _privateConstructorUsedError;
  int get currentStock => throw _privateConstructorUsedError;
  bool get usesInventory => throw _privateConstructorUsedError;
  String get packagingType =>
      throw _privateConstructorUsedError; // 'BULTO' or 'UNIT'
  int get unitsPerBulto => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    String storeId,
    String description,
    String barcode,
    double price1,
    double price2,
    double price3,
    double price4,
    double price5,
    double? salePrice,
    double costPrice,
    int currentStock,
    bool usesInventory,
    String packagingType,
    int unitsPerBulto,
    String? imageUrl,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? description = null,
    Object? barcode = null,
    Object? price1 = null,
    Object? price2 = null,
    Object? price3 = null,
    Object? price4 = null,
    Object? price5 = null,
    Object? salePrice = freezed,
    Object? costPrice = null,
    Object? currentStock = null,
    Object? usesInventory = null,
    Object? packagingType = null,
    Object? unitsPerBulto = null,
    Object? imageUrl = freezed,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            barcode: null == barcode
                ? _value.barcode
                : barcode // ignore: cast_nullable_to_non_nullable
                      as String,
            price1: null == price1
                ? _value.price1
                : price1 // ignore: cast_nullable_to_non_nullable
                      as double,
            price2: null == price2
                ? _value.price2
                : price2 // ignore: cast_nullable_to_non_nullable
                      as double,
            price3: null == price3
                ? _value.price3
                : price3 // ignore: cast_nullable_to_non_nullable
                      as double,
            price4: null == price4
                ? _value.price4
                : price4 // ignore: cast_nullable_to_non_nullable
                      as double,
            price5: null == price5
                ? _value.price5
                : price5 // ignore: cast_nullable_to_non_nullable
                      as double,
            salePrice: freezed == salePrice
                ? _value.salePrice
                : salePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            costPrice: null == costPrice
                ? _value.costPrice
                : costPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            currentStock: null == currentStock
                ? _value.currentStock
                : currentStock // ignore: cast_nullable_to_non_nullable
                      as int,
            usesInventory: null == usesInventory
                ? _value.usesInventory
                : usesInventory // ignore: cast_nullable_to_non_nullable
                      as bool,
            packagingType: null == packagingType
                ? _value.packagingType
                : packagingType // ignore: cast_nullable_to_non_nullable
                      as String,
            unitsPerBulto: null == unitsPerBulto
                ? _value.unitsPerBulto
                : unitsPerBulto // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String storeId,
    String description,
    String barcode,
    double price1,
    double price2,
    double price3,
    double price4,
    double price5,
    double? salePrice,
    double costPrice,
    int currentStock,
    bool usesInventory,
    String packagingType,
    int unitsPerBulto,
    String? imageUrl,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? description = null,
    Object? barcode = null,
    Object? price1 = null,
    Object? price2 = null,
    Object? price3 = null,
    Object? price4 = null,
    Object? price5 = null,
    Object? salePrice = freezed,
    Object? costPrice = null,
    Object? currentStock = null,
    Object? usesInventory = null,
    Object? packagingType = null,
    Object? unitsPerBulto = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        barcode: null == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String,
        price1: null == price1
            ? _value.price1
            : price1 // ignore: cast_nullable_to_non_nullable
                  as double,
        price2: null == price2
            ? _value.price2
            : price2 // ignore: cast_nullable_to_non_nullable
                  as double,
        price3: null == price3
            ? _value.price3
            : price3 // ignore: cast_nullable_to_non_nullable
                  as double,
        price4: null == price4
            ? _value.price4
            : price4 // ignore: cast_nullable_to_non_nullable
                  as double,
        price5: null == price5
            ? _value.price5
            : price5 // ignore: cast_nullable_to_non_nullable
                  as double,
        salePrice: freezed == salePrice
            ? _value.salePrice
            : salePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        costPrice: null == costPrice
            ? _value.costPrice
            : costPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        currentStock: null == currentStock
            ? _value.currentStock
            : currentStock // ignore: cast_nullable_to_non_nullable
                  as int,
        usesInventory: null == usesInventory
            ? _value.usesInventory
            : usesInventory // ignore: cast_nullable_to_non_nullable
                  as bool,
        packagingType: null == packagingType
            ? _value.packagingType
            : packagingType // ignore: cast_nullable_to_non_nullable
                  as String,
        unitsPerBulto: null == unitsPerBulto
            ? _value.unitsPerBulto
            : unitsPerBulto // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl extends _Product {
  const _$ProductImpl({
    required this.id,
    required this.storeId,
    required this.description,
    required this.barcode,
    required this.price1,
    required this.price2,
    required this.price3,
    required this.price4,
    required this.price5,
    this.salePrice,
    required this.costPrice,
    required this.currentStock,
    required this.usesInventory,
    this.packagingType = 'UNIT',
    this.unitsPerBulto = 1,
    this.imageUrl,
  }) : super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String description;
  @override
  final String barcode;
  @override
  final double price1;
  // Public Price
  @override
  final double price2;
  // Client Price
  @override
  final double price3;
  // Mayorista
  @override
  final double price4;
  // Super Mayorista (Restricted)
  @override
  final double price5;
  // Distribuidor (Restricted)
  @override
  final double? salePrice;
  // Base Sale Price (Web compatibility)
  @override
  final double costPrice;
  @override
  final int currentStock;
  @override
  final bool usesInventory;
  @override
  @JsonKey()
  final String packagingType;
  // 'BULTO' or 'UNIT'
  @override
  @JsonKey()
  final int unitsPerBulto;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'Product(id: $id, storeId: $storeId, description: $description, barcode: $barcode, price1: $price1, price2: $price2, price3: $price3, price4: $price4, price5: $price5, salePrice: $salePrice, costPrice: $costPrice, currentStock: $currentStock, usesInventory: $usesInventory, packagingType: $packagingType, unitsPerBulto: $unitsPerBulto, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.price1, price1) || other.price1 == price1) &&
            (identical(other.price2, price2) || other.price2 == price2) &&
            (identical(other.price3, price3) || other.price3 == price3) &&
            (identical(other.price4, price4) || other.price4 == price4) &&
            (identical(other.price5, price5) || other.price5 == price5) &&
            (identical(other.salePrice, salePrice) ||
                other.salePrice == salePrice) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.usesInventory, usesInventory) ||
                other.usesInventory == usesInventory) &&
            (identical(other.packagingType, packagingType) ||
                other.packagingType == packagingType) &&
            (identical(other.unitsPerBulto, unitsPerBulto) ||
                other.unitsPerBulto == unitsPerBulto) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    storeId,
    description,
    barcode,
    price1,
    price2,
    price3,
    price4,
    price5,
    salePrice,
    costPrice,
    currentStock,
    usesInventory,
    packagingType,
    unitsPerBulto,
    imageUrl,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product extends Product {
  const factory _Product({
    required final String id,
    required final String storeId,
    required final String description,
    required final String barcode,
    required final double price1,
    required final double price2,
    required final double price3,
    required final double price4,
    required final double price5,
    final double? salePrice,
    required final double costPrice,
    required final int currentStock,
    required final bool usesInventory,
    final String packagingType,
    final int unitsPerBulto,
    final String? imageUrl,
  }) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get description;
  @override
  String get barcode;
  @override
  double get price1; // Public Price
  @override
  double get price2; // Client Price
  @override
  double get price3; // Mayorista
  @override
  double get price4; // Super Mayorista (Restricted)
  @override
  double get price5; // Distribuidor (Restricted)
  @override
  double? get salePrice; // Base Sale Price (Web compatibility)
  @override
  double get costPrice;
  @override
  int get currentStock;
  @override
  bool get usesInventory;
  @override
  String get packagingType; // 'BULTO' or 'UNIT'
  @override
  int get unitsPerBulto;
  @override
  String? get imageUrl;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
