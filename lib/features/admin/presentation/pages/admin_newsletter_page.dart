import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/admin_providers.dart';
import '../../data/models/newsletter_subscriber_model.dart';
import '../../data/datasources/admin_api_service.dart';

/// Modern Admin Newsletter Page
class AdminNewsletterPage extends ConsumerStatefulWidget {
  const AdminNewsletterPage({super.key});

  @override
  ConsumerState<AdminNewsletterPage> createState() => _AdminNewsletterPageState();
}

class _AdminNewsletterPageState extends ConsumerState<AdminNewsletterPage> with SingleTickerProviderStateMixin {
  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF14B8A6), Color(0xFF0D9488)];
  
  late TabController _tabController;
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.email_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Newsletter',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accentGradient[0],
          labelColor: _accentGradient[0],
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.edit_rounded), text: 'Crear campaña'),
            Tab(icon: Icon(Icons.people_rounded), text: 'Suscriptores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampaignEditor(),
          _buildSubscribersList(),
        ],
      ),
    );
  }

  Widget _buildCampaignEditor() {
    final subscribersCount = ref.watch(subscribersCountProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentGradient[0].withOpacity(0.2), _accentGradient[1].withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentGradient[0].withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentGradient[0].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.people_rounded, color: _accentGradient[0], size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suscriptores activos',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                    subscribersCount.when(
                      data: (count) => Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Text('...', style: TextStyle(color: Colors.white, fontSize: 24)),
                      error: (_, __) => const Text('-', style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Campaign form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva campaña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Asunto del email *',
                    hintText: 'Ej: ¡Nueva colección disponible!',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                    prefixIcon: Icon(Icons.subject_rounded, color: _accentGradient[0]),
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
                
                const SizedBox(height: 16),
                
                TextField(
                  controller: _contentController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: 'Contenido HTML *',
                    hintText: '<h1>Hola!</h1>\n<p>Te traemos novedades...</p>',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    hintStyle: TextStyle(color: Colors.grey.shade700),
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
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'El email se enviará a todos los suscriptores activos',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendCampaign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentGradient[0],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(_isSending ? 'Enviando...' : 'Enviar campaña'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersList() {
    final subscribersAsync = ref.watch(newsletterSubscribersProvider);
    
    return subscribersAsync.when(
      data: (subscribers) {
        if (subscribers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text('No hay suscriptores', style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subscribers.length,
          itemBuilder: (context, index) => _buildSubscriberCard(subscribers[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildSubscriberCard(NewsletterSubscriberModel subscriber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _accentGradient[0].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.person_rounded, color: _accentGradient[0], size: 20),
        ),
        title: Text(
          subscriber.email,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Suscrito: ${DateFormat('dd/MM/yyyy').format(subscriber.subscribedAt)}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
          onPressed: () => _confirmDeleteSubscriber(subscriber),
          tooltip: 'Eliminar',
        ),
      ),
    );
  }

  Future<void> _sendCampaign() async {
    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asunto y contenido son requeridos')),
      );
      return;
    }
    
    setState(() => _isSending = true);
    
    try {
      final success = await AdminApiService().sendNewsletterCampaign(
        subject: _subjectController.text,
        content: _contentController.text,
      );
      
      if (mounted) {
        if (success) {
          _subjectController.clear();
          _contentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Campaña enviada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar la campaña. Verifica CORS en el servidor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _confirmDeleteSubscriber(NewsletterSubscriberModel subscriber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar suscriptor', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${subscriber.email}"?',
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
                await Supabase.instance.client
                    .from('newsletter_subscribers')
                    .delete()
                    .eq('id', subscriber.id);
                
                ref.invalidate(newsletterSubscribersProvider);
                ref.invalidate(subscribersCountProvider);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Suscriptor eliminado')),
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
}
