// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: const PriceConverter().fromJson(json['price'] as num?),
      categoryId: (json['category_id'] as num?)?.toInt(),
      isOffer: json['is_offer'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stock: json['stock'] == null
          ? null
          : StockModel.fromJson(json['stock'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'price': const PriceConverter().toJson(instance.price),
      'category_id': instance.categoryId,
      'is_offer': instance.isOffer,
      'is_featured': instance.isFeatured,
      'active': instance.active,
      'created_at': instance.createdAt?.toIso8601String(),
      'category': instance.category,
      'images': instance.images,
      'stock': instance.stock,
    };
