import 'package:freezed_annotation/freezed_annotation.dart';
import 'category_model.dart';
import 'product_image_model.dart';
import 'stock_model.dart';
import '../../../../shared/utils/price_converter.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Complete product model with relations
@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required int id,
    required String name,
    required String slug,
    String? description,
    @PriceConverter() required double price,
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'is_offer') @Default(false) bool isOffer,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Relations
    CategoryModel? category,
    List<ProductImageModel>? images,
    StockModel? stock,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Get the main image URL
  String? get mainImageUrl => images?.isNotEmpty == true ? images!.first.imageUrl : null;

  /// Get stock quantity, defaults to 0
  int get stockQuantity => stock?.quantity ?? 0;

  /// Check if product is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if stock is low (less than 5)
  bool get isLowStock => stockQuantity > 0 && stockQuantity < 5;
}
