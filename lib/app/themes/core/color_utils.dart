// lib/app/themes/core/color_utils.dart - مصحح
import 'package:flutter/material.dart';
import 'color_helper.dart';

/// دوال مساعدة للألوان - دمج جميع الدوال المكررة
class ColorUtils {
  ColorUtils._();

  /// الحصول على لون النص المتباين (دالة موحدة)
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// تطبيق شفافية آمنة على لون
  static Color applyOpacitySafely(Color color, double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return color.withValues(alpha: safeOpacity);
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

  /// دمج لونين بنسبة معينة
  static Color blendColors(Color color1, Color color2, double ratio) {
    ratio = ratio.clamp(0.0, 1.0);
    
    return Color.fromARGB(
      ((1 - ratio) * color1.a + ratio * color2.a).round(),
      ((1 - ratio) * color1.r + ratio * color2.r).round(),
      ((1 - ratio) * color1.g + ratio * color2.g).round(),
      ((1 - ratio) * color1.b + ratio * color2.b).round(),
    );
  }

  /// تحويل اللون إلى MaterialColor
  static MaterialColor toMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    
    for (var i = 0; i < strengths.length; i++) {
      final strength = strengths[i];
      swatch[(strength * 1000).round()] = i < 5
          ? lighten(color, strength)
          : darken(color, strength - 0.5);
    }
    
    return MaterialColor(color.value, swatch);
  }

  /// الحصول على مجموعة ألوان متناسقة
  static List<Color> getHarmoniousColors(Color baseColor, {int count = 3}) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[];
    
    for (int i = 0; i < count; i++) {
      final newHue = (hsl.hue + (i * 360 / count)) % 360;
      colors.add(hsl.withHue(newHue).toColor());
    }
    
    return colors;
  }

  /// الحصول على تدرج شفاف
  static LinearGradient getTransparentGradient(
    Color color, {
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        applyOpacitySafely(color, 0.0),
        applyOpacitySafely(color, 0.3),
        applyOpacitySafely(color, 0.7),
        color,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// الحصول على تدرج حسب حالة التقدم
  static LinearGradient getProgressGradient(double progress) {
    if (progress < 0.3) {
      return LinearGradient(
        colors: [
          applyOpacitySafely(AppColors.error, 0.8),
          AppColors.warning
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (progress < 0.7) {
      return const LinearGradient(
        colors: [AppColors.warning, AppColors.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [AppColors.success, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// الحصول على تدرج حسب الوقت
  static LinearGradient getTimeBasedGradient({DateTime? dateTime}) {
    final time = dateTime ?? DateTime.now();
    final hour = time.hour;
    
    if (hour < 5) {
      return const LinearGradient(
        colors: [AppColors.darkBackground, AppColors.darkCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 8) {
      return const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 12) {
      return const LinearGradient(
        colors: [AppColors.accent, AppColors.accentLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 15) {
      return const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      return const LinearGradient(
        colors: [AppColors.primaryLight, AppColors.primarySoft],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      return const LinearGradient(
        colors: [AppColors.tertiary, AppColors.tertiaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// الحصول على لون حسب اسم الصلاة
  static Color getPrayerColor(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return AppColors.primaryDark;
      case 'dhuhr':
      case 'الظهر':
        return AppColors.accent;
      case 'asr':
      case 'العصر':
        return AppColors.primaryLight;
      case 'maghrib':
      case 'المغرب':
        return AppColors.tertiary;
      case 'isha':
      case 'العشاء':
        return AppColors.darkCard;
      case 'sunrise':
      case 'الشروق':
        return AppColors.accentLight;
      default:
        return AppColors.primary;
    }
  }

  /// الحصول على تدرج حسب وقت الصلاة
  static LinearGradient getPrayerGradient(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'dhuhr':
      case 'الظهر':
        return const LinearGradient(
          colors: [AppColors.accentLight, AppColors.accent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'asr':
      case 'العصر':
        return const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.primaryLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'maghrib':
      case 'المغرب':
        return const LinearGradient(
          colors: [AppColors.tertiaryLight, AppColors.tertiary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'isha':
      case 'العشاء':
        return const LinearGradient(
          colors: [AppColors.darkCard, AppColors.darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  /// إنشاء تدرج مخصص
  static LinearGradient createCustomGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
    );
  }
}