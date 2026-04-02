import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/products_repository.dart';
import '../../domain/models/product.dart';

part 'products_provider.g.dart';

// Future of all products from local database
@riverpod
Future<List<Product>> products(Ref ref) async {
  return ref.watch(productsRepositoryProvider).getProducts();
}

// Search query state
@riverpod
class ProductSearchQuery extends _$ProductSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

// Filtered products based on search query
@riverpod
Future<List<Product>> filteredProducts(Ref ref) async {
  final products = await ref.watch(productsProvider.future);
  final query = ref.watch(productSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return products;

  return products.where((product) {
    return product.description.toLowerCase().contains(query) ||
        product.barcode.contains(query);
  }).toList();
}
