// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ManifestStop _$ManifestStopFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'delivery':
      return DeliveryStop.fromJson(json);
    case 'collection':
      return CollectionStop.fromJson(json);
    case 'combined':
      return CombinedStop.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'ManifestStop',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$ManifestStop {
  String get id => throw _privateConstructorUsedError;
  Client get client => throw _privateConstructorUsedError;
  bool get isVisited => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get visitedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    delivery,
    required TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    collection,
    required TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    combined,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult? Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult? Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeliveryStop value) delivery,
    required TResult Function(CollectionStop value) collection,
    required TResult Function(CombinedStop value) combined,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeliveryStop value)? delivery,
    TResult? Function(CollectionStop value)? collection,
    TResult? Function(CombinedStop value)? combined,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeliveryStop value)? delivery,
    TResult Function(CollectionStop value)? collection,
    TResult Function(CombinedStop value)? combined,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ManifestStop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManifestStopCopyWith<ManifestStop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManifestStopCopyWith<$Res> {
  factory $ManifestStopCopyWith(
    ManifestStop value,
    $Res Function(ManifestStop) then,
  ) = _$ManifestStopCopyWithImpl<$Res, ManifestStop>;
  @useResult
  $Res call({
    String id,
    Client client,
    bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  });

  $ClientCopyWith<$Res> get client;
}

