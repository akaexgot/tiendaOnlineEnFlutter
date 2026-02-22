import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../../orders/data/models/promo_code_model.dart';

// ============ DATA SOURCE PROVIDER ============

final cartDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource();
});

// ============ CART STATE ============

/// Cart state containing items and promo code
class CartState {
  final List<CartItemModel> items;
  final PromoCodeModel? appliedPromo;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.appliedPromo,
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItemModel>? items,
    PromoCodeModel? appliedPromo,
    bool clearPromo = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Total items count
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Subtotal before discount
  double get subtotal => items.fold<double>(0, (sum, item) => sum + item.subtotal);

  /// Discount amount
  double get discount => appliedPromo?.calculateDiscount(subtotal) ?? 0;

  /// Total after discount
  double get total => subtotal - discount;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;
}

// ============ CART NOTIFIER ============

class CartNotifier extends StateNotifier<CartState> {
  final CartLocalDataSource _dataSource;

  CartNotifier(this._dataSource) : super(const CartState()) {
    _loadCart();
  }

  /// Load cart from local storage
  Future<void> _loadCart() async {
    state = state.copyWith(isLoading: true);
    try {
      await _dataSource.init();
      final items = _dataSource.getItems();
      final promo = _dataSource.getPromoCode();
      state = state.copyWith(
        items: items, 
        appliedPromo: promo != null && promo.isValid ? promo : null, 
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required int productId,
    required String productName,
    required double price,
    int quantity = 1,
    String? imageUrl,
    String? size,
    int? maxStock,
  }) async {
    try {
      final item = CartItemModel(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
        size: size,
        maxStock: maxStock,
      );
      await _dataSource.addItem(item);
      state = state.copyWith(items: _dataSource.getItems(), clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeItem(productId);
      } else {
        await _dataSource.updateQuantity(productId, quantity);
        state = state.copyWith(items: _dataSource.getItems(), clearError: true);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Increment item quantity
  Future<void> incrementQuantity(int productId) async {
    final item = _dataSource.getItem(productId);
    if (item != null && item.canAddMore) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(int productId) async {
    final item = _dataSource.getItem(productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  /// Remove item from cart
  Future<void> removeItem(int productId) async {
    try {
      await _dataSource.removeItem(productId);
      state = state.copyWith(items: _dataSource.getItems(), clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      await _dataSource.clearCart();
      await _dataSource.removePromoCode();
      state = state.copyWith(items: [], clearPromo: true, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Apply promo code
  Future<void> applyPromoCode(PromoCodeModel promo) async {
    if (promo.isValid && promo.minPurchase != null && state.subtotal < promo.minPurchase!) {
       state = state.copyWith(error: 'El importe mínimo es €${promo.minPurchase}');
       return;
    }

    if (promo.isValid) {
      await _dataSource.savePromoCode(promo);
      state = state.copyWith(appliedPromo: promo, clearError: true);
    } else {
      state = state.copyWith(error: 'Código promocional no válido');
    }
  }

  /// Remove promo code
  Future<void> removePromoCode() async {
    await _dataSource.removePromoCode();
    state = state.copyWith(clearPromo: true);
  }

  /// Check if product is in cart
  bool isInCart(int productId) => _dataSource.isInCart(productId);

  /// Get cart item by product ID
  CartItemModel? getItem(int productId) => _dataSource.getItem(productId);
}

// ============ PROVIDERS ============

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.watch(cartDataSourceProvider));
});

/// Cart item count for badge
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

/// Cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Cart total (after discount)
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

/// Is cart empty
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});
