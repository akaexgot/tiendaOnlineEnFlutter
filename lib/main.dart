import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/services/supabase_service.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_provider.dart';
import 'config/router/app_router.dart';
import 'shared/services/stripe_service.dart';
import 'shared/providers/scaffold_messenger_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Falls back to empty env if not found
  }

  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
  } catch (e) {
  }

  try {
    // Initialize Supabase
    await SupabaseService.initialize();
  } catch (e) {
  }

  try {
    // Initialize Stripe
    StripeService.instance.init();
  } catch (e) {
  }

  runApp(
    const ProviderScope(
      child: TiendaOnlineApp(),
    ),
  );
}

class TiendaOnlineApp extends ConsumerWidget {
  const TiendaOnlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final scaffoldMessenger = ref.watch(scaffoldMessengerProvider);

    return MaterialApp.router(
      title: 'SLC CUTS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessenger.scaffoldMessengerKey,
    );
  }
}
