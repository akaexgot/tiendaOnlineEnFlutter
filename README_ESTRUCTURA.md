# 📦 Estructura de Proyecto - Tienda Online Flutter

Esta es una **estructura profesional** basada en **Clean Architecture + Feature-First Organization + Riverpod**.

## 📁 Descripción de Carpetas

### `lib/config/` 🎨
Configuración global de la aplicación:
- **theme/** → Temas (Dark/Light), paleta de colores, estilos
- **router/** → Rutas con GoRouter o AutoRoute
- **constants/** → Constantes globales (API Keys, Environment)

### `lib/shared/` 🔄
Código reutilizable en toda la app:
- **extensions/** → Extensiones de Dart (String, DateTime, etc.)
- **exceptions/** → Manejo de errores (AppException, Failure)
- **services/** → Servicios globales (Supabase, LocalStorage, Camera)
- **widgets/** → Widgets "tontos" y atómicos (Buttons, TextFields, Loaders)

### `lib/features/` 📦
**Cada funcionalidad es independiente** (Products, Auth, Cart, etc.)

Cada feature tiene 3 capas:

#### **data/** (Obtención de datos)
- `datasources/` → Llamadas a Supabase/API (RemoteDataSource)
- `models/` → Clases Freezed con @JsonSerializable
- `repositories/` → Implementaciones concretas

#### **domain/** (Lógica de negocio)
- `repositories/` → Interfaces/contratos

#### **presentation/** (UI y Estado)
- `providers/` → Riverpod Controllers (AsyncNotifier)
- `pages/` → Pantallas completas (Scaffold)
- `widgets/` → Widgets específicos de la feature

---

## 🚀 Flujo de Datos

```
UI (ConsumerWidget)
    ↓ watch
Provider (Riverpod AsyncNotifier)
    ↓ accede a
Repository (Interfaz)
    ↓ implementa
RepositoryImpl
    ↓ usa
RemoteDataSource
    ↓ llama a
Supabase/API
```

---

## 📝 Dependencias Recomendadas

```yaml
# Estado y Lógica
flutter_riverpod: ^2.4.0
riverpod_annotation: ^2.1.0
riverpod_generator: ^2.3.0

# Datos
freezed_annotation: ^2.4.0
json_serializable: ^6.7.0

# Routing
go_router: ^10.0.0

# Backend
supabase_flutter: ^1.10.0

# Build
build_runner: ^2.4.0
```

---

## 🛠️ Cómo Crear una Nueva Feature

### 1. Crear la estructura
```
features/[nombre_feature]/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   └── repositories/
└── presentation/
    ├── providers/
    ├── pages/
    └── widgets/
```

### 2. Crear el modelo (data/models/)
```dart
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

### 3. Crear datasource (data/datasources/)
```dart
class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts() async {
    final data = await supabaseClient.from('products').select();
    return data.map((x) => ProductModel.fromJson(x)).toList();
  }
}
```

### 4. Crear repositorio interfaz (domain/repositories/)
```dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
```

### 5. Implementar repositorio (data/repositories/)
```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    final models = await remoteDataSource.getProducts();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

### 6. Crear provider (presentation/providers/)
```dart
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<Product>> build() async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.getProducts();
  }
}
```

### 7. Usar en la UI (presentation/pages/)
```dart
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    
    return products.when(
      data: (list) => ListView(children: list.map((p) => ProductCard(product: p))),
      loading: () => const CircularProgressIndicator(),
      error: (err, st) => Text('Error: $err'),
    );
  }
}
```

---

## ✅ Principios Clave

- **Inversión de Dependencias** → Interfaz (domain) → Implementación (data)
- **Single Responsibility** → Cada capa tiene una responsabilidad
- **Reutilización** → shared/ para código común
- **Modularización** → Fácil agregar/remover features
- **Testing** → Fácil de testear por capas

---

## 📚 Archivos Principales Creados

- **AppTheme** → `lib/config/theme/app_theme.dart`
- **AppConstants** → `lib/config/constants/app_constants.dart`
- **AppException** → `lib/shared/exceptions/app_exceptions.dart`
- **StringExtension** → `lib/shared/extensions/string_extension.dart`
- **AppButton** → `lib/shared/widgets/app_button.dart`

---

¡Estructura lista para desarrollar! 🚀
