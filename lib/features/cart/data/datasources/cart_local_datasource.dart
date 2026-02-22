import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/cart_item_model.dart';
import '../../../orders/data/models/promo_code_model.dart';

/// Local data source for cart - uses Hive for persistence
class CartLocalDataSource {
  static const String _boxName = 'cart';
  Box<String>? _box;

  /// Initialize Hive box for cart
  Future<void> init() async {
    // Hive.initFlutter() is already called in main.dart
    _box = await Hive.openBox<String>(_boxName);
  }

  Box<String> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Cart box not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all cart items
  List<CartItemModel> getItems() {
    return box.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CartItemModel.fromJson(map);
    }).toList();
  }

  /// Get a specific item by product ID
  CartItemModel? getItem(int productId) {
    final key = productId.toString();
    final data = box.get(key);
    if (data == null) return null;
    final map = jsonDecode(data) as Map<String, dynamic>;
    return CartItemModel.fromJson(map);
  }

  /// Add or update item in cart
  Future<void> addItem(CartItemModel item) async {
    final key = item.productId.toString();
    final existingItem = getItem(item.productId);

    if (existingItem != null) {
      final newQuantity = existingItem.quantity + item.quantity;
      final maxStock = item.maxStock ?? existingItem.maxStock;
      final clampedQuantity = maxStock != null 
          ? newQuantity.clamp(1, maxStock) 
          : newQuantity;
      
      final updatedItem = existingItem.copyWith(
        quantity: clampedQuantity,
        maxStock: maxStock,
      );
      await box.put(key, jsonEncode(updatedItem.toJson()));
    } else {
      await box.put(key, jsonEncode(item.toJson()));
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    final key = productId.toString();
    final item = getItem(productId);
    if (item == null) return;

    final maxStock = item.maxStock;
    final clampedQuantity = maxStock != null 
        ? quantity.clamp(1, maxStock) 
        : quantity.clamp(1, 999);

    final updatedItem = item.copyWith(quantity: clampedQuantity);
    await box.put(key, jsonEncode(updatedItem.toJson()));
  }

  /// Remove item from cart
  Future<void> removeItem(int productId) async {
    final key = productId.toString();
    await box.delete(key);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await box.clear();
  }

  /// Get total items count
  int get itemCount {
    return getItems().fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Get subtotal (before discounts)
  double get subtotal {
    return getItems().fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  /// Check if cart is empty
  bool get isEmpty => box.isEmpty;

  /// Check if product is in cart
  bool isInCart(int productId) => getItem(productId) != null;

  // ============ PROMO CODE PERSISTENCE ============

  static const String _promoKey = '__promo_code__';

  /// Get saved promo code
  PromoCodeModel? getPromoCode() {
    final jsonStr = box.get(_promoKey);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PromoCodeModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Save promo code
  Future<void> savePromoCode(PromoCodeModel promo) async {
    await box.put(_promoKey, jsonEncode(promo.toJson()));
  }

  /// Remove promo code
  Future<void> removePromoCode() async {
    await box.delete(_promoKey);
  }
}
