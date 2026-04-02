import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/providers.dart';
import '../../data/repositories/sales_repository.dart';
import '../../domain/models/client.dart';
import '../../domain/models/collection_receipt.dart';

part 'collection_provider.g.dart';

@riverpod
class CollectionNotifier extends _$CollectionNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> recordPayment({
    required Client client,
    required double amountCordobas,
    required double amountDollars,
    required double exchangeRate,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not authenticated');

      final receipt = CollectionReceipt(
        id: '', // Backend will assign
        clientId: client.id,
        collectorId: user.uid,
        amountCordobas: amountCordobas,
        amountDollars: amountDollars,
        exchangeRate: exchangeRate,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await ref.read(salesRepositoryProvider).recordPayment(receipt.toJson());

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
Future<List<Client>> clientsWithDebt(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  return ref
      .watch(clientsRepositoryProvider)
      .getClientsWithDebtByPreventa(user.uid);
}
