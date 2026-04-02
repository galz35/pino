// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_dashboard_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalesDashboardData {
  double get currentMonthTotal => throw _privateConstructorUsedError;
  double get previousMonthTotal => throw _privateConstructorUsedError;
  int get ordersCount => throw _privateConstructorUsedError;
  List<Order> get recentOrders => throw _privateConstructorUsedError;
  double get growthPercentage => throw _privateConstructorUsedError;
  List<Client> get todaysVisits => throw _privateConstructorUsedError;
  List<Client> get pendingVisits => throw _privateConstructorUsedError;
  List<VisitLog> get todaysLogs => throw _privateConstructorUsedError;

  /// Create a copy of SalesDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesDashboardDataCopyWith<SalesDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesDashboardDataCopyWith<$Res> {
  factory $SalesDashboardDataCopyWith(
    SalesDashboardData value,
    $Res Function(SalesDashboardData) then,
  ) = _$SalesDashboardDataCopyWithImpl<$Res, SalesDashboardData>;
  @useResult
  $Res call({
    double currentMonthTotal,
    double previousMonthTotal,
    int ordersCount,
    List<Order> recentOrders,
    double growthPercentage,
    List<Client> todaysVisits,
    List<Client> pendingVisits,
    List<VisitLog> todaysLogs,
  });
}

