import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../../../orders/data/datasources/order_remote_datasource.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider for OrderRemoteDataSource
final orderDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource();
});

/// Cart page with items, quantity controls, promo code, and checkout button
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    // Listen for cart errors
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.appliedPromo != previous?.appliedPromo && next.appliedPromo != null) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código "${next.appliedPromo!.code}" aplicado correctamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (cartState.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Carrito')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: AppColors.textMuted.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'Tu carrito está vacío',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Añade productos para empezar',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Ver productos'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CARRITO',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          TextButton(
            onPressed: () => _showClearCartDialog(context),
            child: const Text('Vaciar'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  blur: 10,
                  opacity: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.6,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.primaryLight 
                      : Colors.white,
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[800]),
                                errorWidget: (context, url, e) => const Icon(Icons.error),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.size != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Talla: ${item.size}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              '€${item.price.toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQuantityButton(
                                Icons.remove,
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .decrementQuantity(item.productId),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(
                                Icons.add,
                                onPressed: item.canAddMore
                                    ? () => ref
                                        .read(cartProvider.notifier)
                                        .incrementQuantity(item.productId)
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .removeItem(item.productId),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Eliminar', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildSummarySection(context, cartState),
        ],
      ),
    );
  }

  // ... (keep _buildSummarySection and _buildQuantityButton and _showClearCartDialog as is, skipping reuse for brevity if not needed, but here I must match range accurately. The replaced content must be drop-in.)
  // Wait, I started from line 35 (build). I should include the rest or use replace_file_content carefully. 
  // The tool instructions say: "StartLine and EndLine should specify a range of lines containing precisely the instances of TargetContent".
  // I will just replace `build` and `_applyPromoCode`.
  // Using multiple chunks is better.

  // Chunk 1: build method (adding listener)
  // Chunk 2: _applyPromoCode (adding try-catch)

  // ... Wait, the replace_file_content tool does NOT support skipping content in the ReplacementContent. I must provide the FULL replacement for the chunk.
  // The original prompt used `StartLine: 35`.
  
  // I will use `multi_replace_file_content` or just replace `_applyPromoCode`. 
  // Let's replace ONLY `_applyPromoCode` first, as that is where the crash is likely. 
  // And to add the listener, I need to modify `build`.
  // So I'll modify `build` start to add listener, and `_applyPromoCode` end.
  
  // Let's replace `_applyPromoCode` first.
  
  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isApplyingPromo = true);

    try {
      final promo = await ref.read(orderDataSourceProvider).validatePromoCode(code);
      if (promo != null) {
        await ref.read(cartProvider.notifier).applyPromoCode(promo);
        _promoController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código no válido'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplyingPromo = false);
      }
    }
  }

  Widget _buildSummarySection(BuildContext context, cartState) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      blur: 20,
      opacity: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.8,
      color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.primaryLight 
          : Colors.white,
      border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.05))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    decoration: InputDecoration(
                      hintText: 'Código promocional',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingPromo ? null : _applyPromoCode,
                  child: _isApplyingPromo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('€${cartState.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (cartState.discount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Descuento', style: TextStyle(color: AppColors.success)),
                  Text('-€${cartState.discount.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.success)),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '€${cartState.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Continuar al pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed != null ? AppColors.textPrimary : AppColors.textMuted,
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}
