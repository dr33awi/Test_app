// lib/app/themes/core/color_helper.dart - محدث ومكتمل
import 'package:flutter/material.dart';

/// ألوان التطبيق الموحدة - مصدر واحد لجميع الألوان
class AppColors {
  AppColors._();

  // ===== الألوان الأساسية =====
  static const Color primary = Color(0xFF5D7052);
  static const Color primaryLight = Color(0xFF7A8B6F);
  static const Color primaryDark = Color(0xFF445A3B);
  static const Color primarySoft = Color(0xFF8FA584);

  // ===== الألوان الثانوية =====
  static const Color accent = Color(0xFFB8860B);
  static const Color accentLight = Color(0xFFDAA520);
  static const Color accentDark = Color(0xFF996515);
  
  // ===== اللون الثالث =====
  static const Color tertiary = Color(0xFF8B6F47);
  static const Color tertiaryLight = Color(0xFFA68B5B);
  static const Color tertiaryDark = Color(0xFF6B5637);

  // ===== الألوان الدلالية =====
  static const Color success = Color(0xFF5D7052);
  static const Color error = Color(0xFFB85450);
  static const Color warning = Color(0xFFD4A574);
  static const Color info = Color(0xFF6B8E9F);

  // ===== ألوان الوضع الفاتح =====
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFF5F5F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0DDD4);
  static const Color lightTextPrimary = Color(0xFF2D2D2D);
  static const Color lightTextSecondary = Color(0xFF5F5F5F);
  static const Color lightTextHint = Color(0xFF8F8F8F);

  // ===== ألوان الوضع الداكن =====
  static const Color darkBackground = Color(0xFF1A1F1A);
  static const Color darkSurface = Color(0xFF242B24);
  static const Color darkCard = Color(0xFF2D352D);
  static const Color darkDivider = Color(0xFF3A453A);
  static const Color darkTextPrimary = Color(0xFFF5F5F0);
  static const Color darkTextSecondary = Color(0xFFBDBDB0);
  static const Color darkTextHint = Color(0xFF8A8A80);

  // ===== ألوان خاصة بالفئات =====
  static const Color prayerTimesColor = primary;
  static const Color athkarColor = accent;
  static const Color asmaAllahColor = tertiary;
  static const Color duaColor = tertiaryDark;
  static const Color qiblaColor = primaryDark;
  static const Color tasbihColor = accentDark;

  // ===== ألوان أسماء الله الحسنى (3 ألوان فقط) =====
  static const List<Color> asmaAllahColors = [
    primary,    // اللون الأساسي
    accent,     // اللون الثانوي
    tertiary,   // اللون الثالث
  ];

  // ===== التدرجات الأساسية =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [tertiaryLight, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== دوال مساعدة =====
  
  /// الحصول على اللون حسب الثيم
  static Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getDivider(bool isDark) => isDark ? darkDivider : lightDivider;

  /// الحصول على لون الفئة
  static Color getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'prayer_times': return prayerTimesColor;
      case 'athkar': return athkarColor;
      case 'asma_allah': return asmaAllahColor;
      case 'dua': return duaColor;
      case 'qibla': return qiblaColor;
      case 'tasbih': return tasbihColor;
      default: return primary;
    }
  }

  /// الحصول على تدرج الفئة
  static LinearGradient getCategoryGradient(String categoryId) {
    switch (categoryId) {
      case 'prayer_times': return primaryGradient;
      case 'athkar': return accentGradient;
      case 'asma_allah': return tertiaryGradient;
      case 'dua': return const LinearGradient(
          colors: [tertiaryDark, tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'qibla': return const LinearGradient(
          colors: [primaryDark, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'tasbih': return const LinearGradient(
          colors: [accentDark, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default: return primaryGradient;
    }
  }

  /// الحصول على تدرج المحتوى حسب النوع
  static LinearGradient getContentGradient(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'verse':
      case 'آية':
        return const LinearGradient(
          colors: [primary, primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'hadith':
      case 'حديث':
        return const LinearGradient(
          colors: [accent, accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'dua':
      case 'دعاء':
        return const LinearGradient(
          colors: [tertiary, tertiaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'athkar':
      case 'أذكار':
        return accentGradient;
      case 'quote':
      case 'حكمة':
        return const LinearGradient(
          colors: [primaryDark, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'morning':
      case 'صباح':
        return const LinearGradient(
          colors: [accentLight, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'evening':
      case 'مساء':
        return const LinearGradient(
          colors: [primaryDark, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sleep':
      case 'نوم':
        return const LinearGradient(
          colors: [tertiaryDark, tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return primaryGradient;
    }
  }

  /// الحصول على لون من مجموعة أسماء الله الحسنى حسب الفهرس
  static Color getAsmaAllahColorByIndex(int index) {
    return asmaAllahColors[index % asmaAllahColors.length];
  }

  /// الحصول على لون حسب مستوى الأهمية
  static Color getImportanceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'عالي':
        return error;
      case 'medium':
      case 'متوسط':
        return warning;
      case 'low':
      case 'منخفض':
        return info;
      case 'success':
      case 'نجح':
        return success;
      default:
        return primary;
    }
  }

  /// الحصول على تدرج حسب وقت الصلاة
  static LinearGradient getPrayerGradient(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return const LinearGradient(
          colors: [primaryDark, primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'dhuhr':
      case 'الظهر':
        return const LinearGradient(
          colors: [accentLight, accent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'asr':
      case 'العصر':
        return const LinearGradient(
          colors: [primarySoft, primaryLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'maghrib':
      case 'المغرب':
        return const LinearGradient(
          colors: [tertiaryLight, tertiary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'isha':
      case 'العشاء':
        return const LinearGradient(
          colors: [darkCard, darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return primaryGradient;
    }
  }

  /// الحصول على لون حسب اسم الصلاة
  static Color getPrayerColor(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return primaryDark;
      case 'dhuhr':
      case 'الظهر':
        return accent;
      case 'asr':
      case 'العصر':
        return primaryLight;
      case 'maghrib':
      case 'المغرب':
        return tertiary;
      case 'isha':
      case 'العشاء':
        return darkCard;
      case 'sunrise':
      case 'الشروق':
        return accentLight;
      default:
        return primary;
    }
  }

  /// الحصول على تدرج حسب الوقت
  static LinearGradient getTimeBasedGradient({DateTime? dateTime}) {
    final time = dateTime ?? DateTime.now();
    final hour = time.hour;
    
    if (hour < 5) {
      return const LinearGradient(
        colors: [darkBackground, darkCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 8) {
      return const LinearGradient(
        colors: [primaryDark, primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 12) {
      return const LinearGradient(
        colors: [accent, accentLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 15) {
      return const LinearGradient(
        colors: [primary, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      return const LinearGradient(
        colors: [primaryLight, primarySoft],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      return const LinearGradient(
        colors: [tertiary, tertiaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [primaryDark, primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
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