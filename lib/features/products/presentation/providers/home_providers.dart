
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../admin/data/models/news_model.dart';
import '../../../admin/data/models/gallery_image_model.dart';

/// Provider for latest published news
final latestNewsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Fetch only published news, ordered by creation date desc, limit 5
  final response = await supabase
      .from('news')
      .select()
      .eq('is_published', true)
      .order('created_at', ascending: false)
      .limit(5);

  return (response as List).map((e) => NewsModel.fromJson(e)).toList();
});

/// Provider for all published news (full list)
final fullNewsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('news')
      .select()
      .eq('is_published', true)
      .order('created_at', ascending: false);

  return (response as List).map((e) => NewsModel.fromJson(e)).toList();
});

/// Provider for gallery preview images
final galleryPreviewProvider = FutureProvider<List<GalleryImageModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Fetch latest 6 images for preview
  final response = await supabase
      .from('gallery_images')
      .select()
      .limit(6);

  return (response as List).map((e) => GalleryImageModel.fromJson(e)).toList();
});

/// Provider for full gallery images
final fullGalleryProvider = FutureProvider<List<GalleryImageModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('gallery_images')
      .select();

  return (response as List).map((e) => GalleryImageModel.fromJson(e)).toList();
});
