import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants/app_constants.dart';

/// Stripe Checkout Session response model
class CheckoutSessionResult {
  final String sessionId;
  final String checkoutUrl;

  CheckoutSessionResult({
    required this.sessionId,
    required this.checkoutUrl,
  });
}

class StripeService {
  static final StripeService instance = StripeService._();
  StripeService._();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    // Don't initialize Stripe on web to avoid Platform._operatingSystem errors
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    _isInitialized = true;
  }

  /// Creates a Stripe Checkout Session and returns the checkout URL
  /// This redirects customers to Stripe's hosted payment page
  Future<CheckoutSessionResult> createCheckoutSession({
    required List<Map<String, dynamic>> lineItems,
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
    Map<String, String>? metadata,
  }) async {
    try {
      // Build the request body for Checkout Session creation
      final Map<String, String> body = {
        'mode': 'payment',
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      };

      // Add customer email if provided
      if (customerEmail != null && customerEmail.isNotEmpty) {
        body['customer_email'] = customerEmail;
      }

      // Add line items
      for (int i = 0; i < lineItems.length; i++) {
        final item = lineItems[i];
        body['line_items[$i][price_data][currency]'] = item['currency'] ?? 'eur';
        body['line_items[$i][price_data][unit_amount]'] = item['amount'].toString();
        body['line_items[$i][price_data][product_data][name]'] = item['name'];
        if (item['description'] != null) {
          body['line_items[$i][price_data][product_data][description]'] = item['description'];
        }
        if (item['image'] != null) {
          body['line_items[$i][price_data][product_data][images][0]'] = item['image'];
        }
        body['line_items[$i][quantity]'] = item['quantity'].toString();
      }

      // Add metadata if provided
      if (metadata != null) {
        metadata.forEach((key, value) {
          body['metadata[$key]'] = value;
        });
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(decoded['error']?['message'] ?? 'Error creating checkout session');
      }

      return CheckoutSessionResult(
        sessionId: decoded['id'],
        checkoutUrl: decoded['url'],
      );
    } catch (e) {
      throw Exception('Error creating checkout session: $e');
    }
  }

  /// Opens Stripe Checkout in the browser
  /// Returns true if the URL was launched successfully
  Future<bool> redirectToCheckout({
    required List<Map<String, dynamic>> lineItems,
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
    Map<String, String>? metadata,
  }) async {
    try {
      final session = await createCheckoutSession(
        lineItems: lineItems,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        customerEmail: customerEmail,
        metadata: metadata,
      );

      final uri = Uri.parse(session.checkoutUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Retrieves a Checkout Session to verify payment status
  Future<Map<String, dynamic>> retrieveCheckoutSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/checkout/sessions/$sessionId'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error retrieving session');
    } catch (e) {
      throw Exception('Error retrieving checkout session: $e');
    }
  }

  /// Verifies if a checkout session payment was completed
  Future<bool> verifyCheckoutPayment(String sessionId) async {
    try {
      final session = await retrieveCheckoutSession(sessionId);
      final paymentStatus = session['payment_status'];
      return paymentStatus == 'paid';
    } catch (e) {
      return false;
    }
  }

  // Keep mobile payment sheet for native apps
  Future<bool> processPayment({
    required double amount,
    String currency = 'eur',
    BuildContext? context,
  }) async {
    try {
      // 1. Create payment intent
      final paymentIntent = await createPaymentIntent(amount, currency);
      final clientSecret = paymentIntent['client_secret'];

      if (kIsWeb) {
        // On web, this should not be called - use redirectToCheckout instead
        return false;
      } else {
        // Mobile flow: Payment Sheet
        await _initMobilePaymentSheet(clientSecret);
        await Stripe.instance.presentPaymentSheet();
        return true;
      }
    } catch (e) {
      if (e is StripeException) {
      } else {
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    try {
      final Map<String, dynamic> body = {
        'amount': (amount * 100).toInt().toString(),
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(decoded['error']?['message'] ?? 'Error creating payment intent');
      }
      return decoded;
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  /// Mobile-only helper to avoid calling initPaymentSheet on Web
  Future<void> _initMobilePaymentSheet(String clientSecret) async {
    if (kIsWeb) return;
    
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'SLC CUTS',
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }
}
