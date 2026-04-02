import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/providers.dart';
import '../../domain/models/order.dart';
import '../../domain/models/collection_receipt.dart';

part 'closing_provider.g.dart';

@riverpod
Stream<List<Order>> todayOrders(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  // For migration, we use the custom repository.
  // If your endpoint /orders/driver/$driverId supports real-time,
  // you might need a stream. For now, we'll map getOrders to a stream.
  return Stream.fromFuture(
    ref.watch(ordersRepositoryProvider).getOrdersByDriver(user.uid),
  ).map((orders) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return orders
        .where(
          (o) =>
              o.payment.type == PaymentType.cash &&
              o.createdAt.isAfter(startOfDay),
        )
        .toList();
  });
}

@riverpod
Stream<List<CollectionReceipt>> todayCollections(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  // Assuming a similar repository pattern for collections if implemented.
  // If not, this is a placeholder to resolve FS errors.
  return Stream.value([]);
}

@riverpod
double todaySystemTotal(Ref ref) {
  final ordersAsync = ref.watch(todayOrdersProvider);
  final collectionsAsync = ref.watch(todayCollectionsProvider);

  double total = 0.0;

  if (ordersAsync.hasValue) {
    for (final order in ordersAsync.value!) {
      total +=
          order.payment.amountCordobas +
          (order.payment.amountDollars * order.payment.exchangeRate);
    }
  }

  if (collectionsAsync.hasValue) {
    for (final receipt in collectionsAsync.value!) {
      total +=
          receipt.amountCordobas +
          (receipt.amountDollars * receipt.exchangeRate);
    }
  }

  return total;
}
