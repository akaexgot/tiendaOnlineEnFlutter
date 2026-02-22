import 'package:slc_cuts/shared/services/supabase_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/product_image_model.dart';
import '../models/stock_model.dart';

/// Remote data source for products - handles all Supabase queries
class ProductRemoteDataSource {
  final _client = SupabaseService.client;

  /// Get all products with relations (category, images, stock)
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    bool? isFeatured,
    bool? isOffer,
    bool activeOnly = true,
    int? limit,
    int offset = 0,
  }) async {
    dynamic query = _client
        .from('products')
        .select('''
          *,
          category:categories(*),
          images:product_images(*),
          stock(*)
        ''');

    if (activeOnly) {
      query = query.eq('active', true);
    }
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }
    if (isOffer != null) {
      query = query.eq('is_offer', isOffer);
    }

    query = query.order('created_at', ascending: false);

    if (limit != null) {
      query = query.range(offset, offset + limit - 1);
    }

    final data = await query as List<dynamic>;
    return data.map((json) => _parseProduct(json)).toList();
  }

  /// Get a single product by ID
  Future<ProductModel?> getProductById(int id) async {
    final data = await _client
        .from('products')
        .select('''
          *,
          category:categories(*),
          images:product_images(*),
          stock(*)
        ''')
        .eq('id', id)
        .maybeSingle();

    return data != null ? _parseProduct(data) : null;
  }

  /// Get a single product by slug
  Future<ProductModel?> getProductBySlug(String slug) async {
    final data = await _client
        .from('products')
        .select('''
          *,
          category:categories(*),
          images:product_images(*),
          stock(*)
        ''')
        .eq('slug', slug)
        .maybeSingle();

    return data != null ? _parseProduct(data) : null;
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select('''
          *,
          category:categories(*),
          images:product_images(*),
          stock(*)
        ''')
        .eq('active', true)
        .ilike('name', '%$query%')
        .order('name')
        .limit(20);

    return (data as List<dynamic>).map((json) => _parseProduct(json)).toList();
  }

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 6}) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  /// Get offer products
  Future<List<ProductModel>> getOfferProducts({int limit = 10}) async {
    return getProducts(isOffer: true, limit: limit);
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId, {int? limit}) async {
    return getProducts(categoryId: categoryId, limit: limit);
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('name');

    return (data as List<dynamic>).map((json) => CategoryModel.fromJson(json)).toList();
  }

  /// Get a single category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('id', id)
        .maybeSingle();

    return data != null ? CategoryModel.fromJson(data) : null;
  }

  /// Get a single category by slug
  Future<CategoryModel?> getCategoryBySlug(String slug) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    return data != null ? CategoryModel.fromJson(data) : null;
  }

  // ============ ADMIN METHODS ============

  /// Create a new product (admin)
  Future<ProductModel> createProduct({
    required String name,
    required String slug,
    String? description,
    required double price,
    int? categoryId,
    bool isOffer = false,
    bool isFeatured = false,
    bool active = true,
    List<String>? imageUrls,
    int initialStock = 0,
  }) async {
    // Create product
    final productData = await _client
        .from('products')
        .insert({
          'name': name,
          'slug': slug,
          'description': description,
          'price': price * 100,
          'category_id': categoryId,
          'is_offer': isOffer,
          'is_featured': isFeatured,
          'active': active,
        })
        .select()
        .single();

    final productId = productData['id'] as int;

    // Add images if provided
    if (imageUrls != null && imageUrls.isNotEmpty) {
      await _client.from('product_images').insert(
        imageUrls.map((url) => {
          'product_id': productId,
          'image_url': url,
        }).toList(),
      );
    }

    // Create stock entry
    await _client.from('stock').insert({
      'product_id': productId,
      'quantity': initialStock,
    });

    // Return complete product
    return (await getProductById(productId))!;
  }

  /// Update a product (admin)
  Future<ProductModel> updateProduct({
    required int id,
    String? name,
    String? slug,
    String? description,
    double? price,
    int? categoryId,
    bool? isOffer,
    bool? isFeatured,
    bool? active,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (slug != null) updates['slug'] = slug;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price * 100;
    if (categoryId != null) updates['category_id'] = categoryId;
    if (isOffer != null) updates['is_offer'] = isOffer;
    if (isFeatured != null) updates['is_featured'] = isFeatured;
    if (active != null) updates['active'] = active;

    await _client.from('products').update(updates).eq('id', id);

    return (await getProductById(id))!;
  }

  /// Delete a product (admin) - sets active to false
  Future<void> deleteProduct(int id) async {
    await _client.from('products').update({'active': false}).eq('id', id);
  }

  /// Update stock quantity (admin)
  Future<void> updateStock(int productId, int quantity) async {
    await _client.from('stock').upsert({
      'product_id': productId,
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Add product image (admin)
  Future<ProductImageModel> addProductImage(int productId, String imageUrl) async {
    final data = await _client
        .from('product_images')
        .insert({
          'product_id': productId,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return ProductImageModel.fromJson(data);
  }

  /// Delete product image (admin)
  Future<void> deleteProductImage(int imageId) async {
    await _client.from('product_images').delete().eq('id', imageId);
  }

  /// Set main image (replaces all existing images)
  Future<void> setMainImage(int productId, String imageUrl) async {
    // Get current images to delete them
    final data = await _client
        .from('product_images')
        .select('id')
        .eq('product_id', productId);
    
    final images = (data as List).map((e) => e['id'] as int).toList();
    
    for (final id in images) {
      await deleteProductImage(id);
    }

    // Add new image
    await addProductImage(productId, imageUrl);
  }

  // ============ CATEGORY ADMIN METHODS ============

  /// Create a new category (admin)
  Future<CategoryModel> createCategory({
    required String name,
    required String slug,
    String? imageUrl,
  }) async {
    final data = await _client
        .from('categories')
        .insert({
          'name': name,
          'slug': slug,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return CategoryModel.fromJson(data);
  }

  /// Update a category (admin)
  Future<CategoryModel> updateCategory({
    required int id,
    String? name,
    String? slug,
    String? imageUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (slug != null) updates['slug'] = slug;
    if (imageUrl != null) updates['image_url'] = imageUrl;

    final data = await _client
        .from('categories')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return CategoryModel.fromJson(data);
  }

  /// Delete a category (admin)
  Future<void> deleteCategory(int id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // ============ HELPERS ============

  /// Parse a product with its relations
  ProductModel _parseProduct(Map<String, dynamic> json) {
    // Parse category
    CategoryModel? category;
    if (json['category'] != null) {
      category = CategoryModel.fromJson(json['category']);
    }

    // Parse images
    List<ProductImageModel>? images;
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List)
          .map((img) => ProductImageModel.fromJson(img))
          .toList();
    }

    // Parse stock
    StockModel? stock;
    if (json['stock'] != null) {
      if (json['stock'] is List && (json['stock'] as List).isNotEmpty) {
        stock = StockModel.fromJson((json['stock'] as List).first);
      } else if (json['stock'] is Map) {
        stock = StockModel.fromJson(json['stock']);
      }
    }

    // Create product with clean JSON (remove nested objects)
    final productJson = Map<String, dynamic>.from(json);
    productJson.remove('category');
    productJson.remove('images');
    productJson.remove('stock');

    return ProductModel.fromJson(productJson).copyWith(
      category: category,
      images: images,
      stock: stock,
    );
  }
}
