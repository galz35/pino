import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/api_client.dart';
import '../../domain/models/client.dart';

class SalesRepository {
  final ApiClient _apiClient;

  SalesRepository(this._apiClient);

  Future<bool> validateCredit({
    required Client client,
    required double newOrderTotal,
  }) async {
    final projectedDebt = client.currentDebt + newOrderTotal;
    return projectedDebt <= client.creditLimit;
  }

  Future<int> getAvailableStock(String productId) async {
    try {
      final response = await _apiClient.get('/products/$productId/stock');
      if (response.statusCode == 200) {
        return (response.data['currentStock'] as int?) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime> calculateDeliveryDate(String subZoneId) async {
    try {
      final response = await _apiClient.get(
        '/zones/subzones/$subZoneId/next-delivery',
      );
      if (response.statusCode == 200) {
        return DateTime.parse(response.data['date']);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> requestAuthorization({
    required String clientId,
    required double orderTotal,
    required String reason,
  }) async {
    await _apiClient.post(
      '/admin/alerts',
      data: {
        'type': 'CREDIT_LIMIT_EXCEEDED',
        'clientId': clientId,
        'orderTotal': orderTotal,
        'reason': reason,
      },
    );
  }

  Future<void> recordPayment(Map<String, dynamic> receiptData) async {
    await _apiClient.post('/collections/record', data: receiptData);
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(apiClientProvider));
});
