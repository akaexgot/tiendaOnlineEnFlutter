import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Implementation of ProductRepository using ProductRemoteDataSource
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _dataSource;

  ProductRepositoryImpl({ProductRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ProductRemoteDataSource();

  @override
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    bool? isFeatured,
    bool? isOffer,
    bool activeOnly = true,
    int? limit,
    int offset = 0,
  }) {
    return _dataSource.getProducts(
      categoryId: categoryId,
      isFeatured: isFeatured,
      isOffer: isOffer,
      activeOnly: activeOnly,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ProductModel?> getProductById(int id) {
    return _dataSource.getProductById(id);
  }

  @override
  Future<ProductModel?> getProductBySlug(String slug) {
    return _dataSource.getProductBySlug(slug);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) {
    return _dataSource.searchProducts(query);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 6}) {
    return _dataSource.getFeaturedProducts(limit: limit);
  }

  @override
  Future<List<ProductModel>> getOfferProducts({int limit = 10}) {
    return _dataSource.getOfferProducts(limit: limit);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(int categoryId, {int? limit}) {
    return _dataSource.getProductsByCategory(categoryId, limit: limit);
  }

  @override
  Future<List<CategoryModel>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) {
    return _dataSource.getCategoryById(id);
  }

  @override
  Future<CategoryModel?> getCategoryBySlug(String slug) {
    return _dataSource.getCategoryBySlug(slug);
  }
}
