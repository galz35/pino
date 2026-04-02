import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'collection_receipt.freezed.dart';
part 'collection_receipt.g.dart';

@freezed
class CollectionReceipt with _$CollectionReceipt {
  const factory CollectionReceipt({
    required String id,
    required String clientId,
    required String collectorId, // Preventista or Rutero
    required double amountCordobas,
    required double amountDollars,
    required double exchangeRate,
    @DateTimeConverter() required DateTime createdAt,
    String? notes,
  }) = _CollectionReceipt;

  factory CollectionReceipt.fromJson(Map<String, dynamic> json) =>
      _$CollectionReceiptFromJson(json);
}
