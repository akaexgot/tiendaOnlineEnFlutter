// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      guestEmail: json['guest_email'] as String?,
      customerEmail: json['customer_email'] as String?,
      totalPrice: json['total_price'] == null
          ? 0
          : const PriceConverter().fromJson(json['total_price'] as num?),
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      shippingMethod: json['shipping_method'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      contactInfo: json['contact_info'] as Map<String, dynamic>?,
      stockDeducted: json['stock_deducted'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'guest_email': instance.guestEmail,
      'customer_email': instance.customerEmail,
      'total_price': const PriceConverter().toJson(instance.totalPrice),
      'total_amount': instance.totalAmount,
      'status': instance.status,
      'payment_method': instance.paymentMethod,
      'shipping_method': instance.shippingMethod,
      'shipping_address': instance.shippingAddress,
      'contact_info': instance.contactInfo,
      'stock_deducted': instance.stockDeducted,
      'created_at': instance.createdAt?.toIso8601String(),
      'items': instance.items,
    };
