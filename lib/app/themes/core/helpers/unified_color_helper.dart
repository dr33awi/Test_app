// lib/app/themes/core/helpers/unified_color_helper.dart
import 'package:flutter/material.dart';
import '../../theme_constants.dart';

/// مساعد موحد للألوان في جميع أنحاء التطبيق
/// يجمع جميع وظائف الألوان في مكان واحد لتجنب التكرار
class UnifiedColorHelper {
  UnifiedColorHelper._();

  // ==================== التدرجات اللونية ====================
  
  /// الحصول على تدرج لوني حسب الفئة
  static LinearGradient getCategoryGradient(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'prayer_times':
      case 'مواقيت الصلاة':
        return const LinearGradient(
          colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'athkar':
      case 'أذكار':
        return const LinearGradient(
          colors: [ThemeConstants.accent, ThemeConstants.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'asma_allah':
      case 'أسماء الله الحسنى':
        return const LinearGradient(
          colors: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'quran':
      case 'قرآن':
        return const LinearGradient(
          colors: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'qibla':
      case 'القبلة':
        return const LinearGradient(
          colors: [ThemeConstants.primaryDark, ThemeConstants.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'tasbih':
      case 'التسبيح':
        return const LinearGradient(
          colors: [ThemeConstants.accentDark, ThemeConstants.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'dua':
      case 'دعاء':
      case 'أدعية':
        return const LinearGradient(
          colors: [ThemeConstants.tertiaryDark, ThemeConstants.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'settings':
      case 'إعدادات':
        return LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return ThemeConstants.primaryGradient;
    }
  }

  /// الحصول على تدرج لوني حسب نوع المحتوى
  static LinearGradient getContentGradient(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'verse':
      case 'آية':
        return const LinearGradient(
          colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'hadith':
      case 'حديث':
        return const LinearGradient(
          colors: [ThemeConstants.accent, ThemeConstants.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'dua':
      case 'دعاء':
        return const LinearGradient(
          colors: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'athkar':
      case 'أذكار':
        return const LinearGradient(
          colors: [ThemeConstants.accentDark, ThemeConstants.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'wisdom':
      case 'حكمة':
        return const LinearGradient(
          colors: [ThemeConstants.tertiaryDark, ThemeConstants.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return ThemeConstants.primaryGradient;
    }
  }

  /// الحصول على تدرج للحالة
  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'نجح':
      case 'مكتمل':
        return LinearGradient(
          colors: [ThemeConstants.success, ThemeConstants.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'warning':
      case 'pending':
      case 'تحذير':
      case 'معلق':
        return LinearGradient(
          colors: [ThemeConstants.warning, ThemeConstants.warning.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'error':
      case 'failed':
      case 'خطأ':
      case 'فشل':
        return LinearGradient(
          colors: [ThemeConstants.error, ThemeConstants.error.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'info':
      case 'معلومات':
        return LinearGradient(
          colors: [ThemeConstants.info, ThemeConstants.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return ThemeConstants.primaryGradient;
    }
  }

  // ==================== الألوان المفردة ====================
  
  /// الحصول على لون حسب الفئة
  static Color getCategoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'prayer_times':
        return ThemeConstants.primary;
      case 'athkar':
        return ThemeConstants.accent;
      case 'asma_allah':
        return ThemeConstants.tertiary;
      case 'qibla':
        return ThemeConstants.primaryDark;
      case 'tasbih':
        return ThemeConstants.accentDark;
      case 'dua':
        return ThemeConstants.tertiaryDark;
      default:
        return ThemeConstants.primary;
    }
  }

  /// الحصول على لون حسب مستوى الأهمية
  static Color getImportanceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'عالي':
        return ThemeConstants.error;
      case 'medium':
      case 'متوسط':
        return ThemeConstants.warning;
      case 'low':
      case 'منخفض':
        return ThemeConstants.info;
      case 'success':
      case 'نجح':
        return ThemeConstants.success;
      default:
        return ThemeConstants.primary;
    }
  }

  /// الحصول على لون حسب الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'نجح':
      case 'مكتمل':
        return ThemeConstants.success;
      case 'warning':
      case 'pending':
      case 'تحذير':
      case 'معلق':
        return ThemeConstants.warning;
      case 'error':
      case 'failed':
      case 'خطأ':
      case 'فشل':
        return ThemeConstants.error;
      case 'info':
      case 'معلومات':
        return ThemeConstants.info;
      default:
        return ThemeConstants.primary;
    }
  }

  // ==================== عمليات الألوان ====================
  
  /// الحصول على لون النص المتباين
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// دمج لونين بنسبة معينة
  static Color blendColors(Color color1, Color color2, double ratio) {
    ratio = ratio.clamp(0.0, 1.0);
    
    return Color.fromARGB(
      ((1 - ratio) * color1.alpha + ratio * color2.alpha).round(),
      ((1 - ratio) * color1.red + ratio * color2.red).round(),
      ((1 - ratio) * color1.green + ratio * color2.green).round(),
      ((1 - ratio) * color1.blue + ratio * color2.blue).round(),
    );
  }

  /// تطبيق شفافية على اللون
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  /// تفتيح اللون
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// تغميق اللون
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// الحصول على مجموعة ألوان متناسقة
  static List<Color> getHarmoniousColors(Color baseColor, {int count = 3}) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[];
    
    for (int i = 0; i < count; i++) {
      final hue = (hsl.hue + (360 / count * i)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }
    
    return colors;
  }

  /// الحصول على ألوان التدرج المناسبة للخلفية
  static List<Color> getBackgroundGradientColors(bool isDarkMode) {
    if (isDarkMode) {
      return [
        ThemeConstants.darkBackground,
        ThemeConstants.darkSurface,
      ];
    } else {
      return [
        ThemeConstants.lightBackground,
        ThemeConstants.lightSurface,
      ];
    }
  }

  /// الحصول على لون مع تشبع مخصص
  static Color withSaturation(Color color, double saturation) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(saturation.clamp(0.0, 1.0)).toColor();
  }

  /// الحصول على لون مع كمية ضوء مخصصة
  static Color withLightness(Color color, double lightness) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// تحويل لون إلى MaterialColor
  static MaterialColor toMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    
    for (var i = 0; i < strengths.length; i++) {
      final strength = strengths[i];
      swatch[(strength * 1000).round()] = i < 5
          ? lighten(color, strength)
          : darken(color, strength - 0.5);
    }
    
    swatch[500] = color;
    
    return MaterialColor(color.value, swatch);
  }
}