/// @nodoc
class _$SalesDashboardDataCopyWithImpl<$Res, $Val extends SalesDashboardData>
    implements $SalesDashboardDataCopyWith<$Res> {
  _$SalesDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentMonthTotal = null,
    Object? previousMonthTotal = null,
    Object? ordersCount = null,
    Object? recentOrders = null,
    Object? growthPercentage = null,
    Object? todaysVisits = null,
    Object? pendingVisits = null,
    Object? todaysLogs = null,
  }) {
    return _then(
      _value.copyWith(
            currentMonthTotal: null == currentMonthTotal
                ? _value.currentMonthTotal
                : currentMonthTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            previousMonthTotal: null == previousMonthTotal
                ? _value.previousMonthTotal
                : previousMonthTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            ordersCount: null == ordersCount
                ? _value.ordersCount
                : ordersCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentOrders: null == recentOrders
                ? _value.recentOrders
                : recentOrders // ignore: cast_nullable_to_non_nullable
                      as List<Order>,
            growthPercentage: null == growthPercentage
                ? _value.growthPercentage
                : growthPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            todaysVisits: null == todaysVisits
                ? _value.todaysVisits
                : todaysVisits // ignore: cast_nullable_to_non_nullable
                      as List<Client>,
            pendingVisits: null == pendingVisits
                ? _value.pendingVisits
                : pendingVisits // ignore: cast_nullable_to_non_nullable
                      as List<Client>,
            todaysLogs: null == todaysLogs
                ? _value.todaysLogs
                : todaysLogs // ignore: cast_nullable_to_non_nullable
                      as List<VisitLog>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesDashboardDataImplCopyWith<$Res>
    implements $SalesDashboardDataCopyWith<$Res> {
  factory _$$SalesDashboardDataImplCopyWith(
    _$SalesDashboardDataImpl value,
    $Res Function(_$SalesDashboardDataImpl) then,
  ) = __$$SalesDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double currentMonthTotal,
    double previousMonthTotal,
    int ordersCount,
    List<Order> recentOrders,
    double growthPercentage,
    List<Client> todaysVisits,
    List<Client> pendingVisits,
    List<VisitLog> todaysLogs,
  });
}

/// @nodoc
class __$$SalesDashboardDataImplCopyWithImpl<$Res>
    extends _$SalesDashboardDataCopyWithImpl<$Res, _$SalesDashboardDataImpl>
    implements _$$SalesDashboardDataImplCopyWith<$Res> {
  __$$SalesDashboardDataImplCopyWithImpl(
    _$SalesDashboardDataImpl _value,
    $Res Function(_$SalesDashboardDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentMonthTotal = null,
    Object? previousMonthTotal = null,
    Object? ordersCount = null,
    Object? recentOrders = null,
    Object? growthPercentage = null,
    Object? todaysVisits = null,
    Object? pendingVisits = null,
    Object? todaysLogs = null,
  }) {
    return _then(
      _$SalesDashboardDataImpl(
        currentMonthTotal: null == currentMonthTotal
            ? _value.currentMonthTotal
            : currentMonthTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        previousMonthTotal: null == previousMonthTotal
            ? _value.previousMonthTotal
            : previousMonthTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        ordersCount: null == ordersCount
            ? _value.ordersCount
            : ordersCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentOrders: null == recentOrders
            ? _value._recentOrders
            : recentOrders // ignore: cast_nullable_to_non_nullable
                  as List<Order>,
        growthPercentage: null == growthPercentage
            ? _value.growthPercentage
            : growthPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        todaysVisits: null == todaysVisits
            ? _value._todaysVisits
            : todaysVisits // ignore: cast_nullable_to_non_nullable
                  as List<Client>,
        pendingVisits: null == pendingVisits
            ? _value._pendingVisits
            : pendingVisits // ignore: cast_nullable_to_non_nullable
                  as List<Client>,
        todaysLogs: null == todaysLogs
            ? _value._todaysLogs
            : todaysLogs // ignore: cast_nullable_to_non_nullable
                  as List<VisitLog>,
      ),
    );
  }
}

/// @nodoc

class _$SalesDashboardDataImpl implements _SalesDashboardData {
  const _$SalesDashboardDataImpl({
    this.currentMonthTotal = 0.0,
    this.previousMonthTotal = 0.0,
    this.ordersCount = 0,
    final List<Order> recentOrders = const [],
    this.growthPercentage = 0.0,
    final List<Client> todaysVisits = const [],
    final List<Client> pendingVisits = const [],
    final List<VisitLog> todaysLogs = const [],
  }) : _recentOrders = recentOrders,
       _todaysVisits = todaysVisits,
       _pendingVisits = pendingVisits,
       _todaysLogs = todaysLogs;

  @override
  @JsonKey()
  final double currentMonthTotal;
  @override
  @JsonKey()
  final double previousMonthTotal;
  @override
  @JsonKey()
  final int ordersCount;
  final List<Order> _recentOrders;
  @override
  @JsonKey()
  List<Order> get recentOrders {
    if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentOrders);
  }

  @override
  @JsonKey()
  final double growthPercentage;
  final List<Client> _todaysVisits;
  @override
  @JsonKey()
  List<Client> get todaysVisits {
    if (_todaysVisits is EqualUnmodifiableListView) return _todaysVisits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaysVisits);
  }

  final List<Client> _pendingVisits;
  @override
  @JsonKey()
  List<Client> get pendingVisits {
    if (_pendingVisits is EqualUnmodifiableListView) return _pendingVisits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingVisits);
  }

  final List<VisitLog> _todaysLogs;
  @override
  @JsonKey()
  List<VisitLog> get todaysLogs {
    if (_todaysLogs is EqualUnmodifiableListView) return _todaysLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaysLogs);
  }

  @override
  String toString() {
    return 'SalesDashboardData(currentMonthTotal: $currentMonthTotal, previousMonthTotal: $previousMonthTotal, ordersCount: $ordersCount, recentOrders: $recentOrders, growthPercentage: $growthPercentage, todaysVisits: $todaysVisits, pendingVisits: $pendingVisits, todaysLogs: $todaysLogs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesDashboardDataImpl &&
            (identical(other.currentMonthTotal, currentMonthTotal) ||
                other.currentMonthTotal == currentMonthTotal) &&
            (identical(other.previousMonthTotal, previousMonthTotal) ||
                other.previousMonthTotal == previousMonthTotal) &&
            (identical(other.ordersCount, ordersCount) ||
                other.ordersCount == ordersCount) &&
            const DeepCollectionEquality().equals(
              other._recentOrders,
              _recentOrders,
            ) &&
            (identical(other.growthPercentage, growthPercentage) ||
                other.growthPercentage == growthPercentage) &&
            const DeepCollectionEquality().equals(
              other._todaysVisits,
              _todaysVisits,
            ) &&
            const DeepCollectionEquality().equals(
              other._pendingVisits,
              _pendingVisits,
            ) &&
            const DeepCollectionEquality().equals(
              other._todaysLogs,
              _todaysLogs,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentMonthTotal,
    previousMonthTotal,
    ordersCount,
    const DeepCollectionEquality().hash(_recentOrders),
    growthPercentage,
    const DeepCollectionEquality().hash(_todaysVisits),
    const DeepCollectionEquality().hash(_pendingVisits),
    const DeepCollectionEquality().hash(_todaysLogs),
  );

  /// Create a copy of SalesDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesDashboardDataImplCopyWith<_$SalesDashboardDataImpl> get copyWith =>
      __$$SalesDashboardDataImplCopyWithImpl<_$SalesDashboardDataImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesDashboardData implements SalesDashboardData {
  const factory _SalesDashboardData({
    final double currentMonthTotal,
    final double previousMonthTotal,
    final int ordersCount,
    final List<Order> recentOrders,
    final double growthPercentage,
    final List<Client> todaysVisits,
    final List<Client> pendingVisits,
    final List<VisitLog> todaysLogs,
  }) = _$SalesDashboardDataImpl;

  @override
  double get currentMonthTotal;
  @override
  double get previousMonthTotal;
  @override
  int get ordersCount;
  @override
  List<Order> get recentOrders;
  @override
  double get growthPercentage;
  @override
  List<Client> get todaysVisits;
  @override
  List<Client> get pendingVisits;
  @override
  List<VisitLog> get todaysLogs;

  /// Create a copy of SalesDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesDashboardDataImplCopyWith<_$SalesDashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
