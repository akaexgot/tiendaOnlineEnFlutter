import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

// ============ DATASOURCE PROVIDERS ============

final productDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource();
});

// ============ REPOSITORY PROVIDERS ============

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    dataSource: ref.watch(productDataSourceProvider),
  );
});

// ============ PRODUCTS PROVIDERS ============

/// All active products (for storefront)
final productsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});

/// All products including inactive (for admin)
final adminProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts(activeOnly: false);
});

/// Featured products
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(productRepositoryProvider).getFeaturedProducts();
});

/// Offer products
final offerProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.watch(productRepositoryProvider).getOfferProducts();
});

/// Products by category
final productsByCategoryProvider = FutureProvider.family<List<ProductModel>, int>((ref, categoryId) {
  return ref.watch(productRepositoryProvider).getProductsByCategory(categoryId);
});

/// Single product by ID
final productByIdProvider = FutureProvider.family<ProductModel?, int>((ref, id) {
  return ref.watch(productRepositoryProvider).getProductById(id);
});

/// Single product by slug
final productBySlugProvider = FutureProvider.family<ProductModel?, String>((ref, slug) {
  return ref.watch(productRepositoryProvider).getProductBySlug(slug);
});

/// Search products
final searchProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(productRepositoryProvider).searchProducts(query);
});

// ============ CATEGORIES PROVIDERS ============

/// All categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(productRepositoryProvider).getCategories();
});

/// Single category by ID
final categoryByIdProvider = FutureProvider.family<CategoryModel?, int>((ref, id) {
  return ref.watch(productRepositoryProvider).getCategoryById(id);
});

/// Single category by slug
final categoryBySlugProvider = FutureProvider.family<CategoryModel?, String>((ref, slug) {
  return ref.watch(productRepositoryProvider).getCategoryBySlug(slug);
});

// ============ SELECTED FILTERS STATE ============

/// Selected category filter
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

/// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered products based on selected category and search
final filteredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final categoryId = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isNotEmpty) {
    return ref.watch(productRepositoryProvider).searchProducts(searchQuery);
  }

  return ref.watch(productRepositoryProvider).getProducts(categoryId: categoryId);
});
