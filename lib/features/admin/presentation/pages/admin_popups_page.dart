import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/admin_providers.dart';
import '../../data/models/popup_model.dart';
import '../widgets/image_upload_widget.dart';

/// Modern Admin Popups Page with Cloudinary Image Upload
class AdminPopupsPage extends ConsumerWidget {
  const AdminPopupsPage({super.key});

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFFF97316), Color(0xFFEA580C)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popupsAsync = ref.watch(popupsProvider);
    
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
              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pop-ups',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showPopupDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nuevo'),
            ),
          ),
        ],
      ),
      body: popupsAsync.when(
        data: (popups) {
          if (popups.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: popups.length,
            itemBuilder: (context, index) => _buildPopupCard(context, ref, popups[index], popups),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text('No hay pop-ups', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showPopupDialog(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: _accentGradient[0]),
            icon: const Icon(Icons.add),
            label: const Text('Crear pop-up'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context, WidgetRef ref, PopupModel popup, List<PopupModel> allPopups) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: popup.isActive 
              ? _accentGradient[0].withOpacity(0.5)
              : Colors.white.withOpacity(0.05),
          width: popup.isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
                image: popup.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(popup.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: popup.imageUrl == null
                  ? Icon(Icons.image_rounded, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          popup.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (popup.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _accentGradient),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (popup.content != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      popup.content!,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(popup.createdAt),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (popup.buttonText != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.touch_app_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          popup.buttonText!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                Switch(
                  value: popup.isActive,
                  onChanged: (value) => _toggleActive(context, ref, popup, value, allPopups),
                  activeColor: _accentGradient[0],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: Colors.grey.shade400, size: 20),
                      onPressed: () => _showPopupDialog(context, ref, popup: popup),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(context, ref, popup),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    PopupModel popup,
    bool value,
    List<PopupModel> allPopups,
  ) async {
    try {
      // If activating, deactivate all others first
      if (value) {
        for (final p in allPopups.where((p) => p.id != popup.id && p.isActive)) {
          await Supabase.instance.client
              .from('popups')
              .update({'is_active': false})
              .eq('id', p.id);
        }
      }
      
      await Supabase.instance.client
          .from('popups')
          .update({'is_active': value})
          .eq('id', popup.id);
      
      ref.invalidate(popupsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Pop-up activado' : 'Pop-up desactivado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PopupModel popup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar pop-up', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${popup.title}"?',
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
                await Supabase.instance.client.from('popups').delete().eq('id', popup.id);
                ref.invalidate(popupsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pop-up eliminado')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showPopupDialog(BuildContext context, WidgetRef ref, {PopupModel? popup}) {
    final isEditing = popup != null;
    final titleController = TextEditingController(text: popup?.title ?? '');
    final contentController = TextEditingController(text: popup?.content ?? '');
    final buttonTextController = TextEditingController(text: popup?.buttonText ?? '');
    final buttonUrlController = TextEditingController(text: popup?.buttonUrl ?? '');
    String? currentImageUrl = popup?.imageUrl;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Editar pop-up' : 'Nuevo pop-up',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Título *'),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: _inputDecoration('Contenido'),
                ),
                const SizedBox(height: 12),
                // Replaced text field with upload widget
                ImageUploadWidget(
                  label: 'Imagen (opcional)',
                  initialUrl: currentImageUrl,
                  onImageChanged: (url) {
                    currentImageUrl = url;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(buttonTextController, 'Texto del botón')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(buttonUrlController, 'URL del botón')),
                  ],
                ),
              ],
            ),
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
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El título es requerido')),
                );
                return;
              }

              try {
                final data = {
                  'title': titleController.text,
                  'content': contentController.text.isNotEmpty ? contentController.text : null,
                  'image_url': currentImageUrl,
                  'button_text': buttonTextController.text.isNotEmpty ? buttonTextController.text : null,
                  'button_link': buttonUrlController.text.isNotEmpty ? buttonUrlController.text : null,
                };

                if (isEditing) {
                  await Supabase.instance.client.from('popups').update(data).eq('id', popup.id);
                } else {
                  await Supabase.instance.client.from('popups').insert(data);
                }
                
                ref.invalidate(popupsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Pop-up actualizado' : 'Pop-up creado')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }
}
