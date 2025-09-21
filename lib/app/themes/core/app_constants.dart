// lib/app/constants/app_constants.dart
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
}