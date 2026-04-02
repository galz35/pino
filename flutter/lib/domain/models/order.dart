import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  pending,
  @JsonValue('ready_to_load')
  readyToLoad,
  @JsonValue('on_route')
  onRoute,
  delivered,
  cancelled,
  returned, // Keep returned for item status, but maybe order status too if fully returned
}

enum PreparationStatus {
  pending,
  @JsonValue('in_preparation')
  inPreparation,
  prepared,
  loaded,
}

enum PaymentType { cash, credit }

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String description,
    required int quantity,
    required double price,
    required double total,
    @Default(false) bool isReturned,
    String? returnReason,
    @Default('UNIT') String unitType, // 'BULTO' or 'UNIT'
    @Default(0) int scannedCount,
    @Default(false) bool hasDiscrepancy,
    int? actualQuantity, // For discrepancy reporting
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class PaymentInfo with _$PaymentInfo {
  const factory PaymentInfo({
    required PaymentType type,
    @NullableDateTimeConverter() DateTime? dueDate,
    required double amountCordobas,
    required double amountDollars,
    required double exchangeRate,
  }) = _PaymentInfo;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);
}

@freezed
class DeliveryInfo with _$DeliveryInfo {
  const factory DeliveryInfo({
    required String driverId,
    required String routeId,
    required double lat,
    required double lng,
    @NullableDateTimeConverter() DateTime? deliveredAt,
  }) = _DeliveryInfo;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);
}

@freezed
class AuthRequest with _$AuthRequest {
  const factory AuthRequest({
    required String requestedBy,
    @DateTimeConverter() required DateTime requestedAt,
    required String reason,
    @Default('pending') String status, // pending, approved, rejected
    String? approvedBy,
    @NullableDateTimeConverter() DateTime? approvedAt,
  }) = _AuthRequest;

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String clientId,
    required String sectorId, // Inherited from client subZone
    @NullableDateTimeConverter() DateTime? scheduledDeliveryDate,
    required OrderStatus status,
    @Default(PreparationStatus.pending) PreparationStatus preparationStatus,
    String? preparedBy,
    required List<OrderItem> items,
    required PaymentInfo payment,
    required DeliveryInfo delivery,
    AuthRequest? authRequest,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
