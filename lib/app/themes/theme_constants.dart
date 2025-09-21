// lib/app/themes/theme_constants.dart - محدث مع الثوابت المفقودة
import 'package:flutter/material.dart';
import 'core/color_helper.dart';
import 'constants/app_constants.dart';

/// ثوابت الثيم - استخدام AppColors و AppConstants
class ThemeConstants {
  ThemeConstants._();

  // ===== استخدام الألوان من AppColors =====
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primarySoft = AppColors.primarySoft;

  static const Color accent = AppColors.accent;
  static const Color accentLight = AppColors.accentLight;
  static const Color accentDark = AppColors.accentDark;
  
  static const Color tertiary = AppColors.tertiary;
  static const Color tertiaryLight = AppColors.tertiaryLight;
  static const Color tertiaryDark = AppColors.tertiaryDark;

  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color warning = AppColors.warning;
  static const Color info = AppColors.info;

  // ===== ألوان الوضع الفاتح =====
  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightCard = AppColors.lightCard;
  static const Color lightDivider = AppColors.lightDivider;
  static const Color lightTextPrimary = AppColors.lightTextPrimary;
  static const Color lightTextSecondary = AppColors.lightTextSecondary;
  static const Color lightTextHint = AppColors.lightTextHint;

  // ===== ألوان الوضع الداكن =====
  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkCard = AppColors.darkCard;
  static const Color darkDivider = AppColors.darkDivider;
  static const Color darkTextPrimary = AppColors.darkTextPrimary;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  static const Color darkTextHint = AppColors.darkTextHint;

  // ===== استخدام الثوابت من AppConstants =====
  static const String fontFamily = AppConstants.fontFamily;
  static const String fontFamilyArabic = AppConstants.fontFamilyArabic;
  static const String fontFamilyQuran = AppConstants.fontFamilyQuran;

  static const FontWeight light = AppConstants.light;
  static const FontWeight regular = AppConstants.regular;
  static const FontWeight medium = AppConstants.medium;
  static const FontWeight semiBold = AppConstants.semiBold;
  static const FontWeight bold = AppConstants.bold;

  static const double textSizeXs = AppConstants.textSizeXs;
  static const double textSizeSm = AppConstants.textSizeSm;
  static const double textSizeMd = AppConstants.textSizeMd;
  static const double textSizeLg = AppConstants.textSizeLg;
  static const double textSizeXl = AppConstants.textSizeXl;
  static const double textSize2xl = AppConstants.textSize2xl;
  static const double textSize3xl = AppConstants.textSize3xl;
  static const double textSize4xl = AppConstants.textSize4xl;
  static const double textSize5xl = AppConstants.textSize5xl;

  static const double space0 = AppConstants.space0;
  static const double space1 = AppConstants.space1;
  static const double space2 = AppConstants.space2;
  static const double space3 = AppConstants.space3;
  static const double space4 = AppConstants.space4;
  static const double space5 = AppConstants.space5;
  static const double space6 = AppConstants.space6;
  static const double space8 = AppConstants.space8;
  static const double space10 = AppConstants.space10;
  static const double space12 = AppConstants.space12;
  static const double space16 = AppConstants.space16;

  static const double radiusNone = AppConstants.radiusNone;
  static const double radiusXs = AppConstants.radiusXs;
  static const double radiusSm = AppConstants.radiusSm;
  static const double radiusMd = AppConstants.radiusMd;
  static const double radiusLg = AppConstants.radiusLg;
  static const double radiusXl = AppConstants.radiusXl;
  static const double radius2xl = AppConstants.radius2xl;
  static const double radius3xl = AppConstants.radius3xl;
  static const double radiusFull = AppConstants.radiusFull;

  static const double borderNone = AppConstants.borderNone;
  static const double borderThin = AppConstants.borderThin;
  static const double borderLight = AppConstants.borderLight;
  static const double borderMedium = AppConstants.borderMedium;
  static const double borderThick = AppConstants.borderThick;
  static const double borderHeavy = AppConstants.borderHeavy;

  static const double iconXs = AppConstants.iconXs;
  static const double iconSm = AppConstants.iconSm;
  static const double iconMd = AppConstants.iconMd;
  static const double iconLg = AppConstants.iconLg;
  static const double iconXl = AppConstants.iconXl;
  static const double icon2xl = AppConstants.icon2xl;
  static const double icon3xl = AppConstants.icon3xl;

  static const double heightXs = AppConstants.heightXs;
  static const double heightSm = AppConstants.heightSm;
  static const double heightMd = AppConstants.heightMd;
  static const double heightLg = AppConstants.heightLg;
  static const double heightXl = AppConstants.heightXl;
  static const double height2xl = AppConstants.height2xl;
  static const double height3xl = AppConstants.height3xl;

  static const double appBarHeight = AppConstants.appBarHeight;
  static const double bottomNavHeight = AppConstants.bottomNavHeight;
  static const double buttonHeight = AppConstants.buttonHeight;
  static const double inputHeight = AppConstants.inputHeight;
  static const double fabSize = AppConstants.fabSize;
  static const double fabSizeMini = AppConstants.fabSizeMini;

  static const double elevationNone = AppConstants.elevationNone;
  static const double elevation1 = AppConstants.elevation1;
  static const double elevation2 = AppConstants.elevation2;
  static const double elevation4 = AppConstants.elevation4;
  static const double elevation6 = AppConstants.elevation6;
  static const double elevation8 = AppConstants.elevation8;
  static const double elevation12 = AppConstants.elevation12;
  static const double elevation16 = AppConstants.elevation16;

