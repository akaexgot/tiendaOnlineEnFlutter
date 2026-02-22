import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized API service for Astro backend endpoints
class AdminApiService {
  static const String baseUrl = 'https://slccuts.es';
  
  static final AdminApiService _instance = AdminApiService._internal();
  factory AdminApiService() => _instance;
  AdminApiService._internal();
  
  final _client = http.Client();
  
  /// Get current auth token for API requests
  String? get _authToken => Supabase.instance.client.auth.currentSession?.accessToken;
  
  /// Standard headers for JSON requests
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  // ============================================================
  // PRODUCTOS
  // ============================================================
  
  /// Create a new product
  Future<Map<String, dynamic>?> createProduct({
    required String name,
    required String slug,
    String? description,
    required int priceInCents,
    String? categoryId,
    bool active = true,
    bool isOffer = false,
    int? stock,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/products/create'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'slug': slug,
          'description': description,
          'price': priceInCents,
          'category_id': categoryId,
          'active': active,
          'is_offer': isOffer,
          'stock': stock,
          'image_url': imageUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true ? data['product'] : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Update existing product
  Future<bool> updateProduct({
    required String id,
    String? name,
    String? slug,
    String? description,
    int? priceInCents,
    String? categoryId,
    bool? active,
    bool? isOffer,
    int? stock,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{'id': id};
      if (name != null) body['name'] = name;
      if (slug != null) body['slug'] = slug;
      if (description != null) body['description'] = description;
      if (priceInCents != null) body['price'] = priceInCents;
      if (categoryId != null) body['category_id'] = categoryId;
      if (active != null) body['active'] = active;
      if (isOffer != null) body['is_offer'] = isOffer;
      if (stock != null) body['stock'] = stock;
      if (imageUrl != null) body['image_url'] = imageUrl;
      
      final response = await _client.post(
        Uri.parse('$baseUrl/api/products/update'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // CATEGORÍAS
  // ============================================================
  
  /// Create a new category
  Future<Map<String, dynamic>?> createCategory({
    required String name,
    required String slug,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/categories/create'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'slug': slug,
          'image_url': imageUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true ? data['category'] : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ============================================================
  // PEDIDOS
  // ============================================================
  
  /// Update order status (sends email automatically if shipped)
  Future<Map<String, dynamic>?> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/orders/update-status'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'orderId': orderId,
          'status': status,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true ? data['order'] : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ============================================================
  // EMAILS
  // ============================================================
  
  /// Send custom email
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String html,
    String? text,
    String? title,
    String? ctaLink,
    String? ctaText,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/emails/send'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': html,
          if (text != null) 'text': text,
          if (title != null) 'title': title,
          if (ctaLink != null) 'ctaLink': ctaLink,
          if (ctaText != null) 'ctaText': ctaText,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // NEWSLETTER
  // ============================================================
  
  /// Send newsletter campaign to all subscribers
  Future<bool> sendNewsletterCampaign({
    required String subject,
    required String content,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/newsletter/send-campaign'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'subject': subject,
          'content': content,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // ============================================================
  // ANALYTICS
  // ============================================================
  
  /// Track page visit
  Future<bool> trackPageVisit(String path) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/analytics/track'),
        headers: _jsonHeaders,
        body: jsonEncode({'path': path}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    _client.close();
  }
}
