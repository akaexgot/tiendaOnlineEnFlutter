import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/gallery_image_model.dart';
import '../../data/models/news_model.dart';
import '../../data/models/popup_model.dart';
import '../../data/models/newsletter_subscriber_model.dart';
import '../../data/models/site_settings_model.dart';


final _supabase = Supabase.instance.client;

// ============================================================
// GALLERY
// ============================================================

final galleryImagesProvider = FutureProvider<List<GalleryImageModel>>((ref) async {
  final response = await _supabase
      .from('gallery_images')
      .select()
      .order('created_at', ascending: false);
  
  return (response as List)
      .map((e) => GalleryImageModel.fromJson(e))
      .toList();
});

// ============================================================
// NEWS
// ============================================================

final newsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final response = await _supabase
      .from('news')
      .select()
      .order('created_at', ascending: false);
  
  return (response as List)
      .map((e) => NewsModel.fromJson(e))
      .toList();
});

final publishedNewsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final response = await _supabase
      .from('news')
      .select()
      .eq('is_published', true)
      .order('published_at', ascending: false);
  
  return (response as List)
      .map((e) => NewsModel.fromJson(e))
      .toList();
});

// ============================================================
// POPUPS
// ============================================================

final popupsProvider = FutureProvider<List<PopupModel>>((ref) async {
  final response = await _supabase
      .from('popups')
      .select()
      .order('created_at', ascending: false);
  
  return (response as List)
      .map((e) => PopupModel.fromJson(e))
      .toList();
});

final activePopupProvider = FutureProvider<PopupModel?>((ref) async {
  final response = await _supabase
      .from('popups')
      .select()
      .eq('is_active', true)
      .maybeSingle();
  
  return response != null ? PopupModel.fromJson(response) : null;
});

// ============================================================
// NEWSLETTER
// ============================================================

final newsletterSubscribersProvider = FutureProvider<List<NewsletterSubscriberModel>>((ref) async {
  final response = await _supabase
      .from('newsletter_subscribers')
      .select()
      .order('created_at', ascending: false);
  
  return (response as List)
      .map((e) => NewsletterSubscriberModel.fromJson(e))
      .toList();
});

final subscribersCountProvider = FutureProvider<int>((ref) async {
  final response = await _supabase
      .from('newsletter_subscribers')
      .select('id')
      .count();
  
  return response.count;
});

// ============================================================
// SITE SETTINGS
// ============================================================

final siteSettingsProvider = FutureProvider<SiteSettingsModel>((ref) async {
  final response = await _supabase
      .from('settings')
      .select()
      .eq('id', 1)
      .maybeSingle();
  
  return response != null 
      ? SiteSettingsModel.fromJson(response)
      : SiteSettingsModel();
});

// ============================================================
// ANALYTICS / STATS
// ============================================================

final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final products = await _supabase.from('products').select('id').count();
  final orders = await _supabase.from('orders').select('id').count();
  final gallery = await _supabase.from('gallery_images').select('id').count();
  final news = await _supabase.from('news').select('id').count();
  final subscribers = await _supabase.from('newsletter_subscribers').select('id').count();
  
  return {
    'products': products.count,
    'orders': orders.count,
    'gallery': gallery.count,
    'news': news.count,
    'subscribers': subscribers.count,
  };
});

final recentVisitsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
  
  final response = await _supabase
      .from('page_visits')
      .select('path, created_at')
      .gte('created_at', sevenDaysAgo)
      .order('created_at', ascending: false)
      .limit(100);
  
  return List<Map<String, dynamic>>.from(response);
});

// ============================================================
// INVOICES (from orders)
// ============================================================

final paidOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await _supabase
      .from('orders')
      .select('*, order_items(*)')
      .inFilter('status', ['paid', 'shipped', 'delivered'])
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
});

final invoiceStatsProvider = FutureProvider.family<Map<String, double>, AdminDateRange?>((ref, dateRange) async {
  var query = _supabase
      .from('orders')
      .select('total_price, payment_method')
      .inFilter('status', ['paid', 'shipped', 'delivered']);
  
  if (dateRange != null) {
    query = query
        .gte('created_at', dateRange.start.toIso8601String())
        .lte('created_at', dateRange.end.toIso8601String());
  }
  
  final response = await query;
  
  double total = 0;
  double online = 0;
  double local = 0;
  
  for (final order in response) {
    final price = ((order['total_price'] as num?) ?? 0) / 100;
    total += price;
    
    if (order['payment_method'] == 'card' || order['payment_method'] == 'stripe') {
      online += price;
    } else {
      local += price;
    }
  }
  
  return {
    'total': total,
    'online': online,
    'local': local,
  };
});

/// Helper class for date range (named AdminDateRange to avoid conflict with Flutter's DateTimeRange)
class AdminDateRange {
  final DateTime start;
  final DateTime end;
  
  AdminDateRange({required this.start, required this.end});
}
