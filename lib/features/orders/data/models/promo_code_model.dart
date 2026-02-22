import 'package:freezed_annotation/freezed_annotation.dart';

part 'promo_code_model.freezed.dart';
part 'promo_code_model.g.dart';

/// Promo code discount type
enum DiscountType { percentage, fixed }

/// Promo code model
@freezed
class PromoCodeModel with _$PromoCodeModel {
  const PromoCodeModel._();

  const factory PromoCodeModel({
    required String id,
    required String code,
    String? description,
    @JsonKey(name: 'discount_type') @Default('percentage') String discountType,
    @JsonKey(name: 'discount_value') required double discountValue,
    @JsonKey(name: 'min_purchase') double? minPurchase,
    @JsonKey(name: 'max_discount') double? maxDiscount,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_until') DateTime? validUntil,
    @JsonKey(name: 'max_uses') int? maxUses,
    @JsonKey(name: 'uses_count') @Default(0) int usesCount,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PromoCodeModel;

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) => 
      _$PromoCodeModelFromJson(json);

  /// Get discount type as enum
  DiscountType get discountTypeEnum => 
      discountType == 'fixed' ? DiscountType.fixed : DiscountType.percentage;

  /// Check if promo code is valid now
  bool get isValid {
    final now = DateTime.now();
    if (!active) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (maxUses != null && usesCount >= maxUses!) return false;
    return true;
  }

  /// Calculate discount for a given amount
  double calculateDiscount(double amount) {
    if (!isValid) return 0;
    if (minPurchase != null && amount < minPurchase!) return 0;

    double discount;
    if (discountTypeEnum == DiscountType.percentage) {
      discount = amount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    // Apply max discount cap
    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }

    return discount.clamp(0, amount);
  }
}
