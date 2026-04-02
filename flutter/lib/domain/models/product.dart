import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String storeId,
    required String description,
    required String barcode,
    required double price1, // Public Price
    required double price2, // Client Price
    required double price3, // Mayorista
    required double price4, // Super Mayorista (Restricted)
    required double price5, // Distribuidor (Restricted)
    double? salePrice, // Base Sale Price (Web compatibility)
    required double costPrice,
    required int currentStock,
    required bool usesInventory,
    @Default('UNIT') String packagingType, // 'BULTO' or 'UNIT'
    @Default(1) int unitsPerBulto,
    String? imageUrl,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  const Product._();

  String get formattedTotalStock {
    if (packagingType == 'BULTO' && unitsPerBulto > 1) {
      final int bultos = (currentStock / unitsPerBulto).floor();
      final int units = currentStock % unitsPerBulto;

      if (bultos > 0 && units > 0) {
        return '$bultos Bult${bultos > 1 ? 'os' : 'o'}, $units Und${units > 1 ? 's' : ''}';
      } else if (bultos > 0) {
        return '$bultos Bult${bultos > 1 ? 'os' : 'o'}';
      }
    }
    return '$currentStock Und${currentStock != 1 ? 's' : ''}';
  }
}
