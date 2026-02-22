// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageModelImpl _$$ProductImageModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductImageModelImpl(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  imageUrl: json['image_url'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ProductImageModelImplToJson(
  _$ProductImageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'image_url': instance.imageUrl,
  'created_at': instance.createdAt?.toIso8601String(),
};
