import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/api_client.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../domain/models/product.dart';

/// Products Repository — OFFLINE-FIRST
/// Reads from local SQLite, writes are synced in background.
class ProductsRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;

  ProductsRepository(this._apiClient, this._localDb, this._connectivity);

  /// Get all products from LOCAL database (instant, no network)
  Future<List<Product>> getProducts() async {
    final rows = await _localDb.getAll('products');
    if (rows.isEmpty && _connectivity.isOnline) {
      // First time — try network fallback
      try {
        final response = await _apiClient.get('/products');
        if (response.statusCode == 200 && response.data is List) {
          final items = List<Map<String, dynamic>>.from(response.data);
          await _localDb.bulkUpsert(
            'products',
            items,
            'id',
            extraColumnsBuilder: (item) => {'store_id': item['storeId'] ?? ''},
          );
          return items.map((json) => Product.fromJson(json)).toList();
        }
      } catch (_) {}
      return [];
    }
    return rows.map((json) => Product.fromJson(json)).toList();
  }

  /// Find product by barcode — from LOCAL database
  Future<Product?> getProductByBarcode(String barcode) async {
    final all = await getProducts();
    try {
      return all.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  /// Search products locally (instant search)
  Future<List<Product>> searchProducts(String query) async {
    final all = await getProducts();
    final q = query.toLowerCase();
    return all
        .where(
          (p) =>
              p.description.toLowerCase().contains(q) ||
              p.barcode.toLowerCase().contains(q),
        )
        .toList();
  }
}

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(
    ref.watch(apiClientProvider),
    LocalDatabase.instance,
    ConnectivityService.instance,
  );
});
