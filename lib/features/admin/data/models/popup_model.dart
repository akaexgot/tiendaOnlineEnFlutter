/// Popup model (maps to popups table)
class PopupModel {
  final String id;
  final String title;
  final String? content;
  final String? imageUrl;
  final String? buttonText;
  final String? buttonUrl;
  final bool isActive;
  final DateTime createdAt;

  PopupModel({
    required this.id,
    required this.title,
    this.content,
    this.imageUrl,
    this.buttonText,
    this.buttonUrl,
    this.isActive = false,
    required this.createdAt,
  });

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      buttonText: json['button_text'] as String?,
      buttonUrl: json['button_link'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'button_text': buttonText,
    'button_link': buttonUrl,
    'is_active': isActive,
  };
}
