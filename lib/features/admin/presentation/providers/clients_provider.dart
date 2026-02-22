import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slc_cuts/features/auth/data/datasources/auth_datasource.dart';
import 'package:slc_cuts/features/auth/data/models/user_model.dart';
import 'package:slc_cuts/shared/providers/scaffold_messenger_provider.dart';

final authDataSourceProvider = Provider((ref) => AuthDataSource());

// State for the list of clients
final clientsProvider = StateNotifierProvider<ClientsNotifier, AsyncValue<List<UserModel>>>((ref) {
  return ClientsNotifier(ref.read(authDataSourceProvider), ref);
});

class ClientsNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final AuthDataSource _dataSource;
  final Ref _ref;

  ClientsNotifier(this._dataSource, this._ref) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    try {
      state = const AsyncValue.loading();
      final clients = await _dataSource.getAllUsers();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteClient(String userId) async {
    try {
      await _dataSource.deleteUser(userId);
      // Remove from local state
      state.whenData((clients) {
        state = AsyncValue.data(clients.where((c) => c.id != userId).toList());
      });
      _ref.read(scaffoldMessengerProvider).showSnackBar(
        'Cliente eliminado correctamente', 
        type: SnackBarType.success
      );
    } catch (e) {
      _ref.read(scaffoldMessengerProvider).showSnackBar(
        'Error al eliminar cliente: $e', 
        type: SnackBarType.error
      );
    }
  }

  Future<void> updateClient({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    String? email,
  }) async {
    try {
      if (role != null) {
        await _dataSource.updateUserRole(userId, role);
      }
      await _dataSource.updateOtherUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );
      
      // Refresh list to get updated data
      await loadClients();
      
      _ref.read(scaffoldMessengerProvider).showSnackBar(
        'Cliente actualizado correctamente', 
        type: SnackBarType.success
      );
    } catch (e) {
      _ref.read(scaffoldMessengerProvider).showSnackBar(
        'Error al actualizar cliente: $e', 
        type: SnackBarType.error
      );
    }
  }
}
