import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

/// Abstract repository interface for products
abstract class ProductRepository {
  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    bool? isFeatured,
    bool? isOffer,
    bool activeOnly = true,
    int? limit,
    int offset = 0,
  });

  /// Get a single product by ID
  Future<ProductModel?> getProductById(int id);

  /// Get a single product by slug
  Future<ProductModel?> getProductBySlug(String slug);

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query);

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 6});

  /// Get offer products
  Future<List<ProductModel>> getOfferProducts({int limit = 10});

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId, {int? limit});

  /// Get all categories
  Future<List<CategoryModel>> getCategories();

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(int id);

  /// Get category by slug
  Future<CategoryModel?> getCategoryBySlug(String slug);
}
