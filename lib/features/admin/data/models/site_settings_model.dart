/// Site settings model (maps to settings table)
class SiteSettingsModel {
  final int id;
  final bool newsEnabled;
  final bool promosEnabled;
  final bool galleryEnabled;
  final bool popupsEnabled;
  final bool newsletterEnabled;
  final bool maintenanceMode;

  SiteSettingsModel({
    this.id = 1,
    this.newsEnabled = true,
    this.promosEnabled = true,
    this.galleryEnabled = true,
    this.popupsEnabled = true,
    this.newsletterEnabled = true,
    this.maintenanceMode = false,
  });

  factory SiteSettingsModel.fromJson(Map<String, dynamic> json) {
    return SiteSettingsModel(
      id: json['id'] as int? ?? 1,
      newsEnabled: json['news_enabled'] as bool? ?? true,
      promosEnabled: json['promos_enabled'] as bool? ?? true,
      galleryEnabled: json['gallery_enabled'] as bool? ?? true,
      popupsEnabled: json['popups_enabled'] as bool? ?? true,
      newsletterEnabled: json['newsletter_enabled'] as bool? ?? true,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'news_enabled': newsEnabled,
    'promos_enabled': promosEnabled,
    'gallery_enabled': galleryEnabled,
    'popups_enabled': popupsEnabled,
    'newsletter_enabled': newsletterEnabled,
    'maintenance_mode': maintenanceMode,
  };

  SiteSettingsModel copyWith({
    bool? newsEnabled,
    bool? promosEnabled,
    bool? galleryEnabled,
    bool? popupsEnabled,
    bool? newsletterEnabled,
    bool? maintenanceMode,
  }) {
    return SiteSettingsModel(
      id: id,
      newsEnabled: newsEnabled ?? this.newsEnabled,
      promosEnabled: promosEnabled ?? this.promosEnabled,
      galleryEnabled: galleryEnabled ?? this.galleryEnabled,
      popupsEnabled: popupsEnabled ?? this.popupsEnabled,
      newsletterEnabled: newsletterEnabled ?? this.newsletterEnabled,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }
}
