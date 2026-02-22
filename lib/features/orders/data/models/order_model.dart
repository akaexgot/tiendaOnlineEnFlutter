import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item_model.dart';
import '../../../../shared/utils/price_converter.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Order status enum
enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled,
}

/// Order model with items
@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'guest_email') String? guestEmail,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'total_price') @PriceConverter() @Default(0) double totalPrice,
    @JsonKey(name: 'total_amount') @Default(0) int totalAmount,
    @Default('pending') String status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'shipping_method') String? shippingMethod,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'stock_deducted') @Default(false) bool stockDeducted,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<OrderItemModel>? items,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  /// Get order status as enum
  OrderStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Get the email to use for communication
  String? get email => customerEmail ?? guestEmail;

  /// Check if order is completed
  bool get isCompleted => 
      status == 'delivered' || status == 'cancelled';
}
