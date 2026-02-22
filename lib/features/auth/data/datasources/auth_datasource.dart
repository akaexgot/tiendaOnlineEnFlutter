import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:slc_cuts/shared/services/supabase_service.dart';
import '../models/user_model.dart';

/// Data source for authentication using Supabase Auth
class AuthDataSource {
  final _client = SupabaseService.client;
  final _auth = SupabaseService.client.auth;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get current user role
  String get userRole {
    final metadata = currentUser?.userMetadata;
    return metadata?['role'] as String? ?? 'client';
  }

  /// Check if current user is admin
  bool get isAdmin => userRole == 'admin';

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Error al iniciar sesión');
    }

    return _getUserFromSupabase(response.user!.id);
  }

  /// Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'role': 'client',
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );

    if (response.user == null) {
      throw Exception('Error al registrarse');
    }

    // Create user record in users table
    await _client.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'role': 'client',
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    });

    return _getUserFromSupabase(response.user!.id);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile() async {
    if (currentUser == null) return null;
    return _getUserFromSupabase(currentUser!.id);
  }

  /// Update user profile
  Future<UserModel?> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (currentUser == null) return null;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (phone != null) updates['phone'] = phone;

    await _client
        .from('users')
        .update(updates)
        .eq('id', currentUser!.id);

    // Also update auth metadata
    await _auth.updateUser(UserAttributes(
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
      },
    ));

    return _getUserFromSupabase(currentUser!.id);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  // ============ ADMIN METHODS ============

  /// Get all users (admin)
  Future<List<UserModel>> getAllUsers() async {
    final data = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Update user role (admin)
  Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from('users')
        .update({'role': role, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  /// Delete user (admin)
  Future<void> deleteUser(String userId) async {
    // Note: This only deletes from the public 'users' table. 
    // To delete from auth.users, you typically need a backend function or service role key.
    // For this app's architecture, we'll delete the record we can access.
    await _client.from('users').delete().eq('id', userId);
  }

  /// Update any user profile (admin)
  Future<void> updateOtherUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;

    await _client.from('users').update(updates).eq('id', userId);
  }

  // ============ HELPERS ============

  Future<UserModel?> _getUserFromSupabase(String id) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}
