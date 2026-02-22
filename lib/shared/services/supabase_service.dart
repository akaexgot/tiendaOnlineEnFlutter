import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:slc_cuts/config/constants/app_constants.dart';

/// Singleton service for Supabase connection
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  /// Get the current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Get user role from metadata
  static String get userRole {
    final metadata = currentUser?.userMetadata;
    return metadata?['role'] as String? ?? 'client';
  }

  /// Check if current user is admin
  static bool get isAdmin => userRole == 'admin';

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': 'client',
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get Supabase Storage bucket for product images
  static SupabaseStorageClient get storage => client.storage;
}
