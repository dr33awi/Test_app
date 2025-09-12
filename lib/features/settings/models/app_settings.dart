// lib/features/settings/models/app_settings.dart (منظف)

/// نموذج إعدادات التطبيق المبسط
/// يحتوي فقط على الإعدادات التي لا تتعلق بالأذونات
class AppSettings {
  // إعدادات المظهر
  final bool isDarkMode;
  
  // إعدادات الإشعارات
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final bool prayerNotificationsEnabled;
  final bool athkarNotificationsEnabled;
  
  // إعدادات أخرى يمكن إضافتها هنا
  final String language;
  final double fontSize;
  final bool soundEnabled;

  const AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = false,
    this.vibrationEnabled = true,
    this.prayerNotificationsEnabled = true,
    this.athkarNotificationsEnabled = true,
    this.language = 'ar',
    this.fontSize = 1.0,
    this.soundEnabled = true,
  });

  /// إنشاء نسخة جديدة مع تغيير بعض القيم
  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    bool? prayerNotificationsEnabled,
    bool? athkarNotificationsEnabled,
    String? language,
    double? fontSize,
    bool? soundEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      prayerNotificationsEnabled: prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      athkarNotificationsEnabled: athkarNotificationsEnabled ?? this.athkarNotificationsEnabled,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'vibrationEnabled': vibrationEnabled,
      'prayerNotificationsEnabled': prayerNotificationsEnabled,
      'athkarNotificationsEnabled': athkarNotificationsEnabled,
      'language': language,
      'fontSize': fontSize,
      'soundEnabled': soundEnabled,
    };
  }

  /// إنشاء من JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      prayerNotificationsEnabled: json['prayerNotificationsEnabled'] ?? true,
      athkarNotificationsEnabled: json['athkarNotificationsEnabled'] ?? true,
      language: json['language'] ?? 'ar',
      fontSize: (json['fontSize'] ?? 1.0).toDouble(),
      soundEnabled: json['soundEnabled'] ?? true,
    );
  }
}