  static const double opacity5 = AppConstants.opacity5;
  static const double opacity05 = AppConstants.opacity05; // المفقود
  static const double opacity10 = AppConstants.opacity10;
  static const double opacity20 = AppConstants.opacity20;
  static const double opacity30 = AppConstants.opacity30;
  static const double opacity40 = AppConstants.opacity40;
  static const double opacity50 = AppConstants.opacity50;
  static const double opacity60 = AppConstants.opacity60;
  static const double opacity70 = AppConstants.opacity70;
  static const double opacity80 = AppConstants.opacity80;
  static const double opacity90 = AppConstants.opacity90;

  static const Duration durationInstant = AppConstants.durationInstant;
  static const Duration durationFast = AppConstants.durationFast;
  static const Duration durationNormal = AppConstants.durationNormal;
  static const Duration durationSlow = AppConstants.durationSlow;
  static const Duration durationVerySlow = AppConstants.durationVerySlow;
  static const Duration durationExtraSlow = AppConstants.durationExtraSlow;

  static const Curve curveDefault = AppConstants.curveDefault;
  static const Curve curveSharp = AppConstants.curveSharp;
  static const Curve curveSmooth = AppConstants.curveSmooth;
  static const Curve curveBounce = AppConstants.curveBounce;
  static const Curve curveOvershoot = AppConstants.curveOvershoot;
  static const Curve curveAnticipate = AppConstants.curveAnticipate;

  static const double breakpointMobile = AppConstants.breakpointMobile;
  static const double breakpointTablet = AppConstants.breakpointTablet;
  static const double breakpointDesktop = AppConstants.breakpointDesktop;
  static const double breakpointWide = AppConstants.breakpointWide;

  static const IconData iconPrayer = AppConstants.iconPrayer;
  static const IconData iconPrayerTime = AppConstants.iconPrayerTime;
  static const IconData iconQibla = AppConstants.iconQibla;
  static const IconData iconAdhan = AppConstants.iconAdhan;
  static const IconData iconAthkar = AppConstants.iconAthkar;
  static const IconData iconMorningAthkar = AppConstants.iconMorningAthkar;
  static const IconData iconEveningAthkar = AppConstants.iconEveningAthkar;
  static const IconData iconSleepAthkar = AppConstants.iconSleepAthkar;
  static const IconData iconFavorite = AppConstants.iconFavorite;
  static const IconData iconFavoriteOutline = AppConstants.iconFavoriteOutline;
  static const IconData iconShare = AppConstants.iconShare;
  static const IconData iconCopy = AppConstants.iconCopy;
  static const IconData iconSettings = AppConstants.iconSettings;
  static const IconData iconNotifications = AppConstants.iconNotifications;

  static const Duration defaultCacheDuration = AppConstants.defaultCacheDuration;
  static const Duration splashDuration = AppConstants.splashDuration;
  static const Duration debounceDelay = AppConstants.debounceDelay;
  static const int defaultMinBatteryLevel = AppConstants.defaultMinBatteryLevel;
  static const int criticalBatteryLevel = AppConstants.criticalBatteryLevel;

  // ===== التدرجات اللونية =====
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient accentGradient = AppColors.accentGradient;
  static const LinearGradient tertiaryGradient = AppColors.tertiaryGradient;

  // ===== الظلال الجاهزة =====
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: primary.withValues(alpha: opacity5),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: primary.withValues(alpha: opacity10),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: primary.withValues(alpha: opacity10),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: primary.withValues(alpha: opacity20),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // ===== دوال مساعدة موحدة =====
  static Color background(BuildContext context) => AppColors.getBackground(
    Theme.of(context).brightness == Brightness.dark
  );

  static Color surface(BuildContext context) => AppColors.getSurface(
    Theme.of(context).brightness == Brightness.dark
  );

  static Color card(BuildContext context) => AppColors.getCard(
    Theme.of(context).brightness == Brightness.dark
  );

  static Color textPrimary(BuildContext context) => AppColors.getTextPrimary(
    Theme.of(context).brightness == Brightness.dark
  );

  static Color textSecondary(BuildContext context) => AppColors.getTextSecondary(
    Theme.of(context).brightness == Brightness.dark
  );

  static Color divider(BuildContext context) => AppColors.getDivider(
    Theme.of(context).brightness == Brightness.dark
  );

  /// الحصول على ظل حسب الارتفاع
  static List<BoxShadow> shadowForElevation(double elevation) {
    if (elevation <= 0) return [];
    if (elevation <= 2) return shadowSm;
    if (elevation <= 4) return shadowMd;
    if (elevation <= 8) return shadowLg;
    return shadowXl;
  }

  /// استخدام دوال AppColors
  static LinearGradient customGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) => AppColors.getCategoryGradient('custom');

  static LinearGradient prayerGradient(String prayerName) => 
    AppColors.getCategoryGradient('prayer_times');

  static Color getPrayerColor(String name) => AppColors.getCategoryColor('prayer_times');
  
  static IconData getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return Icons.dark_mode;
      case 'dhuhr':
      case 'الظهر':
        return Icons.light_mode;
      case 'asr':
      case 'العصر':
        return Icons.wb_cloudy;
      case 'maghrib':
      case 'المغرب':
        return Icons.wb_twilight;
      case 'isha':
      case 'العشاء':
        return Icons.bedtime;
      case 'sunrise':
      case 'الشروق':
        return Icons.wb_sunny;
      default:
        return Icons.access_time;
    }
  }

  static LinearGradient getTimeBasedGradient() => AppColors.primaryGradient;
}