/// Newsletter subscriber model
class NewsletterSubscriberModel {
  final String id;
  final String email;
  final DateTime subscribedAt;

  NewsletterSubscriberModel({
    required this.id,
    required this.email,
    required this.subscribedAt,
  });

  factory NewsletterSubscriberModel.fromJson(Map<String, dynamic> json) {
    return NewsletterSubscriberModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      subscribedAt: json['subscribed_at'] != null 
          ? DateTime.parse(json['subscribed_at'] as String)
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
    );
  }
}
