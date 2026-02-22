import 'package:slc_cuts/shared/services/supabase_service.dart';
import '../models/promotion_model.dart';

/// Remote data source for promotions/coupons (uses promo_codes table)
class PromotionRemoteDataSource {
  final _client = SupabaseService.client;

  /// Get all promotions
  Future<List<PromotionModel>> getPromotions() async {
    final data = await _client
        .from('promo_codes')
        .select()
        .order('code');

    return (data as List<dynamic>).map((json) => PromotionModel.fromJson(json)).toList();
  }

  /// Get a single promotion by ID
  Future<PromotionModel?> getPromotionById(String id) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('id', id)
        .maybeSingle();

    return data != null ? PromotionModel.fromJson(data) : null;
  }

  /// Get a promotion by code
  Future<PromotionModel?> getPromotionByCode(String code) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .maybeSingle();

    return data != null ? PromotionModel.fromJson(data) : null;
  }

  /// Validate a promotion code
  Future<PromotionModel?> validatePromoCode(String code, {double? cartTotal}) async {
    final promotion = await getPromotionByCode(code);
    
    if (promotion == null) return null;
    if (!promotion.isValid) return null;
    
    return promotion;
  }

  /// Create a new promotion
  Future<PromotionModel> createPromotion({
    required String code,
    required String discountType,
    required double discountValue,
    DateTime? validFrom,
    DateTime? validUntil,
    int? usageLimit,
  }) async {
    final data = await _client
        .from('promo_codes')
        .insert({
          'code': code.toUpperCase(),
          'discount_type': discountType,
          'discount_value': discountValue,
          'valid_from': validFrom?.toIso8601String(),
          'valid_until': validUntil?.toIso8601String(),
          'usage_limit': usageLimit,
          'times_used': 0,
        })
        .select()
        .single();

    return PromotionModel.fromJson(data);
  }

  /// Update a promotion
  Future<PromotionModel> updatePromotion({
    required String id,
    String? code,
    String? discountType,
    double? discountValue,
    DateTime? validFrom,
    DateTime? validUntil,
    int? usageLimit,
  }) async {
    final updates = <String, dynamic>{};
    if (code != null) updates['code'] = code.toUpperCase();
    if (discountType != null) updates['discount_type'] = discountType;
    if (discountValue != null) updates['discount_value'] = discountValue;
    if (validFrom != null) updates['valid_from'] = validFrom.toIso8601String();
    if (validUntil != null) updates['valid_until'] = validUntil.toIso8601String();
    if (usageLimit != null) updates['usage_limit'] = usageLimit;

    final data = await _client
        .from('promo_codes')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return PromotionModel.fromJson(data);
  }

  /// Delete a promotion
  Future<void> deletePromotion(String id) async {
    await _client.from('promo_codes').delete().eq('id', id);
  }

  /// Increment usage count
  Future<void> incrementUsage(String id) async {
    final promotion = await getPromotionById(id);
    if (promotion != null) {
      await _client.from('promo_codes').update({
        'times_used': promotion.timesUsed + 1,
      }).eq('id', id);
    }
  }
}

