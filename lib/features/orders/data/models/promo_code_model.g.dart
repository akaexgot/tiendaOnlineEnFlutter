// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromoCodeModelImpl _$$PromoCodeModelImplFromJson(Map<String, dynamic> json) =>
    _$PromoCodeModelImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountValue: (json['discount_value'] as num).toDouble(),
      minPurchase: (json['min_purchase'] as num?)?.toDouble(),
      maxDiscount: (json['max_discount'] as num?)?.toDouble(),
      validFrom: json['valid_from'] == null
          ? null
          : DateTime.parse(json['valid_from'] as String),
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until'] as String),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      usesCount: (json['uses_count'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PromoCodeModelImplToJson(
  _$PromoCodeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'description': instance.description,
  'discount_type': instance.discountType,
  'discount_value': instance.discountValue,
  'min_purchase': instance.minPurchase,
  'max_discount': instance.maxDiscount,
  'valid_from': instance.validFrom?.toIso8601String(),
  'valid_until': instance.validUntil?.toIso8601String(),
  'max_uses': instance.maxUses,
  'uses_count': instance.usesCount,
  'active': instance.active,
  'created_at': instance.createdAt?.toIso8601String(),
};
