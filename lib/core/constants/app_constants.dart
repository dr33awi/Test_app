// lib/core/constants/app_constants.dart - كامل ومحدث
import 'package:flutter/material.dart';

/// الثوابت المشتركة في جميع أنحاء التطبيق
class AppConstants {
  AppConstants._();

  // ===== الخطوط =====
  static const String fontFamilyArabic = 'Cairo';
  static const String fontFamilyQuran = 'Amiri';
  static const String fontFamily = fontFamilyArabic;

  // ===== أوزان الخطوط =====
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ===== أحجام النصوص =====
  static const double textSizeXs = 11.0;
  static const double textSizeSm = 12.0;
  static const double textSizeMd = 14.0;
  static const double textSizeLg = 16.0;
  static const double textSizeXl = 18.0;
  static const double textSize2xl = 20.0;
  static const double textSize3xl = 24.0;
  static const double textSize4xl = 28.0;
  static const double textSize5xl = 32.0;

  // ===== المسافات =====
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // ===== نصف القطر =====
  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 28.0;
  static const double radiusFull = 999.0;

  // ===== الحدود =====
  static const double borderNone = 0.0;
  static const double borderThin = 0.5;
  static const double borderLight = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;
  static const double borderHeavy = 3.0;

  // ===== أحجام الأيقونات =====
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double icon2xl = 48.0;
  static const double icon3xl = 56.0;

  // ===== الارتفاعات =====
  static const double heightXs = 32.0;
  static const double heightSm = 36.0;
  static const double heightMd = 40.0;
  static const double heightLg = 48.0;
  static const double heightXl = 56.0;
  static const double height2xl = 64.0;
  static const double height3xl = 72.0;

  // ===== مكونات خاصة =====
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 64.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double fabSize = 56.0;
  static const double fabSizeMini = 40.0;

  // ===== الظلال =====
  static const double elevationNone = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;

  // ===== الشفافية =====
  static const double opacity5 = 0.05;
  static const double opacity05 = 0.05; // اسم بديل
  static const double opacity10 = 0.10;
  static const double opacity20 = 0.20;
  static const double opacity30 = 0.30;
  static const double opacity40 = 0.40;
  static const double opacity50 = 0.50;
  static const double opacity60 = 0.60;
  static const double opacity70 = 0.70;
  static const double opacity80 = 0.80;
  static const double opacity90 = 0.90;

  // ===== مدد الحركات =====
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationVerySlow = Duration(milliseconds: 600);
  static const Duration durationExtraSlow = Duration(milliseconds: 1000);

  // ===== منحنيات الحركة =====
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveSharp = Curves.easeInOutCubic;
  static const Curve curveSmooth = Curves.easeInOutQuint;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveOvershoot = Curves.easeOutBack;
  static const Curve curveAnticipate = Curves.easeInBack;

  // ===== نقاط التوقف للتصميم المتجاوب =====
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;
  static const double breakpointWide = 1920.0;

  // ===== الأيقونات المشتركة =====
  static const IconData iconPrayer = Icons.mosque;
  static const IconData iconPrayerTime = Icons.access_time;
  static const IconData iconQibla = Icons.explore;
  static const IconData iconAdhan = Icons.volume_up;
  static const IconData iconAthkar = Icons.menu_book;
  static const IconData iconMorningAthkar = Icons.wb_sunny;
  static const IconData iconEveningAthkar = Icons.nights_stay;
  static const IconData iconSleepAthkar = Icons.bedtime;
  static const IconData iconFavorite = Icons.favorite;
  static const IconData iconFavoriteOutline = Icons.favorite_border;
  static const IconData iconShare = Icons.share;
  static const IconData iconCopy = Icons.content_copy;
  static const IconData iconSettings = Icons.settings;
  static const IconData iconNotifications = Icons.notifications;

  // ===== ثوابت التطبيق =====
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int defaultMinBatteryLevel = 15;
  static const int criticalBatteryLevel = 5;

  // ===== معلومات التطبيق =====
  static const String appName = 'حصن المسلم';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@yourapp.com';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourapp.athkar';

  // ===== الثوابت المفقودة التي يحتاجها التطبيق =====
  
  // اللغات
  static const String defaultLanguage = 'ar';
  static const String arabicLanguage = 'ar';
  static const String englishLanguage = 'en';
  
  // مسارات ملفات البيانات
  static const String athkarDataFile = 'assets/data/athkar.json';
  static const String asmaAllahDataFile = 'assets/data/asma_allah.json';
  static const String duaDataFile = 'assets/data/dua.json';
  static const String prayerTimesDataFile = 'assets/data/prayer_times.json';
  
  // مفاتيح التخزين المحلي
  static const String tasbihCounterKey = 'tasbih_counter';
  static const String athkarProgressKey = 'athkar_progress';
  static const String favoritesKey = 'favorites';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String locationKey = 'user_location';
  static const String prayerNotificationsKey = 'prayer_notifications';
  static const String athkarNotificationsKey = 'athkar_notifications';
  static const String lastUpdateKey = 'last_update';
  static const String userPreferencesKey = 'user_preferences';
  static const String completedAthkarKey = 'completed_athkar';
  static const String dailyProgressKey = 'daily_progress';
  
  // حدود وقيود
  static const int maxFavorites = 100;
  static const int maxRecentItems = 20;
  static const int maxHistoryItems = 50;
  static const int defaultTasbihTarget = 33;
  static const int maxTasbihCount = 9999;
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 20;
  
  // URLs وروابط
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportUrl = 'https://yourapp.com/support';
  static const String donationUrl = 'https://yourapp.com/donate';
  static const String feedbackUrl = 'https://yourapp.com/feedback';
  static const String rateAppUrl = 'https://play.google.com/store/apps/details?id=com.yourapp.athkar';
  
