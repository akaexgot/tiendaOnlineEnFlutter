/// News/Blog post model (maps to news table)
class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? slug;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.slug,
    this.isPublished = false,
    required this.createdAt,
    this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      slug: json['slug'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      publishedAt: json['published_at'] != null 
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'slug': slug,
    'is_published': isPublished,
  };

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? slug,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? publishedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      slug: slug ?? this.slug,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
