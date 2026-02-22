import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Checks if the current user is subscribed to the newsletter
final isSubscribedProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.email.isEmpty) return false;

  final supabase = Supabase.instance.client;
  
  try {
    final response = await supabase
        .from('newsletter_subscribers')
        .select('id')
        .eq('email', user.email)
        .maybeSingle();
        
    return response != null;
  } catch (e) {
    // If table doesn't exist or other error, assume not subscribed for safety
    // or log error.
    return false;
  }
});

/// Controller to handle subscription actions
class NewsletterController extends StateNotifier<AsyncValue<void>> {
  NewsletterController() : super(const AsyncValue.data(null));

  Future<bool> subscribeUser(String email) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      
      
      // Check if already exists first to avoid duplicates if constraints aren't set
      final existing = await supabase
          .from('newsletter_subscribers')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('newsletter_subscribers').insert({
          'email': email,
        });
      } else {
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final newsletterControllerProvider = StateNotifierProvider<NewsletterController, AsyncValue<void>>((ref) {
  return NewsletterController();
});
