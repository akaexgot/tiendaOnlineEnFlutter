import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes globales de la aplicación
class AppConstants {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Rutas
  static const String homeRoute = '/';
  static const String productsRoute = '/products';
  static const String productDetailRoute = '/products/:id';
  static const String cartRoute = '/cart';
  static const String authRoute = '/auth';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';

  // Stripe
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? ''; 
}
