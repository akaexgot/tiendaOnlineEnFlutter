# 👗 FashionStore - Tienda Online Flutter

Este proyecto es una aplicación móvil nativa desarrollada con Flutter para la marca de moda "FashionStore". Implementa una arquitectura profesional y escalable para gestionar tanto la experiencia del cliente final como el backofice de administración.

## 🚀 Arquitectura del Proyecto

La aplicación sigue los principios de **Clean Architecture** organizada por **Features**, utilizando **Riverpod** para la gestión del estado y **GoRouter** para la navegación.

### 📁 Estructura de Directorios

```plaintext
lib/
├── config/                  # Configuración global (Theme, Router, Constants)
├── shared/                  # Código reutilizable (Exceptions, Services, Widgets atómicos)
├── features/                # Funcionalidades modulares
│   ├── [nombre_feature]/
│   │   ├── data/            # Implementación (Datasources, Models Freezed, Repositories)
│   │   ├── domain/          # Abstracción (Entities, Interfaces de Repositorios)
│   │   └── presentation/    # UI y Estado (Providers, Pages, Widgets)
└── main.dart                # Punto de entrada de la aplicación
```

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter (Última versión estable)
- **Backend:** Supabase (PostgreSQL + Realtime + Storage)
- **Estado:** Riverpod (AsyncNotifier, StateNotifier)
- **Modelos:** Freezed + JsonSerializable (Inmutabilidad)
- **Enrutamiento:** GoRouter
- **Pagos:** Stripe SDK (Simulado/Integrado)

---

## 📝 Documentación de la Solución (Rúbrica)

### 1. Manejo de Imágenes y Rendimiento
Para garantizar un rendimiento nativo de 60fps y eficiencia en datos:
- **Compresión:** Uso de `flutter_image_compress` antes de la subida a Supabase.
- **Caché:** `cached_network_image` para persistencia local de imágenes del catálogo.
- **Cámara:** Integración con `image_picker` para la gestión de productos desde el móvil.

### 2. Gestión de Errores
Implementación de una clase `Failure` personalizada en `lib/shared/exceptions/` para transformar excepciones técnicas (Red, Supabase) en mensajes amigables para el usuario.

### 3. Lógica Real-time (Ofertas Flash)
Uso de `StreamProvider` de Riverpod para escuchar cambios en la tabla `app_config` de Supabase. Esto permite habilitar/deshabilitar secciones de la app al instante sin necesidad de recargar.

---

## 🗄️ Base de Datos y Backend

### Esquema SQL (Supabase)

```sql
-- Tabla de Categorías
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Productos
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  images TEXT[] DEFAULT '{}',
  stock_quantity INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_offer BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Configuración (Real-time)
CREATE TABLE app_config (
  id TEXT PRIMARY KEY,
  value_bool BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Configuración de Storage
El bucket `products-images` está configurado con políticas RLS que permiten:
- **Lectura:** Pública (todos los usuarios).
- **Escritura:** Restringida a usuarios con rol `admin`.

---

## 📈 Hitos de Desarrollo

1. **Hito 1 (Arquitectura):** Estructura definida, modelos Freezed y diagramas E-R. ✅
2. **Hito 2 (Prototipo):** Conexión con Supabase, listado de productos y diferenciación de roles. ✅
3. **Hito 3 (App Viva):** Flujo de compra completo, gestión de inventario y subida de imágenes optimizada. 🔄 (En progreso)

---

## 🎨 Guía de Estilo

- **Tipografía:**
  - Encabezados: `Playfair Display` (Serif moderna).
  - Cuerpo: `Lato` (Sans-serif limpia).
- **Colores:** Definidos en `lib/config/theme/app_colors.dart`.
- **Aesthetic:** Minimalismo sofisticado con micro-animaciones (Hero, Shimmer).
