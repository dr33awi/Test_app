// lib/features/home/widgets/color_helper.dart - Enhanced Professional Version
import 'package:athkar_app/app/themes/theme_constants.dart';
import 'package:flutter/material.dart';

/// مساعد محسن لتوحيد الألوان والتدرجات في جميع أنحاء التطبيق
class ColorHelper {
  ColorHelper._();

  // مجموعة ألوان محسنة للتطبيق
  static const Map<String, List<Color>> _categoryColorPalettes = {
    'prayer_times': [
      Color(0xFF6366F1), // Indigo 500
      Color(0xFF8B5CF6), // Violet 500
      Color(0xFF3B82F6), // Blue 500
    ],
    'athkar': [
      Color(0xFF10B981), // Emerald 500
      Color(0xFF059669), // Emerald 600
      Color(0xFF34D399), // Emerald 400
    ],
    'asma_allah': [
      Color(0xFFF59E0B), // Amber 500
      Color(0xFFD97706), // Amber 600
      Color(0xFFFBBF24), // Amber 400
    ],
    'qibla': [
      Color(0xFF8B5CF6), // Violet 500
      Color(0xFF7C3AED), // Violet 600
      Color(0xFFA78BFA), // Violet 400
    ],
    'tasbih': [
      Color(0xFFEF4444), // Red 500
      Color(0xFFDC2626), // Red 600
      Color(0xFFF87171), // Red 400
    ],
    'dua': [
      Color(0xFF06B6D4), // Cyan 500
      Color(0xFF0891B2), // Cyan 600
      Color(0xFF22D3EE), // Cyan 400
    ],
  };

