import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

/// Product list page with filtering and search
class ProductListPage extends ConsumerWidget {
  final String? categorySlug;
  final bool showOffers;
  final bool showFeatured;

  const ProductListPage({
    super.key,
    this.categorySlug,
    this.showOffers = false,
    this.showFeatured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Determine which products to show
    final productsAsync = showOffers
        ? ref.watch(offerProductsProvider)
        : showFeatured
            ? ref.watch(featuredProductsProvider)
            : categorySlug != null
                ? ref.watch(categoryBySlugProvider(categorySlug!)).whenData(
                      (category) => category != null
                          ? ref.watch(productsByCategoryProvider(category.id))
                          : ref.watch(productsProvider),
                    ).value ?? const AsyncValue.loading()
                : ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          showOffers
              ? 'OFERTAS'
              : showFeatured
                  ? 'DESTACADOS'
                  : categorySlug != null
                      ? 'CATEGORÍA'
                      : 'PRODUCTOS',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Buscando: "$searchQuery"',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(searchQueryProvider.notifier)
                                .state = '',
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Category chips
          if (!showOffers && !showFeatured && categorySlug == null)
            SizedBox(
              height: 50,
              child: categoriesAsync.when(
                data: (categories) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: FilterChip(
                        label: const Text('Todos'),
                        selected: selectedCategory == null,
                        onSelected: (_) => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = null,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: selectedCategory == category.id,
                          onSelected: (_) => ref
                              .read(selectedCategoryProvider.notifier)
                              .state = category.id,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: product.isInStock
                          ? () => _addToCart(ref, product, context)
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(productsProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar productos'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre del producto...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = controller.text;
              Navigator.pop(context);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Solo ofertas'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to offers
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Solo destacados'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to featured
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Limpiar filtros'),
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = null;
                ref.read(searchQueryProvider.notifier).state = '';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(WidgetRef ref, product, BuildContext context) {
    ref.read(cartProvider.notifier).addItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          imageUrl: product.mainImageUrl,
          maxStock: product.stockQuantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }
}
