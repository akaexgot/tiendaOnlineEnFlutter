import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/models/order_model.dart';
import '../../data/models/promo_code_model.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// ============ DATASOURCE PROVIDER ============

final orderDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource();
});

// ============ ORDERS PROVIDERS ============

/// User's orders
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(orderDataSourceProvider).getUserOrders();
});

/// All orders (admin)
final allOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(orderDataSourceProvider).getAllOrders();
});

/// Orders by status (admin)
final ordersByStatusProvider = FutureProvider.family<List<OrderModel>, String?>((ref, status) {
  return ref.watch(orderDataSourceProvider).getAllOrders(status: status);
});

/// Single order by ID
final orderByIdProvider = FutureProvider.family<OrderModel?, String>((ref, id) {
  return ref.watch(orderDataSourceProvider).getOrderById(id);
});

// ============ PROMO CODE PROVIDERS ============

/// Validate promo code
final validatePromoCodeProvider = FutureProvider.family<PromoCodeModel?, String>((ref, code) {
  if (code.isEmpty) return Future.value(null);
  return ref.watch(orderDataSourceProvider).validatePromoCode(code);
});

/// All promo codes (admin)
final allPromoCodesProvider = FutureProvider<List<PromoCodeModel>>((ref) {
  return ref.watch(orderDataSourceProvider).getAllPromoCodes();
});

// ============ CHECKOUT STATE ============

class CheckoutState {
  final bool isLoading;
  final String? error;
  final OrderModel? completedOrder;
  final String? customerEmail;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? shippingMethod;
  final Map<String, dynamic>? contactInfo;

  const CheckoutState({
    this.isLoading = false,
    this.error,
    this.completedOrder,
    this.customerEmail,
    this.shippingAddress,
    this.paymentMethod,
    this.shippingMethod,
    this.contactInfo,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    OrderModel? completedOrder,
    String? customerEmail,
    String? shippingAddress,
    String? paymentMethod,
    String? shippingMethod,
    Map<String, dynamic>? contactInfo,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      completedOrder: completedOrder ?? this.completedOrder,
      customerEmail: customerEmail ?? this.customerEmail,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  bool get isValid =>
      customerEmail != null &&
      customerEmail!.isNotEmpty &&
      shippingAddress != null &&
      shippingAddress!.isNotEmpty;
}

// ============ CHECKOUT NOTIFIER ============

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final OrderRemoteDataSource _dataSource;
  final Ref _ref;

  CheckoutNotifier(this._dataSource, this._ref) : super(const CheckoutState());

  void setCustomerEmail(String email) {
    state = state.copyWith(customerEmail: email, clearError: true);
  }

  void setShippingAddress(String address) {
    state = state.copyWith(shippingAddress: address, clearError: true);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method, clearError: true);
  }

  void setShippingMethod(String method) {
    state = state.copyWith(shippingMethod: method, clearError: true);
  }

  void setContactInfo(Map<String, dynamic> info) {
    state = state.copyWith(contactInfo: info, clearError: true);
  }

  /// Process checkout
  Future<OrderModel?> processCheckout({
    String? userId,
    String? guestEmail,
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Por favor, complete todos los campos requeridos');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final cartState = _ref.read(cartProvider);
      
      if (cartState.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'El carrito está vacío');
        return null;
      }

      final order = await _dataSource.createOrder(
        userId: userId,
        guestEmail: guestEmail,
        customerEmail: state.customerEmail!,
        cartItems: cartState.items,
        totalPrice: cartState.total,
        paymentMethod: state.paymentMethod,
        shippingMethod: state.shippingMethod,
        shippingAddress: state.shippingAddress,
        contactInfo: state.contactInfo,
        promoCode: cartState.appliedPromo?.code,
      );

      // Clear cart after successful order
      await _ref.read(cartProvider.notifier).clearCart();

      state = state.copyWith(
        isLoading: false,
        completedOrder: order,
      );

      return order;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const CheckoutState();
  }
}

// ============ CHECKOUT PROVIDER ============

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    ref.watch(orderDataSourceProvider),
    ref,
  );
});

// ============ ANALYTICS PROVIDERS ============

/// Orders count by status
final ordersCountByStatusProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(orderDataSourceProvider).getOrdersCountByStatus();
});

/// Top selling products
final topSellingProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(orderDataSourceProvider).getTopSellingProducts();
});
