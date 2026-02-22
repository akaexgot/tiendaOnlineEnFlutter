import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/data/datasources/product_remote_datasource.dart';
import '../widgets/image_upload_widget.dart';

/// Modern Admin Products Page with Cloudinary Image Upload
class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

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
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Productos',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showProductDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nuevo'),
            ),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('No hay productos', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: _accentGradient[0]),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear producto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
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
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                      image: product.mainImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(product.mainImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.mainImageUrl == null
                        ? const Icon(Icons.image_rounded, color: Colors.grey)
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!product.active)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'INACTIVO',
                            style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          '€${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.inventory_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${product.stockQuantity} uds',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                        if (product.isOffer) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('OFERTA', style: TextStyle(fontSize: 9, color: Colors.orange)),
                          ),
                        ],
                        if (product.isFeatured) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('DESTACADO', style: TextStyle(fontSize: 9, color: Colors.purple)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      _buildPopupItem('edit', Icons.edit_rounded, 'Editar', Colors.blue),
                      _buildPopupItem('toggle', product.active ? Icons.visibility_off : Icons.visibility, 
                          product.active ? 'Desactivar' : 'Activar', Colors.orange),
                      _buildPopupItem('stock', Icons.inventory_rounded, 'Stock', Colors.green),
                      _buildPopupItem('delete', Icons.delete_rounded, 'Eliminar', Colors.red),
                    ],
                    onSelected: (value) => _handleAction(context, ref, value, product),
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

  void _handleAction(BuildContext context, WidgetRef ref, String action, product) {
    switch (action) {
      case 'edit':
        _showProductDialog(context, ref, product: product);
        break;
      case 'toggle':
        _toggleProduct(ref, product);
        break;
      case 'stock':
        _showStockDialog(context, ref, product);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, product);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar producto', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.name}"?',
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
              final dataSource = ProductRemoteDataSource();
              await dataSource.deleteProduct(product.id);
              ref.invalidate(adminProductsProvider);
              ref.invalidate(productsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, {product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final slugController = TextEditingController(text: product?.slug ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    bool isOffer = product?.isOffer ?? false;
    bool isFeatured = product?.isFeatured ?? false;
    String? currentImageUrl = product?.mainImageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Editar producto' : 'Nuevo producto',
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
                _buildTextField(descriptionController, 'Descripción', maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField(priceController, 'Precio (€) *', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                // Replaced text field with upload widget
                ImageUploadWidget(
                  label: 'Imagen principal',
                  initialUrl: currentImageUrl,
                  onImageChanged: (url) {
                    currentImageUrl = url;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckbox('Oferta', isOffer, (v) => setState(() => isOffer = v ?? false)),
                    ),
                    Expanded(
                      child: _buildCheckbox('Destacado', isFeatured, (v) => setState(() => isFeatured = v ?? false)),
                    ),
                  ],
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
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre y precio son requeridos')),
                  );
                  return;
                }

                  try {
                  final dataSource = ProductRemoteDataSource();
                  if (isEditing) {
                    await dataSource.updateProduct(
                      id: product.id,
                      name: nameController.text,
                      slug: slugController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      isOffer: isOffer,
                      isFeatured: isFeatured,
                      // Image update is handled separately
                    );
                    
                    if (currentImageUrl != null && currentImageUrl != product.mainImageUrl) {
                      await dataSource.setMainImage(product.id, currentImageUrl!);
                    }
                  } else {
                    await dataSource.createProduct(
                      name: nameController.text,
                      slug: slugController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      isOffer: isOffer,
                      isFeatured: isFeatured,
                      imageUrls: currentImageUrl != null ? [currentImageUrl!] : null,
                    );
                  }
                  ref.invalidate(adminProductsProvider);
                  ref.invalidate(productsProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Producto actualizado' : 'Producto creado')),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        filled: true,
        fillColor: _bgColor,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: _accentGradient[0],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Future<void> _toggleProduct(WidgetRef ref, product) async {
    final dataSource = ProductRemoteDataSource();
    await dataSource.updateProduct(id: product.id, active: !product.active);
    ref.invalidate(adminProductsProvider);
    ref.invalidate(productsProvider);
  }

  void _showStockDialog(BuildContext context, WidgetRef ref, product) {
    final stockController = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Actualizar Stock', style: TextStyle(color: Colors.white)),
        content: _buildTextField(stockController, 'Cantidad', keyboardType: TextInputType.number),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final dataSource = ProductRemoteDataSource();
              await dataSource.updateStock(product.id, int.tryParse(stockController.text) ?? 0);
              ref.invalidate(adminProductsProvider);
              ref.invalidate(productsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock actualizado')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
