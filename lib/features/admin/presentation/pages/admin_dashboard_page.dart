import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../../config/theme/app_theme.dart';
import '../widgets/revenue_chart.dart';

/// Modern Admin Dashboard with redesigned UI
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersCountAsync = ref.watch(ordersCountByStatusProvider);
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F23),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Panel Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () => context.go('/'),
                  tooltip: 'Ver tienda',
                ),
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.widgets_rounded, color: Colors.white, size: 20),
                ),
                tooltip: 'Acciones Rápidas',
                offset: const Offset(0, 50),
                color: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                onSelected: (route) => context.push(route),
                itemBuilder: (context) => [
                  _buildMenuItem(Icons.inventory_2_rounded, 'Productos', '/admin/products', Colors.blue),
                  _buildMenuItem(Icons.receipt_long_rounded, 'Pedidos', '/admin/orders', Colors.green),
                  _buildMenuItem(Icons.people_alt_rounded, 'Clientes', '/admin/clients', Colors.purple),
                  _buildMenuItem(Icons.category_rounded, 'Categorías', '/admin/categories', Colors.deepPurple),
                  _buildMenuItem(Icons.local_offer_rounded, 'Promociones', '/admin/promotions', Colors.orange),
                  _buildMenuItem(Icons.receipt_rounded, 'Facturación', '/admin/invoices', Colors.teal),
                  _buildMenuItem(Icons.photo_library_rounded, 'Galería', '/admin/gallery', Colors.pink),
                  _buildMenuItem(Icons.article_rounded, 'Noticias', '/admin/news', Colors.cyan),
                  _buildMenuItem(Icons.campaign_rounded, 'Pop-ups', '/admin/popups', Colors.deepOrange),
                  _buildMenuItem(Icons.email_rounded, 'Newsletter', '/admin/newsletter', Colors.teal),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Grid
                _buildStatsSection(context, ref, ordersCountAsync, productsAsync, categoriesAsync, isWide),
                
                const SizedBox(height: 24),



                // Analytics Chart
                _buildAnalyticsSection(context, ref),

                const SizedBox(height: 24),

                // Recent Orders
                _buildRecentOrdersSection(context, ref),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, int>> ordersCountAsync,
    AsyncValue productsAsync,
    AsyncValue categoriesAsync,
    bool isWide,
  ) {
    final stats = [
      _StatData(
        icon: Icons.inventory_2_rounded,
        title: 'Productos',
        value: productsAsync.whenOrNull(data: (p) => p.length.toString()) ?? '...',
        gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      ),
      _StatData(
        icon: Icons.category_rounded,
        title: 'Categorías',
        value: categoriesAsync.whenOrNull(data: (c) => c.length.toString()) ?? '...',
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      ),
      _StatData(
        icon: Icons.pending_actions_rounded,
        title: 'Pendientes',
        value: ordersCountAsync.whenOrNull(data: (c) => (c['pending'] ?? 0).toString()) ?? '...',
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      ),
      _StatData(
        icon: Icons.local_shipping_rounded,
        title: 'Enviados',
        value: ordersCountAsync.whenOrNull(data: (c) => (c['shipped'] ?? 0).toString()) ?? '...',
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((stat) => SizedBox(
        width: isWide ? (MediaQuery.of(context).size.width - 80) / 4 : (MediaQuery.of(context).size.width - 56) / 2,
        child: _buildStatCard(stat),
      )).toList(),
    );
  }

  Widget _buildStatCard(_StatData stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.gradient[0].withOpacity(0.15),
            stat.gradient[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stat.gradient[0].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: stat.gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: stat.gradient[0],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String title, String route, MaterialColor color) {
    return PopupMenuItem(
      value: route,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Analíticas de Ventas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: ref.watch(allOrdersProvider).when(
            data: (orders) => RevenueChart(orders: orders),
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Error cargando analíticas',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pedidos Recientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push('/admin/orders'),
              icon: const Text('Ver todos', style: TextStyle(color: Color(0xFF6366F1))),
              label: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF6366F1)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ref.watch(allOrdersProvider).when(
          data: (orders) {
            final recentOrders = orders.take(5).toList();
            if (recentOrders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade600),
                      const SizedBox(height: 12),
                      Text(
                        'Sin pedidos recientes',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: order.status.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        color: order.status.statusColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    subtitle: Text(
                      order.email ?? 'Sin email',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: order.status.statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.status.statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: order.status.statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class _StatData {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> gradient;

  _StatData({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  });
}


