// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_closing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyClosing _$DailyClosingFromJson(Map<String, dynamic> json) {
  return _DailyClosing.fromJson(json);
}

/// @nodoc
mixin _$DailyClosing {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  double get exchangeRateSnapshot =>
      throw _privateConstructorUsedError; // Tasa del día congelada
  Map<String, int> get cashCountCordobas =>
      throw _privateConstructorUsedError; // {'1000': 5, '500': 2...}
  Map<String, int> get cashCountDollars =>
      throw _privateConstructorUsedError; // {'100': 1, '20': 5...}
  double get totalSystemCalculated => throw _privateConstructorUsedError;
  double get totalPhysicalCounted => throw _privateConstructorUsedError;
  double get difference => throw _privateConstructorUsedError;

  /// Serializes this DailyClosing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyClosing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyClosingCopyWith<DailyClosing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyClosingCopyWith<$Res> {
  factory $DailyClosingCopyWith(
    DailyClosing value,
    $Res Function(DailyClosing) then,
  ) = _$DailyClosingCopyWithImpl<$Res, DailyClosing>;
  @useResult
  $Res call({
    String id,
    String driverId,
    @DateTimeConverter() DateTime createdAt,
    double exchangeRateSnapshot,
    Map<String, int> cashCountCordobas,
    Map<String, int> cashCountDollars,
    double totalSystemCalculated,
    double totalPhysicalCounted,
    double difference,
  });
}

/// @nodoc
class _$DailyClosingCopyWithImpl<$Res, $Val extends DailyClosing>
    implements $DailyClosingCopyWith<$Res> {
  _$DailyClosingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyClosing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? createdAt = null,
    Object? exchangeRateSnapshot = null,
    Object? cashCountCordobas = null,
    Object? cashCountDollars = null,
    Object? totalSystemCalculated = null,
    Object? totalPhysicalCounted = null,
    Object? difference = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            driverId: null == driverId
                ? _value.driverId
                : driverId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            exchangeRateSnapshot: null == exchangeRateSnapshot
                ? _value.exchangeRateSnapshot
                : exchangeRateSnapshot // ignore: cast_nullable_to_non_nullable
                      as double,
            cashCountCordobas: null == cashCountCordobas
                ? _value.cashCountCordobas
                : cashCountCordobas // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            cashCountDollars: null == cashCountDollars
                ? _value.cashCountDollars
                : cashCountDollars // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            totalSystemCalculated: null == totalSystemCalculated
                ? _value.totalSystemCalculated
                : totalSystemCalculated // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPhysicalCounted: null == totalPhysicalCounted
                ? _value.totalPhysicalCounted
                : totalPhysicalCounted // ignore: cast_nullable_to_non_nullable
                      as double,
            difference: null == difference
                ? _value.difference
                : difference // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyClosingImplCopyWith<$Res>
    implements $DailyClosingCopyWith<$Res> {
  factory _$$DailyClosingImplCopyWith(
    _$DailyClosingImpl value,
    $Res Function(_$DailyClosingImpl) then,
  ) = __$$DailyClosingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String driverId,
    @DateTimeConverter() DateTime createdAt,
    double exchangeRateSnapshot,
    Map<String, int> cashCountCordobas,
    Map<String, int> cashCountDollars,
    double totalSystemCalculated,
    double totalPhysicalCounted,
    double difference,
  });
}

