// lib/core/constants/app_constants.dart (مبسط)

/// ثوابت التطبيق الأساسية - فقط ما هو مستخدم فعلياً
class AppConstants {
  AppConstants._();
  
  // ===== معلومات التطبيق =====
  static const String appName = 'تطبيق الأذكار';
  static const String appVersion = '1.0.0';
  
  // ===== اللغة الافتراضية =====
  static const String defaultLanguage = 'ar';
  
  // ===== مفاتيح التخزين المستخدمة فعلياً =====
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // ===== إعدادات افتراضية مستخدمة =====
  static const int defaultPageSize = 20;
  static const int maxRecentItems = 10;
  
  // ===== ميزات التطبيق (للتحكم في التفعيل) =====
  static const bool enablePrayerTimes = true;
  static const bool enableQibla = true;
  static const bool enableTasbih = true;
  static const bool enableDua = true;
  static const bool enableAthkar = true;
}