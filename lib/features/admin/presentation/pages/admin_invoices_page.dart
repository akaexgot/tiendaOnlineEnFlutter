import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../providers/admin_providers.dart';

/// Modern Admin Invoices Page
class AdminInvoicesPage extends ConsumerStatefulWidget {
  const AdminInvoicesPage({super.key});

  @override
  ConsumerState<AdminInvoicesPage> createState() => _AdminInvoicesPageState();
}

class _AdminInvoicesPageState extends ConsumerState<AdminInvoicesPage> {
  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFF22C55E), Color(0xFF16A34A)];
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final dateRange = _startDate != null && _endDate != null 
        ? AdminDateRange(start: _startDate!, end: _endDate!)
        : null;
    final statsAsync = ref.watch(invoiceStatsProvider(dateRange));
    final ordersAsync = ref.watch(paidOrdersProvider);
    
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
              'Facturación',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date filter
            _buildDateFilter(),
            
            const SizedBox(height: 20),
            
            // Stats cards
            statsAsync.when(
              data: (stats) => _buildStatsRow(stats),
              loading: () => _buildStatsRow({'total': 0.0, 'online': 0.0, 'local': 0.0}),
              error: (_, __) => _buildStatsRow({'total': 0.0, 'online': 0.0, 'local': 0.0}),
            ),
            
            const SizedBox(height: 24),
            
            // Invoices list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Facturas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDownloadOptions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentGradient[0],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Descargar'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Invoices list
            ordersAsync.when(
              data: (orders) {
                final filteredOrders = _filterOrdersByDate(orders);
                
                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }
                
                return Column(
                  children: filteredOrders.map((order) => _buildInvoiceCard(order)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrdersByDate(List<Map<String, dynamic>> orders) {
    if (_startDate == null || _endDate == null) return orders;
    
    return orders.where((order) {
      final createdAt = DateTime.tryParse(order['created_at'] ?? '');
      if (createdAt == null) return false;
      return createdAt.isAfter(_startDate!) && createdAt.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              label: 'Desde',
              date: _startDate,
              onTap: () => _selectDate(true),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateButton(
              label: 'Hasta',
              date: _endDate,
              onTap: () => _selectDate(false),
            ),
          ),
          const SizedBox(width: 12),
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              tooltip: 'Limpiar filtro',
            ),
        ],
      ),
    );
  }

  Widget _buildDateButton({required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: _accentGradient[0]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentGradient[0],
              surface: _cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildStatsRow(Map<String, double> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', stats['total'] ?? 0, Icons.account_balance_wallet_rounded, _accentGradient)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Online', stats['online'] ?? 0, Icons.credit_card_rounded, [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)])),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Local', stats['local'] ?? 0, Icons.store_rounded, [const Color(0xFFF59E0B), const Color(0xFFD97706)])),
      ],
    );
  }

  Widget _buildStatCard(String label, double amount, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient[0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: gradient[0],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'No hay facturas en este período',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String? ?? '';
    final status = order['status'] as String? ?? 'pending';
    final totalPrice = ((order['total_price'] as num?) ?? 0) / 100;
    final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final email = order['customer_email'] ?? order['guest_email'] ?? '-';
    final paymentMethod = order['payment_method'] as String? ?? '-';
    final items = order['order_items'] as List? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentGradient[0].withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_rounded, color: _accentGradient[0], size: 20),
          ),
          title: Row(
            children: [
              Text(
                '#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'delivered' 
                      ? _accentGradient[0].withOpacity(0.15)
                      : Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 10,
                    color: status == 'delivered' ? _accentGradient[0] : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${DateFormat('dd/MM/yyyy').format(createdAt)} · $email',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          trailing: Text(
            '€${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: _accentGradient[0],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: [
            // Invoice details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Método de pago:', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(
                        paymentMethod == 'card' || paymentMethod == 'stripe' ? 'Tarjeta' : 'Local',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Productos:', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text('${items.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    ...items.map((item) {
                      final name = item['product_name'] ?? 'Producto';
                      final qty = item['quantity'] ?? 1;
                      final price = ((item['price'] as num?) ?? 0) / 100;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$qty x $name',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '€${(price * qty).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _downloadSingleInvoice(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      side: BorderSide(color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Descargar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showInvoicePreview(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentGradient[0],
                      side: BorderSide(color: _accentGradient[0]),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('Ver factura'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid': return 'PAGADO';
      case 'shipped': return 'ENVIADO';
      case 'delivered': return 'ENTREGADO';
      default: return status.toUpperCase();
    }
  }

  void _showDownloadOptions() {
    final ordersAsync = ref.read(paidOrdersProvider);
    
    ordersAsync.whenData((orders) {
      final filteredOrders = _filterOrdersByDate(orders);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Descargar Facturas', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.receipt_long_rounded, color: _accentGradient[0]),
                title: const Text('Todas las facturas', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${filteredOrders.length} facturas',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _downloadAllInvoicesCSV(filteredOrders);
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.summarize_rounded, color: _accentGradient[0]),
                title: const Text('Resumen', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Totales por método de pago',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _downloadSummaryCSV(filteredOrders);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
            ),
          ],
        ),
      );
    });
  }

  void _downloadAllInvoicesCSV(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay facturas para descargar')),
      );
      return;
    }

    // Generate CSV
    final List<List<dynamic>> rows = [
      ['ID Pedido', 'Fecha', 'Cliente', 'Total (€)', 'Método de Pago', 'Estado', 'Productos']
    ];

    for (final order in orders) {
      final orderId = (order['id'] as String? ?? '').substring(0, 8).toUpperCase();
      final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
      final email = order['customer_email'] ?? order['guest_email'] ?? '-';
      final totalPrice = ((order['total_price'] as num?) ?? 0) / 100;
      final paymentMethod = order['payment_method'] == 'card' || order['payment_method'] == 'stripe' ? 'Tarjeta' : 'Local';
      final status = _statusLabel(order['status'] ?? 'pending');
      final items = order['order_items'] as List? ?? [];
      final productsCount = items.length;

      rows.add([
        orderId,
        DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
        email,
        totalPrice.toStringAsFixed(2),
        paymentMethod,
        status,
        productsCount.toString(),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    _downloadFile(csvData, 'facturas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${orders.length} facturas descargadas'),
        backgroundColor: _accentGradient[0],
      ),
    );
  }

  void _downloadSummaryCSV(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para el resumen')),
      );
      return;
    }

    double totalOnline = 0;
    double totalLocal = 0;
    int countOnline = 0;
    int countLocal = 0;

    for (final order in orders) {
      final price = ((order['total_price'] as num?) ?? 0) / 100;
      final paymentMethod = order['payment_method'] as String? ?? '';

      if (paymentMethod == 'card' || paymentMethod == 'stripe') {
        totalOnline += price;
        countOnline++;
      } else {
        totalLocal += price;
        countLocal++;
      }
    }

    final List<List<dynamic>> rows = [
      ['Resumen de Facturación'],
      [''],
      ['Período', _startDate != null && _endDate != null 
          ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
          : 'Todas las fechas'],
      [''],
      ['Método de Pago', 'Cantidad', 'Total (€)'],
      ['Tarjeta', countOnline.toString(), totalOnline.toStringAsFixed(2)],
      ['Local', countLocal.toString(), totalLocal.toStringAsFixed(2)],
      [''],
      ['TOTAL', (countOnline + countLocal).toString(), (totalOnline + totalLocal).toStringAsFixed(2)],
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    _downloadFile(csvData, 'resumen_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Resumen descargado'),
        backgroundColor: _accentGradient[0],
      ),
    );
  }

  void _downloadSingleInvoice(Map<String, dynamic> order) {
    final orderId = (order['id'] as String? ?? '').substring(0, 8).toUpperCase();
    final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final email = order['customer_email'] ?? order['guest_email'] ?? '-';
    final totalPrice = ((order['total_price'] as num?) ?? 0) / 100;
    final paymentMethod = order['payment_method'] == 'card' || order['payment_method'] == 'stripe' ? 'Tarjeta' : 'Local';
    final items = order['order_items'] as List? ?? [];

    final List<List<dynamic>> rows = [
      ['FACTURA #$orderId'],
      [''],
      ['Fecha', DateFormat('dd/MM/yyyy HH:mm').format(createdAt)],
      ['Cliente', email],
      ['Método de Pago', paymentMethod],
      [''],
      ['Producto', 'Cantidad', 'Precio Unit. (€)', 'Total (€)'],
    ];

    for (final item in items) {
      final name = item['product_name'] ?? 'Producto';
      final qty = item['quantity'] ?? 1;
      final price = ((item['price'] as num?) ?? 0) / 100;
      rows.add([name, qty.toString(), price.toStringAsFixed(2), (price * qty).toStringAsFixed(2)]);
    }

    rows.addAll([
      [''],
      ['TOTAL', '', '', totalPrice.toStringAsFixed(2)],
    ]);

    final csvData = const ListToCsvConverter().convert(rows);
    _downloadFile(csvData, 'factura_${orderId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Factura #$orderId descargada'),
        backgroundColor: _accentGradient[0],
      ),
    );
  }

  void _downloadFile(String content, String filename) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showInvoicePreview(Map<String, dynamic> order) {
    final orderId = order['id'] as String? ?? '';
    final totalPrice = ((order['total_price'] as num?) ?? 0) / 100;
    final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final email = order['customer_email'] ?? order['guest_email'] ?? '-';
    final items = order['order_items'] as List? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FACTURA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                style: TextStyle(
                  color: _accentGradient[0],
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInvoiceRow('Fecha', DateFormat('dd/MM/yyyy').format(createdAt)),
              _buildInvoiceRow('Cliente', email),
              
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              
              const Text('Productos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((item) {
                final name = item['product_name'] ?? 'Producto';
                final qty = item['quantity'] ?? 1;
                final price = ((item['price'] as num?) ?? 0) / 100;
                return _buildInvoiceRow('$qty x $name', '€${(price * qty).toStringAsFixed(2)}');
              }),
              
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '€${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _accentGradient[0],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
