import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Pages imports
import '../../features/products/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/order_confirmation_page.dart';
import '../../features/orders/presentation/pages/order_history_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/content/presentation/pages/gallery_page.dart';
import '../../features/content/presentation/pages/news_page.dart';
import '../../features/content/presentation/pages/help_page.dart';
import '../../features/content/presentation/pages/about_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/admin_orders_page.dart';
import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/admin_promotions_page.dart';
import '../../features/admin/presentation/pages/admin_gallery_page.dart';
import '../../features/admin/presentation/pages/admin_news_page.dart';
import '../../features/admin/presentation/pages/admin_popups_page.dart';
import '../../features/admin/presentation/pages/admin_newsletter_page.dart';
import '../../features/admin/presentation/pages/admin_invoices_page.dart';
import '../../features/content/presentation/pages/booking_page.dart';
import '../../features/admin/presentation/pages/clients_page.dart';
import '../shell/main_shell.dart';

/// Route names
class AppRoutes {
  // Main routes
  static const home = '/';
  static const products = '/products';
  static const productDetail = '/product/:slug';
  static const category = '/category/:slug';
  static const offers = '/offers';
  static const featured = '/featured';
  static const search = '/search';
  static const gallery = '/gallery';
  static const booking = '/booking';
  
  // Cart & Checkout
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderConfirmation = '/order-confirmation/:orderId';
  static const orders = '/orders';
  static const orderDetail = '/orders/:orderId';
  
  // Auth
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const forgotPassword = '/forgot-password';
  
  // Admin
  static const admin = '/admin';
  static const adminProducts = '/admin/products';
  static const adminOrders = '/admin/orders';
  static const adminCategories = '/admin/categories';
  static const adminPromotions = '/admin/promotions';
  static const adminGallery = '/admin/gallery';
  static const adminNews = '/admin/news';
  static const adminPopups = '/admin/popups';
  static const adminNewsletter = '/admin/newsletter';
  static const adminInvoices = '/admin/invoices';
  static const adminClients = '/admin/clients';
}



/// RouterNotifier adapts auth state changes to a Listenable for GoRouter
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      // Only notify if the properties that affect routing change
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isAdmin != next.isAdmin ||
          previous?.isLoading != next.isLoading) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

/// GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final isAuthLoading = authState.isLoading;
      final path = state.matchedLocation;

      // Avoid redirecting while auth is still loading (initial check)
      if (isAuthLoading) return null;

      // Admin routes protection
      if (path.startsWith('/admin')) {
        if (!isLoggedIn) return AppRoutes.login;
        if (!isAdmin) return AppRoutes.home;
      }

      // Profile protection
      if (path == AppRoutes.profile && !isLoggedIn) {
        return AppRoutes.login;
      }

      // Orders protection
      if (path.startsWith('/orders') && !isLoggedIn) {
        return AppRoutes.login;
      }

      // Redirect from login if already logged in
      if ((path == AppRoutes.login || path == AppRoutes.register) && isLoggedIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ============ Main Shell (Bottom Navigation) ============
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            builder: (context, state) => const ProductListPage(),
          ),
          GoRoute(
            path: '/category/:slug',
            name: 'category',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return ProductListPage(categorySlug: slug);
            },
          ),
          GoRoute(
            path: AppRoutes.offers,
            name: 'offers',
            builder: (context, state) => const ProductListPage(showOffers: true),
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.booking,
            name: 'booking',
            builder: (context, state) => const BookingPage(),
          ),
          GoRoute(
            path: AppRoutes.checkout,
            name: 'checkout',
            builder: (context, state) => const CheckoutPage(),
          ),
          GoRoute(
            path: '/order-confirmation/:orderId',
            name: 'orderConfirmation',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderConfirmationPage(orderId: orderId);
            },
          ),
        ],
      ),

      // ============ Product Detail ============
      GoRoute(
        path: '/product/:slug',
        name: 'productDetail',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return ProductDetailPage(slug: slug);
        },
      ),

      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrderHistoryPage(),
      ),

      // ============ Auth ============
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => const NewsPage(),
      ),
      GoRoute(
        path: '/featured',
        builder: (context, state) => const ProductListPage(showFeatured: true),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        name: 'gallery',
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ============ Admin ============
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'products',
            name: 'adminProducts',
            builder: (context, state) => const AdminProductsPage(),
          ),
          GoRoute(
            path: 'orders',
            name: 'adminOrders',
            builder: (context, state) => const AdminOrdersPage(),
          ),
          GoRoute(
            path: 'categories',
            name: 'adminCategories',
            builder: (context, state) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: 'promotions',
            name: 'adminPromotions',
            builder: (context, state) => const AdminPromotionsPage(),
          ),
          GoRoute(
            path: 'invoices',
            name: 'adminInvoices',
            builder: (context, state) => const AdminInvoicesPage(),
          ),
          GoRoute(
            path: 'gallery',
            name: 'adminGallery',
            builder: (context, state) => const AdminGalleryPage(),
          ),
          GoRoute(
            path: 'news',
            name: 'adminNews',
            builder: (context, state) => const AdminNewsPage(),
          ),
          GoRoute(
            path: 'popups',
            name: 'adminPopups',
            builder: (context, state) => const AdminPopupsPage(),
          ),
          GoRoute(
            path: 'newsletter',
            name: 'adminNewsletter',
            builder: (context, state) => const AdminNewsletterPage(),
          ),
          GoRoute(
            path: 'clients',
            name: 'adminClients',
            builder: (context, state) => const ClientsPage(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Error desconocido'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
