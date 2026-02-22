import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/admin_providers.dart';
import '../../data/models/news_model.dart';
import '../widgets/image_upload_widget.dart';

/// Modern Admin News Page with Cloudinary Image Upload
class AdminNewsPage extends ConsumerWidget {
  const AdminNewsPage({super.key});

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
  static const _baseUrl = 'https://slccuts.es';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    
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
              child: const Icon(Icons.article_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Noticias / Blog',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showNewsDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva'),
            ),
          ),
        ],
      ),
      body: newsAsync.when(
        data: (news) {
          if (news.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            itemBuilder: (context, index) => _buildNewsCard(context, ref, news[index]),
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
          Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text('No hay publicaciones', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showNewsDialog(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: _accentGradient[0]),
            icon: const Icon(Icons.add),
            label: const Text('Crear publicación'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, WidgetRef ref, NewsModel news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image
            if (news.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 120,
                  child: Image.network(
                    news.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _bgColor,
                      child: Icon(Icons.image, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            news.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: news.isPublished 
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            news.isPublished ? 'PUBLICADO' : 'BORRADOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: news.isPublished ? const Color(0xFF10B981) : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.content,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(news.createdAt),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const Spacer(),
                        _buildActionButton(
                          icon: news.isPublished ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          onTap: () => _togglePublished(context, ref, news),
                          tooltip: news.isPublished ? 'Despublicar' : 'Publicar',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.open_in_new_rounded,
                          onTap: () => _openInWeb(context, news),
                          tooltip: 'Ver en web',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          onTap: () => _showNewsDialog(context, ref, news: news),
                          tooltip: 'Editar',
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.red,
                          onTap: () => _confirmDelete(context, ref, news),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: color ?? Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Future<void> _togglePublished(BuildContext context, WidgetRef ref, NewsModel news) async {
    try {
      await Supabase.instance.client.from('news').update({
        'is_published': !news.isPublished,
        if (!news.isPublished) 'published_at': DateTime.now().toIso8601String(),
      }).eq('id', news.id);
      
      ref.invalidate(newsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(news.isPublished ? 'Despublicado' : 'Publicado'),
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

  Future<void> _openInWeb(BuildContext context, NewsModel news) async {
    final url = Uri.parse('$_baseUrl/blog/${news.slug ?? news.id}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, NewsModel news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar publicación', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${news.title}"?',
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
                await Supabase.instance.client.from('news').delete().eq('id', news.id);
                ref.invalidate(newsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada')),
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

  void _showNewsDialog(BuildContext context, WidgetRef ref, {NewsModel? news}) {
    final isEditing = news != null;
    final titleController = TextEditingController(text: news?.title ?? '');
    final contentController = TextEditingController(text: news?.content ?? '');
    final slugController = TextEditingController(text: news?.slug ?? '');
    String? currentImageUrl = news?.imageUrl;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Editar publicación' : 'Nueva publicación',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Título *', onChanged: (value) {
                  if (!isEditing) {
                    slugController.text = value.toLowerCase()
                        .replaceAll(' ', '-')
                        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
                  }
                }),
                const SizedBox(height: 12),
                _buildTextField(slugController, 'Slug'),
                const SizedBox(height: 12),
                // Replaced text field with upload widget
                ImageUploadWidget(
                  label: 'Imagen de portada',
                  initialUrl: currentImageUrl,
                  onImageChanged: (url) {
                    currentImageUrl = url;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Contenido *',
                    alignLabelWithHint: true,
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
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Título y contenido son requeridos')),
                );
                return;
              }

              try {
                final data = {
                  'title': titleController.text,
                  'content': contentController.text,
                  'slug': slugController.text.isNotEmpty ? slugController.text : null,
                  'image_url': currentImageUrl,
                };

                if (isEditing) {
                  await Supabase.instance.client.from('news').update(data).eq('id', news.id);
                } else {
                  await Supabase.instance.client.from('news').insert(data);
                }
                
                ref.invalidate(newsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Publicación actualizada' : 'Publicación creada')),
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
