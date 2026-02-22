import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_model.freezed.dart';
part 'stock_model.g.dart';

/// Stock model for product inventory
@freezed
class StockModel with _$StockModel {
  const factory StockModel({
    @JsonKey(name: 'product_id') required int productId,
    required int quantity,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);
}
