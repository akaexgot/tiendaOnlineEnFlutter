/// Implementación concreta del repositorio de productos
/// Aquí van las implementaciones reales que usan el datasource
// class ProductRepositoryImpl implements ProductRepository {
//   final ProductRemoteDataSource remoteDataSource;
//
//   ProductRepositoryImpl({required this.remoteDataSource});
//
//   @override
//   Future<List<Product>> getProducts() async {
//     try {
//       final models = await remoteDataSource.getProducts();
//       return models.map((model) => model.toEntity()).toList();
//     } on ServerException catch (e) {
//       throw Failure(message: e.message, code: e.code);
//     }
//   }
// }
