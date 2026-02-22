/// Gallery image model (maps to gallery_images table)
class GalleryImageModel {
  final String id;
  final String imageUrl;
  final String? description;
  final String? altText;
  final DateTime createdAt;

  GalleryImageModel({
    required this.id,
    required this.imageUrl,
    this.description,
    this.altText,
    required this.createdAt,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String? ?? json['url'] as String? ?? '',
      description: json['description'] as String?,
      altText: json['alt_text'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    'description': description,
    'alt_text': altText,
    'created_at': createdAt.toIso8601String(),
  };
}
