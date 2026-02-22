import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/data/datasources/product_remote_datasource.dart';
import '../widgets/image_upload_widget.dart';

/// Modern Admin Categories Page with Cloudinary Image Upload
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _accentGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Categorías',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showCategoryDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva'),
            ),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('No hay categorías', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: _accentGradient[0]),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear categoría'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentGradient[0].withOpacity(0.3), _accentGradient[1].withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      image: category.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(category.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: category.imageUrl == null
                        ? Icon(Icons.category_rounded, color: _accentGradient[0])
                        : null,
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'slug: ${category.slug}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      _buildPopupItem('edit', Icons.edit_rounded, 'Editar', Colors.blue),
                      _buildPopupItem('delete', Icons.delete_rounded, 'Eliminar', Colors.red),
                    ],
                    onSelected: (value) => _handleAction(context, ref, value, category),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action, category) {
    switch (action) {
      case 'edit':
        _showCategoryDialog(context, ref, category: category);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, category);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar categoría', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${category.name}"? Los productos quedarán sin categoría.',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                final dataSource = ProductRemoteDataSource();
                await dataSource.deleteCategory(category.id);
                ref.invalidate(categoriesProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Categoría eliminada')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final slugController = TextEditingController(text: category?.slug ?? '');
    String? currentImageUrl = category?.imageUrl;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Editar categoría' : 'Nueva categoría',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Nombre *', onChanged: (value) {
                if (!isEditing) {
                  slugController.text = value.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
                }
              }),
              const SizedBox(height: 12),
              _buildTextField(slugController, 'Slug *'),
              const SizedBox(height: 12),
              // Replaced text field with upload widget
              ImageUploadWidget(
                label: 'Imagen de categoría',
                initialUrl: currentImageUrl,
                onImageChanged: (url) {
                  currentImageUrl = url;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentGradient[0],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (nameController.text.isEmpty || slugController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nombre y slug son requeridos')),
                );
                return;
              }

              try {
                final dataSource = ProductRemoteDataSource();
                if (isEditing) {
                  await dataSource.updateCategory(
                    id: category.id,
                    name: nameController.text,
                    slug: slugController.text,
                    imageUrl: currentImageUrl,
                  );
                } else {
                  await dataSource.createCategory(
                    name: nameController.text,
                    slug: slugController.text,
                    imageUrl: currentImageUrl,
                  );
                }
                ref.invalidate(categoriesProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Categoría actualizada' : 'Categoría creada')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentGradient[0]),
        ),
        filled: true,
        fillColor: _bgColor,
      ),
    );
  }
}