/// @nodoc
class _$ManifestStopCopyWithImpl<$Res, $Val extends ManifestStop>
    implements $ManifestStopCopyWith<$Res> {
  _$ManifestStopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? client = null,
    Object? isVisited = null,
    Object? visitedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            client: null == client
                ? _value.client
                : client // ignore: cast_nullable_to_non_nullable
                      as Client,
            isVisited: null == isVisited
                ? _value.isVisited
                : isVisited // ignore: cast_nullable_to_non_nullable
                      as bool,
            visitedAt: freezed == visitedAt
                ? _value.visitedAt
                : visitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClientCopyWith<$Res> get client {
    return $ClientCopyWith<$Res>(_value.client, (value) {
      return _then(_value.copyWith(client: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeliveryStopImplCopyWith<$Res>
    implements $ManifestStopCopyWith<$Res> {
  factory _$$DeliveryStopImplCopyWith(
    _$DeliveryStopImpl value,
    $Res Function(_$DeliveryStopImpl) then,
  ) = __$$DeliveryStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    Client client,
    Order order,
    bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  });

  @override
  $ClientCopyWith<$Res> get client;
  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$DeliveryStopImplCopyWithImpl<$Res>
    extends _$ManifestStopCopyWithImpl<$Res, _$DeliveryStopImpl>
    implements _$$DeliveryStopImplCopyWith<$Res> {
  __$$DeliveryStopImplCopyWithImpl(
    _$DeliveryStopImpl _value,
    $Res Function(_$DeliveryStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? client = null,
    Object? order = null,
    Object? isVisited = null,
    Object? visitedAt = freezed,
  }) {
    return _then(
      _$DeliveryStopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        client: null == client
            ? _value.client
            : client // ignore: cast_nullable_to_non_nullable
                  as Client,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as Order,
        isVisited: null == isVisited
            ? _value.isVisited
            : isVisited // ignore: cast_nullable_to_non_nullable
                  as bool,
        visitedAt: freezed == visitedAt
            ? _value.visitedAt
            : visitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryStopImpl implements DeliveryStop {
  const _$DeliveryStopImpl({
    required this.id,
    required this.client,
    required this.order,
    required this.isVisited,
    @NullableDateTimeConverter() this.visitedAt,
    final String? $type,
  }) : $type = $type ?? 'delivery';

  factory _$DeliveryStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryStopImplFromJson(json);

  @override
  final String id;
  @override
  final Client client;
  @override
  final Order order;
  @override
  final bool isVisited;
  @override
  @NullableDateTimeConverter()
  final DateTime? visitedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ManifestStop.delivery(id: $id, client: $client, order: $order, isVisited: $isVisited, visitedAt: $visitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryStopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isVisited, isVisited) ||
                other.isVisited == isVisited) &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, client, order, isVisited, visitedAt);

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryStopImplCopyWith<_$DeliveryStopImpl> get copyWith =>
      __$$DeliveryStopImplCopyWithImpl<_$DeliveryStopImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    delivery,
    required TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    collection,
    required TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    combined,
  }) {
    return delivery(id, client, order, isVisited, visitedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult? Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult? Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
  }) {
    return delivery?.call(id, client, order, isVisited, visitedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
    required TResult orElse(),
  }) {
    if (delivery != null) {
      return delivery(id, client, order, isVisited, visitedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeliveryStop value) delivery,
    required TResult Function(CollectionStop value) collection,
    required TResult Function(CombinedStop value) combined,
  }) {
    return delivery(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeliveryStop value)? delivery,
    TResult? Function(CollectionStop value)? collection,
    TResult? Function(CombinedStop value)? combined,
  }) {
    return delivery?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeliveryStop value)? delivery,
    TResult Function(CollectionStop value)? collection,
    TResult Function(CombinedStop value)? combined,
    required TResult orElse(),
  }) {
    if (delivery != null) {
      return delivery(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryStopImplToJson(this);
  }
}

abstract class DeliveryStop implements ManifestStop {
  const factory DeliveryStop({
    required final String id,
    required final Client client,
    required final Order order,
    required final bool isVisited,
    @NullableDateTimeConverter() final DateTime? visitedAt,
  }) = _$DeliveryStopImpl;

  factory DeliveryStop.fromJson(Map<String, dynamic> json) =
      _$DeliveryStopImpl.fromJson;

  @override
  String get id;
  @override
  Client get client;
  Order get order;
  @override
  bool get isVisited;
  @override
  @NullableDateTimeConverter()
  DateTime? get visitedAt;

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryStopImplCopyWith<_$DeliveryStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CollectionStopImplCopyWith<$Res>
    implements $ManifestStopCopyWith<$Res> {
  factory _$$CollectionStopImplCopyWith(
    _$CollectionStopImpl value,
    $Res Function(_$CollectionStopImpl) then,
  ) = __$$CollectionStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    Client client,
    double amountToCollect,
    bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  });

  @override
  $ClientCopyWith<$Res> get client;
}

/// @nodoc
class __$$CollectionStopImplCopyWithImpl<$Res>
    extends _$ManifestStopCopyWithImpl<$Res, _$CollectionStopImpl>
    implements _$$CollectionStopImplCopyWith<$Res> {
  __$$CollectionStopImplCopyWithImpl(
    _$CollectionStopImpl _value,
    $Res Function(_$CollectionStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? client = null,
    Object? amountToCollect = null,
    Object? isVisited = null,
    Object? visitedAt = freezed,
  }) {
    return _then(
      _$CollectionStopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        client: null == client
            ? _value.client
            : client // ignore: cast_nullable_to_non_nullable
                  as Client,
        amountToCollect: null == amountToCollect
            ? _value.amountToCollect
            : amountToCollect // ignore: cast_nullable_to_non_nullable
                  as double,
        isVisited: null == isVisited
            ? _value.isVisited
            : isVisited // ignore: cast_nullable_to_non_nullable
                  as bool,
        visitedAt: freezed == visitedAt
            ? _value.visitedAt
            : visitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionStopImpl implements CollectionStop {
  const _$CollectionStopImpl({
    required this.id,
    required this.client,
    required this.amountToCollect,
    required this.isVisited,
    @NullableDateTimeConverter() this.visitedAt,
    final String? $type,
  }) : $type = $type ?? 'collection';

  factory _$CollectionStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionStopImplFromJson(json);

  @override
  final String id;
  @override
  final Client client;
  @override
  final double amountToCollect;
  @override
  final bool isVisited;
  @override
  @NullableDateTimeConverter()
  final DateTime? visitedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ManifestStop.collection(id: $id, client: $client, amountToCollect: $amountToCollect, isVisited: $isVisited, visitedAt: $visitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionStopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.amountToCollect, amountToCollect) ||
                other.amountToCollect == amountToCollect) &&
            (identical(other.isVisited, isVisited) ||
                other.isVisited == isVisited) &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    client,
    amountToCollect,
    isVisited,
    visitedAt,
  );

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionStopImplCopyWith<_$CollectionStopImpl> get copyWith =>
      __$$CollectionStopImplCopyWithImpl<_$CollectionStopImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    delivery,
    required TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    collection,
    required TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    combined,
  }) {
    return collection(id, client, amountToCollect, isVisited, visitedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult? Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult? Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
  }) {
    return collection?.call(id, client, amountToCollect, isVisited, visitedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
    required TResult orElse(),
  }) {
    if (collection != null) {
      return collection(id, client, amountToCollect, isVisited, visitedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeliveryStop value) delivery,
    required TResult Function(CollectionStop value) collection,
    required TResult Function(CombinedStop value) combined,
  }) {
    return collection(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeliveryStop value)? delivery,
    TResult? Function(CollectionStop value)? collection,
    TResult? Function(CombinedStop value)? combined,
  }) {
    return collection?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeliveryStop value)? delivery,
    TResult Function(CollectionStop value)? collection,
    TResult Function(CombinedStop value)? combined,
    required TResult orElse(),
  }) {
    if (collection != null) {
      return collection(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionStopImplToJson(this);
  }
}

abstract class CollectionStop implements ManifestStop {
  const factory CollectionStop({
    required final String id,
    required final Client client,
    required final double amountToCollect,
    required final bool isVisited,
    @NullableDateTimeConverter() final DateTime? visitedAt,
  }) = _$CollectionStopImpl;

  factory CollectionStop.fromJson(Map<String, dynamic> json) =
      _$CollectionStopImpl.fromJson;

  @override
  String get id;
  @override
  Client get client;
  double get amountToCollect;
  @override
  bool get isVisited;
  @override
  @NullableDateTimeConverter()
  DateTime? get visitedAt;

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionStopImplCopyWith<_$CollectionStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CombinedStopImplCopyWith<$Res>
    implements $ManifestStopCopyWith<$Res> {
  factory _$$CombinedStopImplCopyWith(
    _$CombinedStopImpl value,
    $Res Function(_$CombinedStopImpl) then,
  ) = __$$CombinedStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    Client client,
    Order order,
    double amountToCollect,
    bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  });

  @override
  $ClientCopyWith<$Res> get client;
  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$CombinedStopImplCopyWithImpl<$Res>
    extends _$ManifestStopCopyWithImpl<$Res, _$CombinedStopImpl>
    implements _$$CombinedStopImplCopyWith<$Res> {
  __$$CombinedStopImplCopyWithImpl(
    _$CombinedStopImpl _value,
    $Res Function(_$CombinedStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? client = null,
    Object? order = null,
    Object? amountToCollect = null,
    Object? isVisited = null,
    Object? visitedAt = freezed,
  }) {
    return _then(
      _$CombinedStopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        client: null == client
            ? _value.client
            : client // ignore: cast_nullable_to_non_nullable
                  as Client,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as Order,
        amountToCollect: null == amountToCollect
            ? _value.amountToCollect
            : amountToCollect // ignore: cast_nullable_to_non_nullable
                  as double,
        isVisited: null == isVisited
            ? _value.isVisited
            : isVisited // ignore: cast_nullable_to_non_nullable
                  as bool,
        visitedAt: freezed == visitedAt
            ? _value.visitedAt
            : visitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$CombinedStopImpl implements CombinedStop {
  const _$CombinedStopImpl({
    required this.id,
    required this.client,
    required this.order,
    required this.amountToCollect,
    required this.isVisited,
    @NullableDateTimeConverter() this.visitedAt,
    final String? $type,
  }) : $type = $type ?? 'combined';

  factory _$CombinedStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$CombinedStopImplFromJson(json);

  @override
  final String id;
  @override
  final Client client;
  @override
  final Order order;
  @override
  final double amountToCollect;
  @override
  final bool isVisited;
  @override
  @NullableDateTimeConverter()
  final DateTime? visitedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ManifestStop.combined(id: $id, client: $client, order: $order, amountToCollect: $amountToCollect, isVisited: $isVisited, visitedAt: $visitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CombinedStopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.amountToCollect, amountToCollect) ||
                other.amountToCollect == amountToCollect) &&
            (identical(other.isVisited, isVisited) ||
                other.isVisited == isVisited) &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    client,
    order,
    amountToCollect,
    isVisited,
    visitedAt,
  );

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CombinedStopImplCopyWith<_$CombinedStopImpl> get copyWith =>
      __$$CombinedStopImplCopyWithImpl<_$CombinedStopImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    delivery,
    required TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    collection,
    required TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )
    combined,
  }) {
    return combined(id, client, order, amountToCollect, isVisited, visitedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult? Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult? Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
  }) {
    return combined?.call(
      id,
      client,
      order,
      amountToCollect,
      isVisited,
      visitedAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String id,
      Client client,
      Order order,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    delivery,
    TResult Function(
      String id,
      Client client,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    collection,
    TResult Function(
      String id,
      Client client,
      Order order,
      double amountToCollect,
      bool isVisited,
      @NullableDateTimeConverter() DateTime? visitedAt,
    )?
    combined,
    required TResult orElse(),
  }) {
    if (combined != null) {
      return combined(id, client, order, amountToCollect, isVisited, visitedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeliveryStop value) delivery,
    required TResult Function(CollectionStop value) collection,
    required TResult Function(CombinedStop value) combined,
  }) {
    return combined(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeliveryStop value)? delivery,
    TResult? Function(CollectionStop value)? collection,
    TResult? Function(CombinedStop value)? combined,
  }) {
    return combined?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeliveryStop value)? delivery,
    TResult Function(CollectionStop value)? collection,
    TResult Function(CombinedStop value)? combined,
    required TResult orElse(),
  }) {
    if (combined != null) {
      return combined(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CombinedStopImplToJson(this);
  }
}

abstract class CombinedStop implements ManifestStop {
  const factory CombinedStop({
    required final String id,
    required final Client client,
    required final Order order,
    required final double amountToCollect,
    required final bool isVisited,
    @NullableDateTimeConverter() final DateTime? visitedAt,
  }) = _$CombinedStopImpl;

  factory CombinedStop.fromJson(Map<String, dynamic> json) =
      _$CombinedStopImpl.fromJson;

  @override
  String get id;
  @override
  Client get client;
  Order get order;
  double get amountToCollect;
  @override
  bool get isVisited;
  @override
  @NullableDateTimeConverter()
  DateTime? get visitedAt;

  /// Create a copy of ManifestStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CombinedStopImplCopyWith<_$CombinedStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteManifest _$RouteManifestFromJson(Map<String, dynamic> json) {
  return _RouteManifest.fromJson(json);
}

/// @nodoc
mixin _$RouteManifest {
  String get driverId => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get date => throw _privateConstructorUsedError;
  List<ManifestStop> get stops => throw _privateConstructorUsedError;

  /// Serializes this RouteManifest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteManifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteManifestCopyWith<RouteManifest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteManifestCopyWith<$Res> {
  factory $RouteManifestCopyWith(
    RouteManifest value,
    $Res Function(RouteManifest) then,
  ) = _$RouteManifestCopyWithImpl<$Res, RouteManifest>;
  @useResult
  $Res call({
    String driverId,
    @DateTimeConverter() DateTime date,
    List<ManifestStop> stops,
  });
}

/// @nodoc
class _$RouteManifestCopyWithImpl<$Res, $Val extends RouteManifest>
    implements $RouteManifestCopyWith<$Res> {
  _$RouteManifestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteManifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? date = null,
    Object? stops = null,
  }) {
    return _then(
      _value.copyWith(
            driverId: null == driverId
                ? _value.driverId
                : driverId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            stops: null == stops
                ? _value.stops
                : stops // ignore: cast_nullable_to_non_nullable
                      as List<ManifestStop>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteManifestImplCopyWith<$Res>
    implements $RouteManifestCopyWith<$Res> {
  factory _$$RouteManifestImplCopyWith(
    _$RouteManifestImpl value,
    $Res Function(_$RouteManifestImpl) then,
  ) = __$$RouteManifestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String driverId,
    @DateTimeConverter() DateTime date,
    List<ManifestStop> stops,
  });
}

/// @nodoc
class __$$RouteManifestImplCopyWithImpl<$Res>
    extends _$RouteManifestCopyWithImpl<$Res, _$RouteManifestImpl>
    implements _$$RouteManifestImplCopyWith<$Res> {
  __$$RouteManifestImplCopyWithImpl(
    _$RouteManifestImpl _value,
    $Res Function(_$RouteManifestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteManifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? date = null,
    Object? stops = null,
  }) {
    return _then(
      _$RouteManifestImpl(
        driverId: null == driverId
            ? _value.driverId
            : driverId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        stops: null == stops
            ? _value._stops
            : stops // ignore: cast_nullable_to_non_nullable
                  as List<ManifestStop>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteManifestImpl implements _RouteManifest {
  const _$RouteManifestImpl({
    required this.driverId,
    @DateTimeConverter() required this.date,
    required final List<ManifestStop> stops,
  }) : _stops = stops;

  factory _$RouteManifestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteManifestImplFromJson(json);

  @override
  final String driverId;
  @override
  @DateTimeConverter()
  final DateTime date;
  final List<ManifestStop> _stops;
  @override
  List<ManifestStop> get stops {
    if (_stops is EqualUnmodifiableListView) return _stops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stops);
  }

  @override
  String toString() {
    return 'RouteManifest(driverId: $driverId, date: $date, stops: $stops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteManifestImpl &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._stops, _stops));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    driverId,
    date,
    const DeepCollectionEquality().hash(_stops),
  );

  /// Create a copy of RouteManifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteManifestImplCopyWith<_$RouteManifestImpl> get copyWith =>
      __$$RouteManifestImplCopyWithImpl<_$RouteManifestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteManifestImplToJson(this);
  }
}

abstract class _RouteManifest implements RouteManifest {
  const factory _RouteManifest({
    required final String driverId,
    @DateTimeConverter() required final DateTime date,
    required final List<ManifestStop> stops,
  }) = _$RouteManifestImpl;

  factory _RouteManifest.fromJson(Map<String, dynamic> json) =
      _$RouteManifestImpl.fromJson;

  @override
  String get driverId;
  @override
  @DateTimeConverter()
  DateTime get date;
  @override
  List<ManifestStop> get stops;

  /// Create a copy of RouteManifest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteManifestImplCopyWith<_$RouteManifestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
