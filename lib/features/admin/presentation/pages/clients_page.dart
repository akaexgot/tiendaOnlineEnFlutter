import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slc_cuts/features/auth/data/models/user_model.dart';
import 'package:slc_cuts/features/admin/presentation/providers/clients_provider.dart';
import 'package:intl/intl.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        title: const Text('Gestión de Clientes', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return const Center(
              child: Text('No hay clientes registrados', style: TextStyle(color: Colors.white)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final client = clients[index];
              return _ClientCard(client: client);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _ClientCard extends ConsumerWidget {
  final UserModel client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: client.isAdmin ? Colors.purple : Colors.blue,
          child: Text(
            client.firstName?.isNotEmpty == true ? client.firstName![0].toUpperCase() : client.email[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          client.fullName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(client.email, style: const TextStyle(color: Colors.grey)),
            if (client.phone != null) ...[
              const SizedBox(height: 2),
              Text(client.phone!, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _RoleBadge(isAdmin: client.isAdmin),
                const SizedBox(width: 8),
                Text(
                  'Registrado: ${client.createdAt != null ? DateFormat('dd/MM/yyyy').format(client.createdAt!) : 'N/A'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2D2D44),
          onSelected: (value) async {
            if (value == 'edit') {
              await showDialog(
                context: context,
                builder: (_) => _EditClientDialog(client: client),
              );
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                   backgroundColor: const Color(0xFF2D2D44),
                  title: const Text('Eliminar Cliente', style: TextStyle(color: Colors.white)),
                  content: Text(
                    '¿Estás seguro de eliminar a ${client.fullName}?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                 await ref.read(clientsProvider.notifier).deleteClient(client.id);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                   Icon(Icons.delete, color: Colors.red, size: 20),
                   SizedBox(width: 8),
                   Text('Eliminar', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAdmin ? Colors.purple.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'CLIENTE',
        style: TextStyle(
          color: isAdmin ? Colors.purple[200] : Colors.blue[200],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EditClientDialog extends ConsumerStatefulWidget {
  final UserModel client;

  const _EditClientDialog({required this.client});

  @override
  ConsumerState<_EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends ConsumerState<_EditClientDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _role;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.client.firstName);
    _lastNameController = TextEditingController(text: widget.client.lastName);
    _phoneController = TextEditingController(text: widget.client.phone);
    _emailController = TextEditingController(text: widget.client.email);
    _role = widget.client.role;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D44),
      title: const Text('Editar Cliente', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(controller: _firstNameController, label: 'Nombre'),
            const SizedBox(height: 12),
            _buildTextField(controller: _lastNameController, label: 'Apellido'),
            const SizedBox(height: 12),
            _buildTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 12),
            _buildTextField(controller: _phoneController, label: 'Teléfono'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              dropdownColor: const Color(0xFF2D2D44),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              items: const [
                DropdownMenuItem(value: 'client', child: Text('Cliente')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _role = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ref.read(clientsProvider.notifier).updateClient(
              userId: widget.client.id,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              role: _role,
            );
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      ),
    );
  }
}
