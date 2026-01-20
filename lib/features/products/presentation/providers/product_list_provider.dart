/// Provider para la lista de productos con Riverpod
/// Estructura base:
///
/// @riverpod
/// class ProductList extends _$ProductList {
///   @override
///   Future<List<Product>> build() async {
///     final repository = ref.watch(productRepositoryProvider);
///     return repository.getProducts();
///   }
/// }
///
/// Usar en la UI como:
/// ConsumerWidget que hace watch al provider
/// ref.watch(productListProvider)
///
/// Dependencias necesarias: flutter_riverpod, riverpod_generator
