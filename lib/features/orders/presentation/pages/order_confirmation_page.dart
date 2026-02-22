import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../../../../config/theme/app_theme.dart';

/// Order confirmation page shown after successful checkout
class OrderConfirmationPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends ConsumerState<OrderConfirmationPage> {
  bool _isConfirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAndConfirmPayment();
  }

  // Check if we need to confirm payment (based on URL params or just always try for safety)
  // Logic: GoRouter state might have query params.
  // For now, we will assume if we land here from Stripe, we should try to confirm.
  // Ideally, we check ?payment=success
  Future<void> _checkAndConfirmPayment() async {
    // We can't easily access query params here without properly passing them from router.
    // However, calling the RPC is safe (idempotent - it checks if already paid).
    // So we will always attempt to confirm if the order is not yet paid.
    
    // Defer to next frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       // Refresh order first to see status
       await ref.refresh(orderByIdProvider(widget.orderId).future);
       final order = ref.read(orderByIdProvider(widget.orderId)).value;
       
       if (order != null && order.status == 'pending') {
         setState(() {
           _isConfirming = true;
         });

         try {
           await ref.read(orderDataSourceProvider).confirmOrderPayment(widget.orderId);
           // Refresh again to show updated status
           ref.invalidate(orderByIdProvider(widget.orderId));
         } catch (e) {
           setState(() {
             _error = 'Error confirmando el pago: $e';
           });
         } finally {
           if (mounted) {
             setState(() {
               _isConfirming = false;
             });
           }
         }
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      body: SafeArea(
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return const Center(child: Text('Pedido no encontrado'));
            }

            if (_isConfirming) {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     CircularProgressIndicator(),
                     SizedBox(height: 16),
                     Text('Confirmando pago y stock...'),
                   ],
                 ),
               );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  
                  // Success icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '¡Pedido confirmado!',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  Text(
                    'Gracias por tu compra',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Order details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles del pedido',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Número de pedido', '#${order.id.substring(0, 8)}'),
                        _buildDetailRow('Email', order.email ?? '-'),
                        _buildDetailRow('Productos', '${order.totalAmount}'),
                        _buildDetailRow(
                          'Total',
                          '€${order.totalPrice.toStringAsFixed(2)}',
                          isHighlight: true,
                        ),
                        _buildDetailRow('Estado', order.status.toUpperCase()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order items
                  if (order.items != null && order.items!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...order.items!.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'x${item.quantity}',
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '€${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Recibirás un email de confirmación en ${order.email}',
                            style: const TextStyle(color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/orders'),
                      child: const Text('Ver mis pedidos'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Seguir comprando'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
