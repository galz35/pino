// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      productId: json['productId'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      isReturned: json['isReturned'] as bool? ?? false,
      returnReason: json['returnReason'] as String?,
      unitType: json['unitType'] as String? ?? 'UNIT',
      scannedCount: (json['scannedCount'] as num?)?.toInt() ?? 0,
      hasDiscrepancy: json['hasDiscrepancy'] as bool? ?? false,
      actualQuantity: (json['actualQuantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'description': instance.description,
      'quantity': instance.quantity,
      'price': instance.price,
      'total': instance.total,
      'isReturned': instance.isReturned,
      'returnReason': instance.returnReason,
      'unitType': instance.unitType,
      'scannedCount': instance.scannedCount,
      'hasDiscrepancy': instance.hasDiscrepancy,
      'actualQuantity': instance.actualQuantity,
    };

_$PaymentInfoImpl _$$PaymentInfoImplFromJson(Map<String, dynamic> json) =>
    _$PaymentInfoImpl(
      type: $enumDecode(_$PaymentTypeEnumMap, json['type']),
      dueDate: const NullableDateTimeConverter().fromJson(
        json['dueDate'] as String?,
      ),
      amountCordobas: (json['amountCordobas'] as num).toDouble(),
      amountDollars: (json['amountDollars'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$PaymentInfoImplToJson(_$PaymentInfoImpl instance) =>
    <String, dynamic>{
      'type': _$PaymentTypeEnumMap[instance.type]!,
      'dueDate': const NullableDateTimeConverter().toJson(instance.dueDate),
      'amountCordobas': instance.amountCordobas,
      'amountDollars': instance.amountDollars,
      'exchangeRate': instance.exchangeRate,
    };

const _$PaymentTypeEnumMap = {
  PaymentType.cash: 'cash',
  PaymentType.credit: 'credit',
};

_$DeliveryInfoImpl _$$DeliveryInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryInfoImpl(
      driverId: json['driverId'] as String,
      routeId: json['routeId'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      deliveredAt: const NullableDateTimeConverter().fromJson(
        json['deliveredAt'] as String?,
      ),
    );

Map<String, dynamic> _$$DeliveryInfoImplToJson(
  _$DeliveryInfoImpl instance,
) => <String, dynamic>{
  'driverId': instance.driverId,
  'routeId': instance.routeId,
  'lat': instance.lat,
  'lng': instance.lng,
  'deliveredAt': const NullableDateTimeConverter().toJson(instance.deliveredAt),
};

_$AuthRequestImpl _$$AuthRequestImplFromJson(Map<String, dynamic> json) =>
    _$AuthRequestImpl(
      requestedBy: json['requestedBy'] as String,
      requestedAt: const DateTimeConverter().fromJson(
        json['requestedAt'] as String,
      ),
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'pending',
      approvedBy: json['approvedBy'] as String?,
      approvedAt: const NullableDateTimeConverter().fromJson(
        json['approvedAt'] as String?,
      ),
    );

Map<String, dynamic> _$$AuthRequestImplToJson(
  _$AuthRequestImpl instance,
) => <String, dynamic>{
  'requestedBy': instance.requestedBy,
  'requestedAt': const DateTimeConverter().toJson(instance.requestedAt),
  'reason': instance.reason,
  'status': instance.status,
  'approvedBy': instance.approvedBy,
  'approvedAt': const NullableDateTimeConverter().toJson(instance.approvedAt),
};

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  sectorId: json['sectorId'] as String,
  scheduledDeliveryDate: const NullableDateTimeConverter().fromJson(
    json['scheduledDeliveryDate'] as String?,
  ),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  preparationStatus:
      $enumDecodeNullable(
        _$PreparationStatusEnumMap,
        json['preparationStatus'],
      ) ??
      PreparationStatus.pending,
  preparedBy: json['preparedBy'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  payment: PaymentInfo.fromJson(json['payment'] as Map<String, dynamic>),
  delivery: DeliveryInfo.fromJson(json['delivery'] as Map<String, dynamic>),
  authRequest: json['authRequest'] == null
      ? null
      : AuthRequest.fromJson(json['authRequest'] as Map<String, dynamic>),
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as String),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$$OrderImplToJson(
  _$OrderImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'sectorId': instance.sectorId,
  'scheduledDeliveryDate': const NullableDateTimeConverter().toJson(
    instance.scheduledDeliveryDate,
  ),
  'status': _$OrderStatusEnumMap[instance.status]!,
  'preparationStatus': _$PreparationStatusEnumMap[instance.preparationStatus]!,
  'preparedBy': instance.preparedBy,
  'items': instance.items,
  'payment': instance.payment,
  'delivery': instance.delivery,
  'authRequest': instance.authRequest,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.readyToLoad: 'ready_to_load',
  OrderStatus.onRoute: 'on_route',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.returned: 'returned',
};

const _$PreparationStatusEnumMap = {
  PreparationStatus.pending: 'pending',
  PreparationStatus.inPreparation: 'in_preparation',
  PreparationStatus.prepared: 'prepared',
  PreparationStatus.loaded: 'loaded',
};