/// @nodoc
class __$$DailyClosingImplCopyWithImpl<$Res>
    extends _$DailyClosingCopyWithImpl<$Res, _$DailyClosingImpl>
    implements _$$DailyClosingImplCopyWith<$Res> {
  __$$DailyClosingImplCopyWithImpl(
    _$DailyClosingImpl _value,
    $Res Function(_$DailyClosingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyClosing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? createdAt = null,
    Object? exchangeRateSnapshot = null,
    Object? cashCountCordobas = null,
    Object? cashCountDollars = null,
    Object? totalSystemCalculated = null,
    Object? totalPhysicalCounted = null,
    Object? difference = null,
  }) {
    return _then(
      _$DailyClosingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        driverId: null == driverId
            ? _value.driverId
            : driverId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        exchangeRateSnapshot: null == exchangeRateSnapshot
            ? _value.exchangeRateSnapshot
            : exchangeRateSnapshot // ignore: cast_nullable_to_non_nullable
                  as double,
        cashCountCordobas: null == cashCountCordobas
            ? _value._cashCountCordobas
            : cashCountCordobas // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        cashCountDollars: null == cashCountDollars
            ? _value._cashCountDollars
            : cashCountDollars // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        totalSystemCalculated: null == totalSystemCalculated
            ? _value.totalSystemCalculated
            : totalSystemCalculated // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPhysicalCounted: null == totalPhysicalCounted
            ? _value.totalPhysicalCounted
            : totalPhysicalCounted // ignore: cast_nullable_to_non_nullable
                  as double,
        difference: null == difference
            ? _value.difference
            : difference // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyClosingImpl implements _DailyClosing {
  const _$DailyClosingImpl({
    required this.id,
    required this.driverId,
    @DateTimeConverter() required this.createdAt,
    required this.exchangeRateSnapshot,
    required final Map<String, int> cashCountCordobas,
    required final Map<String, int> cashCountDollars,
    required this.totalSystemCalculated,
    required this.totalPhysicalCounted,
    required this.difference,
  }) : _cashCountCordobas = cashCountCordobas,
       _cashCountDollars = cashCountDollars;

  factory _$DailyClosingImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyClosingImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  final double exchangeRateSnapshot;
  // Tasa del día congelada
  final Map<String, int> _cashCountCordobas;
  // Tasa del día congelada
  @override
  Map<String, int> get cashCountCordobas {
    if (_cashCountCordobas is EqualUnmodifiableMapView)
      return _cashCountCordobas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cashCountCordobas);
  }

  // {'1000': 5, '500': 2...}
  final Map<String, int> _cashCountDollars;
  // {'1000': 5, '500': 2...}
  @override
  Map<String, int> get cashCountDollars {
    if (_cashCountDollars is EqualUnmodifiableMapView) return _cashCountDollars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cashCountDollars);
  }

  // {'100': 1, '20': 5...}
  @override
  final double totalSystemCalculated;
  @override
  final double totalPhysicalCounted;
  @override
  final double difference;

  @override
  String toString() {
    return 'DailyClosing(id: $id, driverId: $driverId, createdAt: $createdAt, exchangeRateSnapshot: $exchangeRateSnapshot, cashCountCordobas: $cashCountCordobas, cashCountDollars: $cashCountDollars, totalSystemCalculated: $totalSystemCalculated, totalPhysicalCounted: $totalPhysicalCounted, difference: $difference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyClosingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.exchangeRateSnapshot, exchangeRateSnapshot) ||
                other.exchangeRateSnapshot == exchangeRateSnapshot) &&
            const DeepCollectionEquality().equals(
              other._cashCountCordobas,
              _cashCountCordobas,
            ) &&
            const DeepCollectionEquality().equals(
              other._cashCountDollars,
              _cashCountDollars,
            ) &&
            (identical(other.totalSystemCalculated, totalSystemCalculated) ||
                other.totalSystemCalculated == totalSystemCalculated) &&
            (identical(other.totalPhysicalCounted, totalPhysicalCounted) ||
                other.totalPhysicalCounted == totalPhysicalCounted) &&
            (identical(other.difference, difference) ||
                other.difference == difference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    driverId,
    createdAt,
    exchangeRateSnapshot,
    const DeepCollectionEquality().hash(_cashCountCordobas),
    const DeepCollectionEquality().hash(_cashCountDollars),
    totalSystemCalculated,
    totalPhysicalCounted,
    difference,
  );

  /// Create a copy of DailyClosing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyClosingImplCopyWith<_$DailyClosingImpl> get copyWith =>
      __$$DailyClosingImplCopyWithImpl<_$DailyClosingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyClosingImplToJson(this);
  }
}

abstract class _DailyClosing implements DailyClosing {
  const factory _DailyClosing({
    required final String id,
    required final String driverId,
    @DateTimeConverter() required final DateTime createdAt,
    required final double exchangeRateSnapshot,
    required final Map<String, int> cashCountCordobas,
    required final Map<String, int> cashCountDollars,
    required final double totalSystemCalculated,
    required final double totalPhysicalCounted,
    required final double difference,
  }) = _$DailyClosingImpl;

  factory _DailyClosing.fromJson(Map<String, dynamic> json) =
      _$DailyClosingImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  double get exchangeRateSnapshot; // Tasa del día congelada
  @override
  Map<String, int> get cashCountCordobas; // {'1000': 5, '500': 2...}
  @override
  Map<String, int> get cashCountDollars; // {'100': 1, '20': 5...}
  @override
  double get totalSystemCalculated;
  @override
  double get totalPhysicalCounted;
  @override
  double get difference;

  /// Create a copy of DailyClosing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyClosingImplCopyWith<_$DailyClosingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
