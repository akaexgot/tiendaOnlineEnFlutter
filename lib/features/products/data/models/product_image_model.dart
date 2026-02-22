import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image_model.freezed.dart';
part 'product_image_model.g.dart';

/// Product image model
@freezed
class ProductImageModel with _$ProductImageModel {
  const factory ProductImageModel({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ProductImageModel;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);
}
