/// Modelo de datos para productos (Freezed + JsonSerializable)
/// Estructura base:
///
/// @freezed
/// class ProductModel with _$ProductModel {
///   const factory ProductModel({
///     required String id,
///     required String name,
///     required String description,
///     required double price,
///     required String imageUrl,
///     @Default(0) int stock,
///     required DateTime createdAt,
///   }) = _ProductModel;
///
///   factory ProductModel.fromJson(Map<String, dynamic> json) =>
///       _$ProductModelFromJson(json);
/// }
///
/// Recuerda añadir estas dependencias a pubspec.yaml:
/// - freezed_annotation
/// - json_serializable
/// Y ejecutar: flutter pub run build_runner build
