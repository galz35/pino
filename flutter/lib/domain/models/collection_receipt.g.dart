// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionReceiptImpl _$$CollectionReceiptImplFromJson(
  Map<String, dynamic> json,
) => _$CollectionReceiptImpl(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  collectorId: json['collectorId'] as String,
  amountCordobas: (json['amountCordobas'] as num).toDouble(),
  amountDollars: (json['amountDollars'] as num).toDouble(),
  exchangeRate: (json['exchangeRate'] as num).toDouble(),
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$CollectionReceiptImplToJson(
  _$CollectionReceiptImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'collectorId': instance.collectorId,
  'amountCordobas': instance.amountCordobas,
  'amountDollars': instance.amountDollars,
  'exchangeRate': instance.exchangeRate,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'notes': instance.notes,
};
