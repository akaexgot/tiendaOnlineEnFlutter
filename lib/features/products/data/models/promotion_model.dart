/// Promotion/Coupon model (maps to promo_codes table)
class PromotionModel {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int timesUsed;

  PromotionModel({
    required this.id,
    required this.code,
    this.discountType = 'percentage',
    required this.discountValue,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.timesUsed = 0,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
      validFrom: json['valid_from'] != null 
          ? DateTime.tryParse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null 
          ? DateTime.tryParse(json['valid_until'] as String)
          : null,
      usageLimit: json['usage_limit'] as int?,
      timesUsed: json['times_used'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'usage_limit': usageLimit,
      'times_used': timesUsed,
    };
  }

  /// Check if promotion is currently valid
  bool get isValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (usageLimit != null && timesUsed >= usageLimit!) return false;
    return true;
  }

  /// Get display discount
  String get displayDiscount {
    if (discountType == 'percentage' || discountType == 'percent') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '€${discountValue.toStringAsFixed(2)}';
    }
  }
}
