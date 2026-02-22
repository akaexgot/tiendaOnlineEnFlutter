import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/models/user_model.dart';

// ============ DATASOURCE PROVIDER ============

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource();
});

// ============ AUTH STATE ============

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isAdmin => user?.isAdmin ?? false;
}

// ============ AUTH NOTIFIER ============

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AuthState()) {
    _init();
  }

  /// Initialize auth state
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    // Listen to auth state changes
    _dataSource.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        final user = await _dataSource.getUserProfile();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          clearUser: true,
          isAuthenticated: false,
          isLoading: false,
        );
      }
    });

    // Check current session
    if (_dataSource.isLoggedIn) {
      final user = await _dataSource.getUserProfile();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _dataSource.signIn(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseAuthError(e),
      );
      return false;
    }
  }

  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _dataSource.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseAuthError(e),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _dataSource.signOut();
      state = state.copyWith(
        clearUser: true,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _dataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _dataSource.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _parseAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Credenciales inválidas';
        case 'User already registered':
          return 'El usuario ya está registrado';
        case 'Email not confirmed':
          return 'Por favor, confirma tu email';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}

// ============ PROVIDERS ============

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authDataSourceProvider));
});

/// Current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is admin
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

/// All users (admin)
final allUsersProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.watch(authDataSourceProvider).getAllUsers();
});
