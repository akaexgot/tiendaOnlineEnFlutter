import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/product_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/product_card.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/theme/theme_provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../admin/data/models/popup_model.dart';
import '../../../../features/content/presentation/providers/client_newsletter_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

/// Home page with featured products, offers, and categories
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final theme = ref.watch(themeProvider);
    final activePopup = ref.watch(activePopupProvider);
    final authState = ref.watch(authProvider);

    // Listen for Newsletter Subscription
    // We confirm we have a user, and then check if they are NOT subscribed
    ref.listen(isSubscribedProvider, (previous, next) {
      next.whenData((isSubscribed) {
        // Only show if:
        // 1. User is authenticated
        // 2. User is NOT subscribed
        // 3. We haven't just ignored it (handled by state logic ideally, but dialog is simple)
        if (authState.isAuthenticated && !isSubscribed) {
          // Delay slightly to avoid conflicts with other dialogs/builds
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              _showNewsletterDialog(context, ref, authState.user?.email);
            }
          });
        }
      });
    });

    ref.listen(activePopupProvider, (previous, next) {
      if (next.hasValue && next.value != null && next.value!.isActive) {
        // Delay the popup slightly to ensure context is ready and it doesn't clash with others
        Future.delayed(const Duration(milliseconds: 500), () {
             if (context.mounted) {
               showDialog(
                 context: context,
                 builder: (context) => _PopupDialog(popup: next.value!),
               );
             }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            leading: IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/logo.png' // Dark logo on gold box looks better
                        : 'assets/images/logo.png',
                    height: 18,
                    width: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SLC CUTS',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search'),
              ),
            ],
          ),

          // Hero Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                blur: 20,
                opacity: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.7,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.primaryLight 
                    : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido!',
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).textTheme.displayLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu barbería de confianza',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => context.push('/booking'),
                            child: const Text('Reserva tu cita'),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/logo_white.png'
                        : 'assets/images/logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ],
                ),
              ),
            ),
          ),


          // Booking Preview
          SliverToBoxAdapter(
            child: _buildBookingPreview(context),
          ),

          // News Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Novedades',
              onSeeAll: () => context.push('/news'),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNewsSection(ref),
          ),

          // Gallery Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildGalleryBanner(context),
            ),
          ),

          // Categories Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Categorías',
              onSeeAll: () => context.go('/products'),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCategoriesSection(ref),
          ),

          // Featured Products Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Destacados',
              onSeeAll: () => context.go('/featured'),
            ),
          ),
          _buildFeaturedProducts(ref),

          // Offers Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Ofertas',
              onSeeAll: () => context.go('/offers'),
            ),
          ),
          _buildOfferProducts(ref),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver todo',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 110,
      child: categoriesAsync.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => context.push('/category/${category.slug}'),
              child: Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: category.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: category.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.category,
                              color: AppColors.primary.withOpacity(0.5),
                              size: 30,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => _buildCategoriesLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCategoriesLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 90,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 60,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProducts(WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 320,
        child: featuredAsync.when(
          data: (products) => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ProductCard(
                  product: product,
                  onAddToCart: product.isInStock
                      ? () => _addToCart(ref, product)
                      : null,
                ),
              );
            },
          ),
          loading: () => _buildProductsLoading(),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildOfferProducts(WidgetRef ref) {
    final offersAsync = ref.watch(offerProductsProvider);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 320,
        child: offersAsync.when(
          data: (products) => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ProductCard(
                  product: product,
                  onAddToCart: product.isInStock
                      ? () => _addToCart(ref, product)
                      : null,
                ),
              );
            },
          ),
          loading: () => _buildProductsLoading(),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildProductsLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 180,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  void _addToCart(WidgetRef ref, product) {
    ref.read(cartProvider.notifier).addItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          imageUrl: product.mainImageUrl,
          maxStock: product.stockQuantity,
        );
  }
  Widget _buildBookingPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        blur: 15,
        opacity: isDark ? 0.08 : 0.4,
        color: isDark ? AppColors.primaryLight : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuestros Servicios',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildServiceItem(context, 'Corte de Pelo', '30 min', '15.00€', Icons.face_retouching_natural),
            const Divider(height: 24, color: Colors.white10),
            _buildServiceItem(context, 'Arreglo de Barba', '20 min', '10.00€', Icons.brush_outlined),
            const Divider(height: 24, color: Colors.white10),
            _buildServiceItem(context, 'Pack SLC (Premium)', '50 min', '22.00€', Icons.auto_awesome_outlined),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String name, String time, String price, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
  Widget _buildNewsSection(WidgetRef ref) {
    final newsAsync = ref.watch(latestNewsProvider);
    
    return SizedBox(
      height: 220,
      child: newsAsync.when(
        data: (news) {
          if (news.isEmpty) return const SizedBox.shrink();
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Container(
                width: 260, // Wider cards for news
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF1E1E1E) 
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Expanded(
                        child: item.imageUrl != null 
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.article),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                width: double.infinity,
                                child: const Icon(Icons.article, size: 40),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => _buildNewsLoading(),
        error: (e, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNewsLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 260,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/gallery'),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.8),
              AppColors.primary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.photo_camera_back,
                size: 140,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Galería de Cortes',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                         const Text(
                          'Inspírate con nuestros mejores trabajos realizados a clientes.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_forward, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewsletterDialog(BuildContext context, WidgetRef ref, String? email) {
    if (email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A2E), // Match app theme
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mark_email_unread_rounded, color: Color(0xFF14B8A6)),
            ),
            const SizedBox(width: 12),
            const Text('Newsletter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Te gustaría suscribirte a nuestra newsletter?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Recibe las mejores ofertas y novedades directamente en tu email: $email',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, gracias', style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Call provider to subscribe
              final success = await ref.read(newsletterControllerProvider.notifier).subscribeUser(email);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por suscribirte!'),
                      backgroundColor: Color(0xFF14B8A6),
                    ),
                  );
                  ref.invalidate(isSubscribedProvider); // Refresh check
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hubo un error al suscribirte'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('¡Sí, quiero!'),
          ),
        ],
      ),
    );
  }
}

class _PopupDialog extends StatelessWidget {
  final PopupModel popup;

  const _PopupDialog({super.key, required this.popup});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 20,
               offset: const Offset(0, 10),
             ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (popup.imageUrl != null)
              CachedNetworkImage(
                imageUrl: popup.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    popup.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (popup.content != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      popup.content!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ),
                      if (popup.buttonText != null && popup.buttonUrl != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final uri = Uri.parse(popup.buttonUrl!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(popup.buttonText!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
