// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      description: json['description'] as String,
      barcode: json['barcode'] as String,
      price1: (json['price1'] as num).toDouble(),
      price2: (json['price2'] as num).toDouble(),
      price3: (json['price3'] as num).toDouble(),
      price4: (json['price4'] as num).toDouble(),
      price5: (json['price5'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toInt(),
      usesInventory: json['usesInventory'] as bool,
      packagingType: json['packagingType'] as String? ?? 'UNIT',
      unitsPerBulto: (json['unitsPerBulto'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'description': instance.description,
      'barcode': instance.barcode,
      'price1': instance.price1,
      'price2': instance.price2,
      'price3': instance.price3,
      'price4': instance.price4,
      'price5': instance.price5,
      'salePrice': instance.salePrice,
      'costPrice': instance.costPrice,
      'currentStock': instance.currentStock,
      'usesInventory': instance.usesInventory,
      'packagingType': instance.packagingType,
      'unitsPerBulto': instance.unitsPerBulto,
      'imageUrl': instance.imageUrl,
    };