  /// الحصول على تدرج لوني محسن حسب الفئة
  static LinearGradient getCategoryGradient(String categoryId) {
    final colors = _categoryColorPalettes[categoryId] ?? [
      ThemeConstants.primary,
      ThemeConstants.primaryLight,
      ThemeConstants.primaryDark,
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors[0],
        colors[1],
      ],
      stops: const [0.0, 1.0],
    );
  }

  /// تدرج لوني متقدم مع نقاط توقف متعددة
  static LinearGradient getAdvancedCategoryGradient(String categoryId) {
    final colors = _categoryColorPalettes[categoryId] ?? [
      ThemeConstants.primary,
      ThemeConstants.primaryLight,
      ThemeConstants.primaryDark,
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors[0],
        colors[1],
        colors[0].withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  /// تدرج شفاف للخلفيات
  static LinearGradient getTransparentCategoryGradient(String categoryId, {
    double startOpacity = 0.3,
    double endOpacity = 0.1,
  }) {
    final colors = _categoryColorPalettes[categoryId] ?? [
      ThemeConstants.primary,
      ThemeConstants.primaryLight,
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors[0].withValues(alpha: startOpacity),
        colors[1].withValues(alpha: endOpacity),
      ],
    );
  }

  /// الحصول على تدرج لوني حسب نوع المحتوى
  static LinearGradient getContentGradient(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'verse':
      case 'آية':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF3B82F6), // Blue
          ],
        );
      case 'hadith':
      case 'حديث':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981), // Emerald
            const Color(0xFF059669), // Emerald dark
          ],
        );
      case 'dua':
      case 'دعاء':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B), // Amber
            const Color(0xFFD97706), // Amber dark
          ],
        );
      case 'athkar':
      case 'أذكار':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6), // Violet
            const Color(0xFF7C3AED), // Violet dark
          ],
        );
      case 'asma_allah':
      case 'أسماء الله':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEF4444), // Red
            const Color(0xFFDC2626), // Red dark
          ],
        );
      default:
        return ThemeConstants.primaryGradient;
    }
  }

  /// تدرج لوني متقدم مع تأثير الوهج
  static LinearGradient getGlowGradient(String categoryId) {
    final colors = _categoryColorPalettes[categoryId] ?? [
      ThemeConstants.primary,
      ThemeConstants.primaryLight,
    ];

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors[0].withValues(alpha: 0.8),
        colors[1].withValues(alpha: 0.6),
        colors[0].withValues(alpha: 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// الحصول على تدرج لوني حسب حالة التقدم مع ألوان محسنة
  static LinearGradient getProgressGradient(double progress) {
    if (progress < 0.3) {
      return const LinearGradient(
        colors: [
          Color(0xFFEF4444), // Red 500
          Color(0xFFF97316), // Orange 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (progress < 0.7) {
      return const LinearGradient(
        colors: [
          Color(0xFFF59E0B), // Amber 500
          Color(0xFFFBBF24), // Amber 400
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [
          Color(0xFF10B981), // Emerald 500
          Color(0xFF34D399), // Emerald 400
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// الحصول على تدرج لوني حسب الوقت مع ألوان طبيعية
  static LinearGradient getTimeBasedGradient({DateTime? dateTime}) {
    final time = dateTime ?? DateTime.now();
    final hour = time.hour;
    
    if (hour < 5) {
      // ليل - أزرق داكن
      return const LinearGradient(
        colors: [
          Color(0xFF1E293B), // Slate 800
          Color(0xFF334155), // Slate 700
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 8) {
      // فجر - بنفسجي وزهري
      return const LinearGradient(
        colors: [
          Color(0xFF7C3AED), // Violet 600
          Color(0xFFEC4899), // Pink 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 12) {
      // صباح - أصفر وبرتقالي
      return const LinearGradient(
        colors: [
          Color(0xFFFBBF24), // Amber 400
          Color(0xFFF97316), // Orange 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 15) {
      // ظهر - أزرق فاتح
      return const LinearGradient(
        colors: [
          Color(0xFF3B82F6), // Blue 500
          Color(0xFF06B6D4), // Cyan 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      // عصر - أخضر
      return const LinearGradient(
        colors: [
          Color(0xFF10B981), // Emerald 500
          Color(0xFF059669), // Emerald 600
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      // مغرب - برتقالي وأحمر
      return const LinearGradient(
        colors: [
          Color(0xFFF97316), // Orange 500
          Color(0xFFEF4444), // Red 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // مساء - بنفسجي داكن
      return const LinearGradient(
        colors: [
          Color(0xFF6366F1), // Indigo 500
          Color(0xFF8B5CF6), // Violet 500
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// الحصول على لون أساسي محسن حسب الفئة
  static Color getCategoryColor(String categoryId) {
    final colors = _categoryColorPalettes[categoryId];
    return colors?.first ?? ThemeConstants.primary;
  }

  /// الحصول على مجموعة ألوان خاصة بأسماء الله الحسنى (محسنة)
  static List<Color> getAsmaAllahColors() {
    return const [
      Color(0xFFF59E0B), // Amber 500
      Color(0xFFEF4444), // Red 500
      Color(0xFF8B5CF6), // Violet 500
      Color(0xFF10B981), // Emerald 500
      Color(0xFF06B6D4), // Cyan 500
      Color(0xFF6366F1), // Indigo 500
    ];
  }

  /// الحصول على لون من مجموعة أسماء الله الحسنى حسب الفهرس
  static Color getAsmaAllahColorByIndex(int index) {
    final colors = getAsmaAllahColors();
    return colors[index % colors.length];
  }

  /// تدرج لوني خاص بأسماء الله الحسنى مع تأثير مضيء محسن
  static LinearGradient getAsmaAllahSpecialGradient(int index) {
    final color = getAsmaAllahColorByIndex(index);
    final lightColor = _lightenColor(color, 0.2);
    final darkColor = _darkenColor(color, 0.1);
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightColor,
        color,
        darkColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// الحصول على لون حسب مستوى الأهمية مع ألوان محسنة
  static Color getImportanceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'عالي':
        return const Color(0xFFEF4444); // Red 500
      case 'medium':
      case 'متوسط':
        return const Color(0xFFF59E0B); // Amber 500
      case 'low':
      case 'منخفض':
        return const Color(0xFF06B6D4); // Cyan 500
      case 'success':
      case 'نجح':
        return const Color(0xFF10B981); // Emerald 500
      default:
        return const Color(0xFF6366F1); // Indigo 500
    }
  }

  /// الحصول على لون النص المتباين المحسن
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    if (luminance > 0.6) {
      return const Color(0xFF1F2937); // Gray 800
    } else if (luminance > 0.4) {
      return const Color(0xFF374151); // Gray 700
    } else {
      return Colors.white;
    }
  }

  /// دمج لونين بنسبة معينة مع تحسينات
  static Color blendColors(Color color1, Color color2, double ratio) {
    ratio = ratio.clamp(0.0, 1.0);
    
    final hsl1 = HSLColor.fromColor(color1);
    final hsl2 = HSLColor.fromColor(color2);
    
    final blendedHue = _interpolateAngle(hsl1.hue, hsl2.hue, ratio);
    final blendedSaturation = _interpolate(hsl1.saturation, hsl2.saturation, ratio);
    final blendedLightness = _interpolate(hsl1.lightness, hsl2.lightness, ratio);
    final blendedAlpha = _interpolate(hsl1.alpha, hsl2.alpha, ratio);
    
    return HSLColor.fromAHSL(blendedAlpha, blendedHue, blendedSaturation, blendedLightness).toColor();
  }

  /// الحصول على مجموعة ألوان متناسقة محسنة
  static List<Color> getHarmoniousColors(Color baseColor, {int count = 3}) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[];
    
    for (int i = 0; i < count; i++) {
      final hueShift = i * (360 / count);
      final newHue = (hsl.hue + hueShift) % 360;
      
      // تنويع طفيف في التشبع والسطوع
      final saturationVariation = (i * 0.1) - 0.05;
      final lightnessVariation = (i * 0.05) - 0.025;
      
      final newSaturation = (hsl.saturation + saturationVariation).clamp(0.0, 1.0);
      final newLightness = (hsl.lightness + lightnessVariation).clamp(0.0, 1.0);
      
      colors.add(HSLColor.fromAHSL(
        hsl.alpha,
        newHue,
        newSaturation,
        newLightness,
      ).toColor());
    }
    
    return colors;
  }

  /// تطبيق شفافية على لون مع الحفاظ على قوة اللون
  static Color applyOpacitySafely(Color color, double opacity) {
    opacity = opacity.clamp(0.0, 1.0);
    return color.withValues(alpha: opacity);
  }

  /// الحصول على تدرج شفاف محسن
  static LinearGradient getTransparentGradient(Color color, {
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.5),
        color.withValues(alpha: 0.8),
        color,
      ],
      stops: stops ?? const [0.0, 0.2, 0.5, 0.8, 1.0],
    );
  }

  /// الحصول على تدرج خاص للخلفيات المحسن
  static LinearGradient getBackgroundGradient({bool isDarkMode = false}) {
    if (isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F172A), // Slate 900
          Color(0xFF1E293B), // Slate 800
          Color(0xFF334155), // Slate 700
          Color(0xFF1E293B), // Slate 800
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFAFAFA), // Gray 50
          Color(0xFFF8FAFC), // Slate 50
          Color(0xFFF1F5F9), // Slate 100
          Color(0xFFF8FAFC), // Slate 50
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    }
  }

  /// تدرج لوني للحالات التفاعلية
  static LinearGradient getInteractiveGradient(Color baseColor, {
    bool isPressed = false,
    bool isHovered = false,
  }) {
    if (isPressed) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _darkenColor(baseColor, 0.2),
          _darkenColor(baseColor, 0.1),
        ],
      );
    } else if (isHovered) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lightenColor(baseColor, 0.1),
          baseColor,
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor,
          _darkenColor(baseColor, 0.05),
        ],
      );
    }
  }

  /// تدرج للظلال المحسنة
  static List<BoxShadow> getEnhancedShadow(Color color, {
    double elevation = 8.0,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: elevation * 0.5,
          offset: Offset(0, elevation * 0.25),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: elevation,
        offset: Offset(0, elevation * 0.5),
        spreadRadius: elevation * 0.1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
        spreadRadius: 0,
      ),
    ];
  }

  // Helper methods
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static double _interpolate(double start, double end, double ratio) {
    return start + (end - start) * ratio;
  }

  static double _interpolateAngle(double start, double end, double ratio) {
    final diff = ((end - start + 180) % 360) - 180;
    return (start + diff * ratio) % 360;
  }

  /// تدرج لوني للأزرار المحسنة
  static LinearGradient getButtonGradient(String type) {
    switch (type.toLowerCase()) {
      case 'primary':
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'secondary':
        return const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'success':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'warning':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'error':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}