import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/utils/price_converter.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

/// Order item model for individual products in an order
@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required int id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'product_name') required String productName,
    required int quantity,
    @PriceConverter() required double price,
    String? size,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}
