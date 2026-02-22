import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/datasources/order_remote_datasource.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/datasources/admin_api_service.dart';

/// Modern Admin Orders Page with Filtering
class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String _selectedStatus = 'all';

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF10B981), Color(0xFF059669)];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);

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
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pedidos',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => ref.invalidate(allOrdersProvider),
            tooltip: 'Actualizar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all'),
                _buildFilterChip('Pendientes', 'pending', color: AppColors.pending),
                _buildFilterChip('Pagados', 'paid', color: AppColors.paid),
                _buildFilterChip('Enviados', 'shipped', color: AppColors.shipped),
                _buildFilterChip('Entregados', 'delivered', color: AppColors.delivered),
                _buildFilterChip('Cancelados', 'cancelled', color: AppColors.cancelled),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Filter logic
                final filteredOrders = _selectedStatus == 'all'
                    ? orders
                    : orders.where((o) => o.status == _selectedStatus).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off_rounded, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'all' 
                              ? 'No hay pedidos aún' 
                              : 'No hay pedidos ${_getStatusLabel(_selectedStatus).toLowerCase()}',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: order.status.statusColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.receipt_rounded,
                                          color: order.status.statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '#${order.id.substring(0, 8).toUpperCase()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              order.email ?? 'Sin email',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusDropdown(context, ref, order),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Divider
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Order details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoChip(Icons.shopping_bag_outlined, '${order.totalAmount} productos'),
                                Text(
                                  '€${order.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            
                            if (order.shippingAddress != null) ...[
                              const SizedBox(height: 12),
                              // Clean address string if it's JSON-like
                              _buildInfoChip(
                                Icons.location_on_outlined, 
                                _formatAddress(order.shippingAddress!),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status, {Color? color}) {
    final isSelected = _selectedStatus == status;
    final activeColor = color ?? Colors.white;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: activeColor.withOpacity(0.2),
        checkmarkColor: activeColor,
        labelStyle: TextStyle(
          color: isSelected ? activeColor : Colors.grey.shade400,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? activeColor.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  String _formatAddress(String rawAddress) {
    // Try to parse if it looks like JSON or leave as is
    if (rawAddress.startsWith('{') && rawAddress.contains('address')) {
      // Simple string manipulation to extract address for cleaner view
      // Just a quick regex or split if we assume the structure from the screenshot
      try {
        final addressMatch = RegExp(r'"address":"([^"]+)"').firstMatch(rawAddress);
        if (addressMatch != null) return addressMatch.group(1) ?? rawAddress;
      } catch (_) {}
    }
    return rawAddress;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pendientes';
      case 'paid': return 'Pagados';
      case 'shipped': return 'Enviados';
      case 'delivered': return 'Entregados';
      case 'cancelled': return 'Cancelados';
      default: return '';
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context, WidgetRef ref, OrderModel order) {
    final statuses = ['pending', 'paid', 'shipped', 'delivered', 'completed', 'cancelled'];
    
    // Ensure the current order status is in the list, otherwise add it to prevent crash
    if (!statuses.contains(order.status) && order.status.isNotEmpty) {
      statuses.add(order.status);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: order.status.statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: order.status.statusColor.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: order.status,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: order.status.statusColor, size: 18),
          dropdownColor: _cardColor,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            color: order.status.statusColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: statuses.map((s) => DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: s.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(s.statusLabel, style: TextStyle(color: s.statusColor)),
              ],
            ),
          )).toList(),
          onChanged: (newStatus) async {
            if (newStatus != null && newStatus != order.status) {
              try {
                // Use AdminApiService so the backend sends the email
                final result = await AdminApiService().updateOrderStatus(
                  orderId: order.id, 
                  status: newStatus
                );
                
                if (result != null) {
                  ref.invalidate(allOrdersProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Estado actualizado a ${newStatus.statusLabel}')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar estado. Verifica el servidor.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}
