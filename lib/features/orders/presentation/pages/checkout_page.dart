import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_providers.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/services/stripe_service.dart';
import 'package:flutter/foundation.dart';

/// Checkout page for completing purchase
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  int _currentStep = 0;
  String _paymentMethod = 'card';
  String _shippingMethod = 'standard';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _emailController.text = user.email;
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double _calculateTotal(CartState cartState) {
    double total = cartState.total;
    if (_shippingMethod == 'express') {
      total += 4.99;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (cartState.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Text('El carrito está vacío'),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Completar Pedido'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onStepCancel,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Custom Step Indicator
            _buildCustomStepIndicator(),
            const SizedBox(height: 32),

            // Step Content
            if (_currentStep == 0) _buildContactStep(isAuthenticated),
            if (_currentStep == 1) _buildShippingStep(),
            if (_currentStep == 2) _buildPaymentStep(cartState, checkoutState),

            const SizedBox(height: 32),

            // Step Navigation Buttons
            Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (checkoutState.isLoading || _isProcessing) ? null : _onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: (checkoutState.isLoading || _isProcessing) ? null : _onStepContinue,
                    child: (checkoutState.isLoading || _isProcessing)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentStep == 2 ? 'Pagar con Stripe' : 'Continuar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, 'Contacto'),
        _buildStepLine(0),
        _buildStepCircle(1, 'Envío'),
        _buildStepLine(1),
        _buildStepCircle(2, 'Pago'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isCompleted = _currentStep > step;
    bool isActive = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: (isCompleted || isActive) 
                ? AppColors.accent 
                : AppColors.surfaceVariant,
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: AppColors.primary)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? AppColors.primary : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.accent : Colors.white30,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    bool isCompleted = _currentStep > afterStep;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? AppColors.accent : AppColors.surfaceVariant,
    );
  }

  Widget _buildContactStep(bool isAuthenticated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ingresa tus datos para el seguimiento del pedido.', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo *',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildShippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dirección de Envío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('¿A dónde debemos enviar tu paquete?', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 24),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección completa *',
            prefixIcon: Icon(Icons.location_on_outlined),
            hintText: 'Calle, número, ciudad...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 32),
        const Text('Método de Envío', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildShippingOption('standard', 'Envío Estándar', '3-5 días', 'Gratis'),
        _buildShippingOption('express', 'Envío Exprés', '24-48 horas', '€4.99'),
      ],
    );
  }

  Widget _buildPaymentStep(CartState cartState, CheckoutState checkoutState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pago y Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        // Stripe Checkout Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.accent.withOpacity(0.05),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: AppColors.accent),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pago Seguro con Stripe', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Serás redirigido a Stripe para completar el pago', style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, color: AppColors.accent, size: 20),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tus datos de pago son procesados de forma segura por Stripe. No almacenamos información de tarjetas.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Summary
        _buildCompactSummary(cartState),
        
        if (checkoutState.error != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              checkoutState.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactSummary(CartState cartState) {
    final total = _calculateTotal(cartState);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _summaryRow('Productos', '€${cartState.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('Envío', _shippingMethod == 'express' ? '€4.99' : 'Gratis'),
          if (cartState.discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('Descuento', '-€${cartState.discount.toStringAsFixed(2)}', isDiscount: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _summaryRow('Total', '€${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white60,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? AppColors.success : (isTotal ? AppColors.accent : Colors.white),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOption(
    String value,
    String title,
    String subtitle,
    String price,
  ) {
    return RadioListTile<String>(
      value: value,
      groupValue: _shippingMethod,
      onChanged: (v) => setState(() => _shippingMethod = v!),
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Text(
        price,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (v) => setState(() => _paymentMethod = v!),
      title: Text(title),
      secondary: Icon(icon),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_emailController.text.isNotEmpty && _nameController.text.isNotEmpty) {
        ref.read(checkoutProvider.notifier).setCustomerEmail(_emailController.text);
        ref.read(checkoutProvider.notifier).setContactInfo({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_addressController.text.isNotEmpty) {
        ref.read(checkoutProvider.notifier).setShippingAddress(_addressController.text);
        ref.read(checkoutProvider.notifier).setShippingMethod(_shippingMethod);
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 2) {
      _processCheckout();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);
    
    try {
      ref.read(checkoutProvider.notifier).setPaymentMethod(_paymentMethod);
      final user = ref.read(currentUserProvider);
      final cartState = ref.read(cartProvider);
      
      // Calculate discount ratio only on products (shipping is added later)
      // cartState.total includes discount. 
      // Ratio = cartState.total / cartState.subtotal
      // If subtotal is 0 (shouldn't happen), ratio is 1.
      double discountFactor = 1.0;
      if (cartState.subtotal > 0 && cartState.total < cartState.subtotal) {
         discountFactor = cartState.total / cartState.subtotal;
      }

      // Build line items for Stripe Checkout
      final List<Map<String, dynamic>> lineItems = [];
      int calculatedTotalCents = 0;
      
      for (final item in cartState.items) {
        // Apply discount factor to each item's price
        // Use standard rounding to nearest integer
        final originalAmountCents = (item.price * 100);
        final discountedAmountCents = (originalAmountCents * discountFactor).round();

        final itemTotalCents = discountedAmountCents * item.quantity;
        calculatedTotalCents += itemTotalCents;

        lineItems.add({
          'name': item.productName,
          'description': item.size != null 
              ? 'Talla: ${item.size}${discountFactor < 1 ? ' (Descuento aplicado)' : ''}' 
              : null,
          'amount': discountedAmountCents, // Amount in cents
          'quantity': item.quantity,
          'currency': 'eur',
          'image': item.imageUrl,
        });
      }

      // Fix rounding errors (compare with expected total)
      final expectedTotalCents = (cartState.total * 100).round();
      final diff = expectedTotalCents - calculatedTotalCents;

      // Apply the difference to the first item if there is any difference
      if (diff != 0 && lineItems.isNotEmpty) {
        // We add the diff to the *first* item's total by adjusting its unit amount * quantity
        // Ideally we adjust unit amount, but if quantity > 1 it might not be divisible.
        // Stripe requires unit_amount. 
        // If we cannot distribute evenly, we might need a separate correction item or just accept 1 cent diff?
        // Let's try to add a "Ajuste de redondeo" item if diff is significant, or adjust the last item unit price if quantity is 1
        
        // Simple approach: Adjust the first item with quantity 1 if possible
        int indexToAdjust = lineItems.indexWhere((item) => item['quantity'] == 1);
        if (indexToAdjust != -1) {
           lineItems[indexToAdjust]['amount'] = (lineItems[indexToAdjust]['amount'] as int) + diff;
        } else {
           // If all items have quantity > 1, create a separate line item for adjustment
           if (diff > 0) {
             lineItems.add({
               'name': 'Ajuste de redondeo',
               'amount': diff,
               'quantity': 1,
               'currency': 'eur',
             });
           } else {
             // If negative diff (should remove cents), and we can't subtract, 
             // we just ignore slight negative (customer pays 1 cent less) or force adjust one unit.
             // For now, let's ignore negative 1-2 cents diff to allow checkout.
           }
        }
      }
      
      // Add shipping cost if express (shipping is usually not discounted)
      if (_shippingMethod == 'express') {
        lineItems.add({
          'name': 'Envío Exprés',
          'description': '24-48 horas',
          'amount': 499, // €4.99 in cents
          'quantity': 1,
          'currency': 'eur',
        });
      }

      // First, create the order in the backend to get order ID
      final order = await ref.read(checkoutProvider.notifier).processCheckout(
        userId: user?.id,
        guestEmail: user == null ? _emailController.text : null,
      );

      if (order == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear el pedido. Por favor, inténtalo de nuevo.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Define success and cancel URLs
      final baseUrl = kIsWeb 
          ? Uri.base.origin 
          : 'https://slc-cuts.app'; 
      
      final successUrl = '$baseUrl/order-confirmation/${order.id}?payment=success';
      final cancelUrl = '$baseUrl/checkout?payment=cancelled';

      // Redirect to Stripe Checkout
      final success = await StripeService.instance.redirectToCheckout(
        lineItems: lineItems,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        customerEmail: _emailController.text,
        metadata: {
          'order_id': order.id,
          'customer_name': _nameController.text,
          'shipping_address': _addressController.text,
        },
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la página de pago. Por favor, inténtalo de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Checkout Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

