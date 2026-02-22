// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemModelImpl _$$OrderItemModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemModelImpl(
      id: (json['id'] as num).toInt(),
      orderId: json['order_id'] as String,
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: const PriceConverter().fromJson(json['price'] as num?),
      size: json['size'] as String?,
    );

Map<String, dynamic> _$$OrderItemModelImplToJson(
  _$OrderItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'product_id': instance.productId,
  'product_name': instance.productName,
  'quantity': instance.quantity,
  'price': const PriceConverter().toJson(instance.price),
  'size': instance.size,
};
