// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CollectionReceipt _$CollectionReceiptFromJson(Map<String, dynamic> json) {
  return _CollectionReceipt.fromJson(json);
}

/// @nodoc
mixin _$CollectionReceipt {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get collectorId =>
      throw _privateConstructorUsedError; // Preventista or Rutero
  double get amountCordobas => throw _privateConstructorUsedError;
  double get amountDollars => throw _privateConstructorUsedError;
  double get exchangeRate => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CollectionReceipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionReceiptCopyWith<CollectionReceipt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionReceiptCopyWith<$Res> {
  factory $CollectionReceiptCopyWith(
    CollectionReceipt value,
    $Res Function(CollectionReceipt) then,
  ) = _$CollectionReceiptCopyWithImpl<$Res, CollectionReceipt>;
  @useResult
  $Res call({
    String id,
    String clientId,
    String collectorId,
    double amountCordobas,
    double amountDollars,
    double exchangeRate,
    @DateTimeConverter() DateTime createdAt,
    String? notes,
  });
}

/// @nodoc
class _$CollectionReceiptCopyWithImpl<$Res, $Val extends CollectionReceipt>
    implements $CollectionReceiptCopyWith<$Res> {
  _$CollectionReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? collectorId = null,
    Object? amountCordobas = null,
    Object? amountDollars = null,
    Object? exchangeRate = null,
    Object? createdAt = null,
    Object? notes = freezed,
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
            collectorId: null == collectorId
                ? _value.collectorId
                : collectorId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollectionReceiptImplCopyWith<$Res>
    implements $CollectionReceiptCopyWith<$Res> {
  factory _$$CollectionReceiptImplCopyWith(
    _$CollectionReceiptImpl value,
    $Res Function(_$CollectionReceiptImpl) then,
  ) = __$$CollectionReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    String collectorId,
    double amountCordobas,
    double amountDollars,
    double exchangeRate,
    @DateTimeConverter() DateTime createdAt,
    String? notes,
  });
}

/// @nodoc
class __$$CollectionReceiptImplCopyWithImpl<$Res>
    extends _$CollectionReceiptCopyWithImpl<$Res, _$CollectionReceiptImpl>
    implements _$$CollectionReceiptImplCopyWith<$Res> {
  __$$CollectionReceiptImplCopyWithImpl(
    _$CollectionReceiptImpl _value,
    $Res Function(_$CollectionReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollectionReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? collectorId = null,
    Object? amountCordobas = null,
    Object? amountDollars = null,
    Object? exchangeRate = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$CollectionReceiptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        collectorId: null == collectorId
            ? _value.collectorId
            : collectorId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionReceiptImpl implements _CollectionReceipt {
  const _$CollectionReceiptImpl({
    required this.id,
    required this.clientId,
    required this.collectorId,
    required this.amountCordobas,
    required this.amountDollars,
    required this.exchangeRate,
    @DateTimeConverter() required this.createdAt,
    this.notes,
  });

  factory _$CollectionReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionReceiptImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  final String collectorId;
  // Preventista or Rutero
  @override
  final double amountCordobas;
  @override
  final double amountDollars;
  @override
  final double exchangeRate;
  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CollectionReceipt(id: $id, clientId: $clientId, collectorId: $collectorId, amountCordobas: $amountCordobas, amountDollars: $amountDollars, exchangeRate: $exchangeRate, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionReceiptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.collectorId, collectorId) ||
                other.collectorId == collectorId) &&
            (identical(other.amountCordobas, amountCordobas) ||
                other.amountCordobas == amountCordobas) &&
            (identical(other.amountDollars, amountDollars) ||
                other.amountDollars == amountDollars) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    clientId,
    collectorId,
    amountCordobas,
    amountDollars,
    exchangeRate,
    createdAt,
    notes,
  );

  /// Create a copy of CollectionReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionReceiptImplCopyWith<_$CollectionReceiptImpl> get copyWith =>
      __$$CollectionReceiptImplCopyWithImpl<_$CollectionReceiptImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionReceiptImplToJson(this);
  }
}

abstract class _CollectionReceipt implements CollectionReceipt {
  const factory _CollectionReceipt({
    required final String id,
    required final String clientId,
    required final String collectorId,
    required final double amountCordobas,
    required final double amountDollars,
    required final double exchangeRate,
    @DateTimeConverter() required final DateTime createdAt,
    final String? notes,
  }) = _$CollectionReceiptImpl;

  factory _CollectionReceipt.fromJson(Map<String, dynamic> json) =
      _$CollectionReceiptImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  String get collectorId; // Preventista or Rutero
  @override
  double get amountCordobas;
  @override
  double get amountDollars;
  @override
  double get exchangeRate;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of CollectionReceipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionReceiptImplCopyWith<_$CollectionReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
