import 'package:slc_cuts/shared/services/supabase_service.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/promo_code_model.dart';
import '../../../cart/data/models/cart_item_model.dart';

/// Remote data source for orders - handles all Supabase operations
class OrderRemoteDataSource {
  final _client = SupabaseService.client;

  /// Create a new order with items (full transaction)
  Future<OrderModel> createOrder({
    String? userId,
    String? guestEmail,
    required String customerEmail,
    required List<CartItemModel> cartItems,
    required double totalPrice,
    String? paymentMethod,
    String? shippingMethod,
    String? shippingAddress,
    Map<String, dynamic>? contactInfo,
    String? promoCode,
  }) async {
    // 1. Validate stock availability for all items
    for (final item in cartItems) {
      final stockData = await _client
          .from('stock')
          .select('quantity')
          .eq('product_id', item.productId)
          .maybeSingle();

      final availableStock = stockData?['quantity'] ?? 0;
      if (availableStock < item.quantity) {
        throw Exception('Stock insuficiente para ${item.productName}. Disponible: $availableStock');
      }
    }

    // 2. Create the order
    final orderData = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'guest_email': guestEmail,
          'customer_email': customerEmail,
          'total_price': totalPrice * 100,
          'total_amount': cartItems.fold<int>(0, (sum, item) => sum + item.quantity),
          'status': 'pending',
          'payment_method': paymentMethod,
          'shipping_method': shippingMethod,
          'shipping_address': shippingAddress,
          'contact_info': contactInfo,
          'stock_deducted': false,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    // 3. Create order items
    final orderItems = cartItems.map((item) => {
      'order_id': orderId,
      'product_id': item.productId,
      'product_name': item.productName,
      'quantity': item.quantity,
      'price': item.price * 100,
      'size': item.size,
    }).toList();

    await _client.from('order_items').insert(orderItems);

    // 4. (Stock deduction moved to payment confirmation)
    
    // 6. Increment promo code usage if used

    // 6. Increment promo code usage if used
    if (promoCode != null) {
      try {
        // Get current usage count and increment
        final promoData = await _client
            .from('promo_codes')
            .select('uses_count')
            .eq('code', promoCode)
            .single();
        
        final currentUses = promoData['uses_count'] as int? ?? 0;
        await _client
            .from('promo_codes')
            .update({'uses_count': currentUses + 1})
            .eq('code', promoCode);
      } catch (e) {
        // Silently fail promo code increment - order is still valid
        // Could log this for debugging
      }
    }

    return (await getOrderById(orderId))!;
  }

  /// Get order by ID with items
  Future<OrderModel?> getOrderById(String id) async {
    final data = await _client
        .from('orders')
        .select('''
          *,
          items:order_items(*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return _parseOrder(data);
  }

  /// Get orders for current user
  Future<List<OrderModel>> getUserOrders({int? limit}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    dynamic query = _client
        .from('orders')
        .select('''
          *,
          items:order_items(*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final data = await query as List<dynamic>;
    return data.map((json) => _parseOrder(json)).toList();
  }

  /// Get all orders (admin)
  Future<List<OrderModel>> getAllOrders({
    String? status,
    int? limit,
    int offset = 0,
  }) async {
    dynamic query = _client
        .from('orders')
        .select('''
          *,
          items:order_items(*)
        ''');

    if (status != null) {
      query = query.eq('status', status);
    }

    query = query.order('created_at', ascending: false);

    if (limit != null) {
      query = query.range(offset, offset + limit - 1);
    }

    final data = await query as List<dynamic>;
    return data.map((json) => _parseOrder(json)).toList();
  }

  /// Update order status (admin)
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);

    // If cancelled, restore stock
    if (status == 'cancelled') {
      await _restoreStock(orderId);
    }

    return (await getOrderById(orderId))!;
  }

  /// Restore stock when order is cancelled
  Future<void> _restoreStock(String orderId) async {
    final order = await getOrderById(orderId);
    if (order == null || !order.stockDeducted) return;

    for (final item in order.items ?? []) {
      await _client.rpc('increment_stock', params: {
        'p_product_id': item.productId,
        'p_quantity': item.quantity,
      });
    }

    // Mark stock as not deducted
    await _client
        .from('orders')
        .update({'stock_deducted': false})
        .eq('id', orderId);
  }

  /// Cancel order
  Future<OrderModel> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, 'cancelled');
  }

  /// Confirm order payment and deduct stock (RPC)
  Future<void> confirmOrderPayment(String orderId) async {
    await _client.rpc('confirm_order_payment', params: {
      'p_order_id': orderId,
    });
  }

  // ============ PROMO CODES ============

  /// Validate and get promo code
  Future<PromoCodeModel?> validatePromoCode(String code) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .eq('active', true)
        .maybeSingle();

    if (data == null) return null;

    final promo = PromoCodeModel.fromJson(data);
    return promo.isValid ? promo : null;
  }

  /// Get all promo codes (admin)
  Future<List<PromoCodeModel>> getAllPromoCodes() async {
    final data = await _client
        .from('promo_codes')
        .select()
        .order('created_at', ascending: false);

    return data.map((json) => PromoCodeModel.fromJson(json)).toList();
  }

  /// Create promo code (admin)
  Future<PromoCodeModel> createPromoCode({
    required String code,
    String? description,
    required String discountType,
    required double discountValue,
    double? minPurchase,
    double? maxDiscount,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxUses,
  }) async {
    final data = await _client
        .from('promo_codes')
        .insert({
          'code': code.toUpperCase(),
          'description': description,
          'discount_type': discountType,
          'discount_value': discountValue,
          'min_purchase': minPurchase,
          'max_discount': maxDiscount,
          'valid_from': validFrom?.toIso8601String(),
          'valid_until': validUntil?.toIso8601String(),
          'max_uses': maxUses,
          'uses_count': 0,
          'active': true,
        })
        .select()
        .single();

    return PromoCodeModel.fromJson(data);
  }

  // ============ ANALYTICS ============

  /// Get orders count by status
  Future<Map<String, int>> getOrdersCountByStatus() async {
    final data = await _client
        .from('orders')
        .select('status');

    final counts = <String, int>{};
    for (final row in data) {
      final status = row['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Get orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _client
        .from('orders')
        .select('*')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('created_at');

    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  /// Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 10}) async {
    final data = await _client.rpc('get_top_selling_products', params: {
      'limit_count': limit,
    });

    return List<Map<String, dynamic>>.from(data);
  }

  // ============ HELPERS ============

  OrderModel _parseOrder(Map<String, dynamic> json) {
    List<OrderItemModel>? items;
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    final orderJson = Map<String, dynamic>.from(json);
    orderJson.remove('items');

    return OrderModel.fromJson(orderJson).copyWith(items: items);
  }
}
