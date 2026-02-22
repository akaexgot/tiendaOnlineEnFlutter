import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Cart item model for local storage
@freezed
class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required int productId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
    String? size,
    int? maxStock,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  /// Calculate subtotal for this item
  double get subtotal => price * quantity;

  /// Check if can add more (stock limit)
  bool get canAddMore => maxStock == null || quantity < maxStock!;

  /// Create a copy with updated quantity
  CartItemModel increment() => copyWith(quantity: quantity + 1);
  CartItemModel decrement() => quantity > 1 ? copyWith(quantity: quantity - 1) : this;
}
