// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VisitLog _$VisitLogFromJson(Map<String, dynamic> json) {
  return _VisitLog.fromJson(json);
}

/// @nodoc
mixin _$VisitLog {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get clientName => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'visited_with_order' or 'visited_no_order'
  String? get orderId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this VisitLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitLogCopyWith<VisitLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitLogCopyWith<$Res> {
  factory $VisitLogCopyWith(VisitLog value, $Res Function(VisitLog) then) =
      _$VisitLogCopyWithImpl<$Res, VisitLog>;
  @useResult
  $Res call({
    String id,
    String clientId,
    String clientName,
    String storeId,
    String vendorId,
    @DateTimeConverter() DateTime date,
    String status,
    String? orderId,
    String? notes,
  });
}

/// @nodoc
class _$VisitLogCopyWithImpl<$Res, $Val extends VisitLog>
    implements $VisitLogCopyWith<$Res> {
  _$VisitLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = null,
    Object? storeId = null,
    Object? vendorId = null,
    Object? date = null,
    Object? status = null,
    Object? orderId = freezed,
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
            clientName: null == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$VisitLogImplCopyWith<$Res>
    implements $VisitLogCopyWith<$Res> {
  factory _$$VisitLogImplCopyWith(
    _$VisitLogImpl value,
    $Res Function(_$VisitLogImpl) then,
  ) = __$$VisitLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    String clientName,
    String storeId,
    String vendorId,
    @DateTimeConverter() DateTime date,
    String status,
    String? orderId,
    String? notes,
  });
}

/// @nodoc
class __$$VisitLogImplCopyWithImpl<$Res>
    extends _$VisitLogCopyWithImpl<$Res, _$VisitLogImpl>
    implements _$$VisitLogImplCopyWith<$Res> {
  __$$VisitLogImplCopyWithImpl(
    _$VisitLogImpl _value,
    $Res Function(_$VisitLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = null,
    Object? storeId = null,
    Object? vendorId = null,
    Object? date = null,
    Object? status = null,
    Object? orderId = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$VisitLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientName: null == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: freezed == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$VisitLogImpl implements _VisitLog {
  const _$VisitLogImpl({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.storeId,
    required this.vendorId,
    @DateTimeConverter() required this.date,
    required this.status,
    this.orderId,
    this.notes,
  });

  factory _$VisitLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitLogImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  final String clientName;
  @override
  final String storeId;
  @override
  final String vendorId;
  @override
  @DateTimeConverter()
  final DateTime date;
  @override
  final String status;
  // 'visited_with_order' or 'visited_no_order'
  @override
  final String? orderId;
  @override
  final String? notes;

  @override
  String toString() {
    return 'VisitLog(id: $id, clientId: $clientId, clientName: $clientName, storeId: $storeId, vendorId: $vendorId, date: $date, status: $status, orderId: $orderId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    clientId,
    clientName,
    storeId,
    vendorId,
    date,
    status,
    orderId,
    notes,
  );

  /// Create a copy of VisitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitLogImplCopyWith<_$VisitLogImpl> get copyWith =>
      __$$VisitLogImplCopyWithImpl<_$VisitLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitLogImplToJson(this);
  }
}

abstract class _VisitLog implements VisitLog {
  const factory _VisitLog({
    required final String id,
    required final String clientId,
    required final String clientName,
    required final String storeId,
    required final String vendorId,
    @DateTimeConverter() required final DateTime date,
    required final String status,
    final String? orderId,
    final String? notes,
  }) = _$VisitLogImpl;

  factory _VisitLog.fromJson(Map<String, dynamic> json) =
      _$VisitLogImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  String get clientName;
  @override
  String get storeId;
  @override
  String get vendorId;
  @override
  @DateTimeConverter()
  DateTime get date;
  @override
  String get status; // 'visited_with_order' or 'visited_no_order'
  @override
  String? get orderId;
  @override
  String? get notes;

  /// Create a copy of VisitLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitLogImplCopyWith<_$VisitLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
