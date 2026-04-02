import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/product.dart';

part 'cart_provider.g.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double price;
  final int priceLevel;
  final String unitType; // 'BULTO' or 'UNIT'

  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.priceLevel,
    this.unitType = 'UNIT',
  });

  double get total => price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? price,
    int? priceLevel,
    String? unitType,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      priceLevel: priceLevel ?? this.priceLevel,
      unitType: unitType ?? this.unitType,
    );
  }
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

@riverpod
class Cart extends _$Cart {
  @override
  CartState build() => const CartState();

  void addItem(
    Product product,
    double price,
    int priceLevel, {
    int quantity = 1,
    String unitType = 'UNIT',
  }) {
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.price == price &&
          item.unitType == unitType,
    );

    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );

      final newItems = [...state.items];
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      final newItem = CartItem(
        product: product,
        quantity: quantity,
        price: price,
        priceLevel: priceLevel,
        unitType: unitType,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeItem(String productId, double price, String unitType) {
    state = state.copyWith(
      items: state.items.where((item) => 
        !(item.product.id == productId && item.price == price && item.unitType == unitType)
      ).toList(),
    );
  }

  void removeItemByProductId(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(
    String productId,
    double price,
    String unitType,
    int quantity,
  ) {
    if (quantity <= 0) {
      removeItem(productId, price, unitType);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.product.id == productId &&
          item.price == price &&
          item.unitType == unitType) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
  }

  void clear() {
    state = const CartState(items: []);
  }
}