  // إعدادات الإشعارات
  static const String morningNotificationChannel = 'morning_athkar';
  static const String eveningNotificationChannel = 'evening_athkar';
  static const String prayerNotificationChannel = 'prayer_times';
  static const String generalNotificationChannel = 'general';
  
  // أوقات افتراضية للإشعارات
  static const String defaultMorningNotificationTime = '07:00';
  static const String defaultEveningNotificationTime = '18:00';
  
  // فئات الأذكار
  static const String morningAthkarCategory = 'morning';
  static const String eveningAthkarCategory = 'evening';
  static const String sleepAthkarCategory = 'sleep';
  static const String prayerAthkarCategory = 'prayer';
  static const String generalAthkarCategory = 'general';
  
  // أسماء الصلوات
  static const String fajrPrayer = 'fajr';
  static const String dhuhrPrayer = 'dhuhr';
  static const String asrPrayer = 'asr';
  static const String maghribPrayer = 'maghrib';
  static const String ishaPrayer = 'isha';
  static const String sunrisePrayer = 'sunrise';
  
  // طرق حساب أوقات الصلاة
  static const String calculationMethodMWL = 'MWL'; // Muslim World League
  static const String calculationMethodISNA = 'ISNA'; // Islamic Society of North America
  static const String calculationMethodEgypt = 'Egypt'; // Egyptian General Authority
  static const String calculationMethodMakkah = 'Makkah'; // Umm Al-Qura University
  static const String calculationMethodKarachi = 'Karachi'; // University of Islamic Sciences, Karachi
  static const String calculationMethodTehran = 'Tehran'; // Institute of Geophysics, University of Tehran
  
  // المذاهب الفقهية
  static const String madhhabHanafi = 'Hanafi';
  static const String madhhabShafi = 'Shafi';
  static const String madhhabMaliki = 'Maliki';
  static const String madhhabHanbali = 'Hanbali';
  
  // إعدادات افتراضية
  static const String defaultCalculationMethod = calculationMethodMWL;
  static const String defaultMadhhab = madhhabShafi;
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultVibrationEnabled = true;
  static const bool defaultSoundEnabled = true;
  static const double defaultFontSize = 16.0;
  static const bool defaultDarkModeEnabled = false;
  
  // أصوات الإشعارات
  static const String defaultAdhanSound = 'adhan_makkah.mp3';
  static const String defaultNotificationSound = 'notification.mp3';
  static const String defaultTasbihSound = 'click.mp3';
  
  // مجلدات الأصول
  static const String assetsPath = 'assets';
  static const String imagesPath = 'assets/images';
  static const String soundsPath = 'assets/sounds';
  static const String dataPath = 'assets/data';
  static const String fontsPath = 'assets/fonts';
  
  // أحجام الخط للقرآن والأذكار
  static const double quranFontSizeSmall = 18.0;
  static const double quranFontSizeMedium = 22.0;
  static const double quranFontSizeLarge = 26.0;
  static const double quranFontSizeExtraLarge = 30.0;
  
  static const double athkarFontSizeSmall = 16.0;
  static const double athkarFontSizeMedium = 18.0;
  static const double athkarFontSizeLarge = 20.0;
  static const double athkarFontSizeExtraLarge = 24.0;
  
  // مسافات السطور
  static const double quranLineHeightSmall = 1.5;
  static const double quranLineHeightMedium = 1.8;
  static const double quranLineHeightLarge = 2.0;
  
  static const double athkarLineHeightSmall = 1.4;
  static const double athkarLineHeightMedium = 1.6;
  static const double athkarLineHeightLarge = 1.8;
  
  // قواعد البيانات المحلية
  static const String databaseName = 'athkar_app.db';
  static const int databaseVersion = 1;
  
  // جداول قاعدة البيانات
  static const String favoritesTable = 'favorites';
  static const String historyTable = 'history';
  static const String progressTable = 'progress';
  static const String settingsTable = 'settings';
  
  // API endpoints (إذا كان التطبيق يستخدم API)
  static const String baseApiUrl = 'https://api.yourapp.com';
  static const String prayerTimesApiUrl = '$baseApiUrl/prayer-times';
  static const String athkarApiUrl = '$baseApiUrl/athkar';
  static const String updateApiUrl = '$baseApiUrl/updates';
  
  // معلومات المطور
  static const String developerName = 'Your Name';
  static const String developerEmail = 'developer@yourapp.com';
  static const String companyName = 'Your Company';
  static const String companyWebsite = 'https://yourcompany.com';
  
  // روابط التواصل الاجتماعي
  static const String facebookUrl = 'https://facebook.com/yourapp';
  static const String twitterUrl = 'https://twitter.com/yourapp';
  static const String instagramUrl = 'https://instagram.com/yourapp';
  static const String youtubeUrl = 'https://youtube.com/yourapp';
  
  // معرفات التطبيق
  static const String packageNameAndroid = 'com.yourapp.athkar';
  static const String bundleIdIOS = 'com.yourapp.athkar';
  static const String appStoreId = '123456789';
  
  // AdMob IDs (إذا كان التطبيق يستخدم إعلانات)
  static const String admobAppIdAndroid = 'ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx';
  static const String admobAppIdIOS = 'ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx';
  static const String admobBannerIdAndroid = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
  static const String admobBannerIdIOS = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'athkar-app-xxxxx';
  static const String firebaseStorageBucket = 'athkar-app-xxxxx.appspot.com';
  
  // معلومات الترخيص
  static const String licenseType = 'MIT License';
  static const String copyrightYear = '2024';
  static const String copyrightHolder = 'Your Name';
}