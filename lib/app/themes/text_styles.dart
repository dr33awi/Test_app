// lib/app/themes/text_styles.dart - مصحح
import 'package:athkar_app/app/themes/constants/app_constants.dart';
import 'package:flutter/material.dart';

import 'theme_constants.dart';

/// أنماط النصوص الموحدة للتطبيق
class AppTextStyles {
  AppTextStyles._();

  // ===== أنماط العناوين =====
  static TextStyle h1 = const TextStyle(
    fontSize: AppConstants.textSize4xl,
    fontWeight: AppConstants.bold,
    height: 1.3,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: AppConstants.textSize3xl,
    fontWeight: AppConstants.semiBold,
    height: 1.3,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: AppConstants.textSize2xl,
    fontWeight: AppConstants.semiBold,
    height: 1.4,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: AppConstants.textSizeXl,
    fontWeight: AppConstants.semiBold,
    height: 1.4,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: AppConstants.textSizeLg,
    fontWeight: AppConstants.semiBold,
    height: 1.5,
    fontFamily: AppConstants.fontFamily,
  );

  // ===== أنماط النص الأساسي =====
  static const TextStyle body1 = TextStyle(
    fontSize: AppConstants.textSizeLg,
    fontWeight: AppConstants.regular,
    height: 1.6,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: AppConstants.textSizeMd,
    fontWeight: AppConstants.regular,
    height: 1.6,
    fontFamily: AppConstants.fontFamily,
  );

  // ===== أنماط التسميات =====
  static const TextStyle label1 = TextStyle(
    fontSize: AppConstants.textSizeMd,
    fontWeight: AppConstants.medium,
    height: 1.4,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle label2 = TextStyle(
    fontSize: AppConstants.textSizeSm,
    fontWeight: AppConstants.medium,
    height: 1.4,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppConstants.textSizeXs,
    fontWeight: AppConstants.regular,
    height: 1.4,
    fontFamily: AppConstants.fontFamily,
  );

  // ===== أنماط الأزرار =====
  static const TextStyle button = TextStyle(
    fontSize: AppConstants.textSizeLg,
    fontWeight: AppConstants.semiBold,
    height: 1.2,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: AppConstants.textSizeMd,
    fontWeight: AppConstants.semiBold,
    height: 1.2,
    fontFamily: AppConstants.fontFamily,
  );

  // ===== أنماط خاصة بالمحتوى الإسلامي =====
  static const TextStyle quran = TextStyle(
    fontSize: 22,
    fontWeight: AppConstants.regular,
    height: 2.0,
    fontFamily: AppConstants.fontFamilyQuran,
  );

  static const TextStyle athkar = TextStyle(
    fontSize: AppConstants.textSizeXl,
    fontWeight: AppConstants.regular,
    height: 1.8,
    fontFamily: AppConstants.fontFamily,
  );

  static const TextStyle dua = TextStyle(
    fontSize: AppConstants.textSizeLg,
    fontWeight: AppConstants.regular,
    height: 1.7,
    fontFamily: AppConstants.fontFamily,
  );

  // ===== إنشاء TextTheme للتطبيق =====
  static TextTheme createTextTheme({
    required Color color,
    Color? secondaryColor,
  }) {
    final Color effectiveSecondaryColor = secondaryColor ?? color.withValues(alpha: 0.7);
    
    return TextTheme(
      // Display styles
      displayLarge: h1.copyWith(color: color),
      displayMedium: h2.copyWith(color: color),
      displaySmall: h3.copyWith(color: color),
      
      // Headline styles
      headlineLarge: h1.copyWith(color: color),
      headlineMedium: h2.copyWith(color: color),
      headlineSmall: h3.copyWith(color: color),
      
      // Title styles
      titleLarge: h4.copyWith(color: color),
      titleMedium: h5.copyWith(color: color),
      titleSmall: h5.copyWith(color: color, fontSize: AppConstants.textSizeMd),
      
      // Body styles
      bodyLarge: body1.copyWith(color: color),
      bodyMedium: body2.copyWith(color: effectiveSecondaryColor),
      bodySmall: caption.copyWith(color: effectiveSecondaryColor),
      
      // Label styles
      labelLarge: label1.copyWith(color: color),
      labelMedium: label2.copyWith(color: effectiveSecondaryColor),
      labelSmall: caption.copyWith(color: effectiveSecondaryColor),
    );
  }

  // ===== أنماط مخصصة حسب السياق =====
  
  /// نص للعناوين الرئيسية في الصفحات
  static TextStyle pageTitle(BuildContext context) {
    return h2.copyWith(
      color: ThemeConstants.textPrimary(context),
    );
  }

  /// نص للعناوين الفرعية
  static TextStyle sectionTitle(BuildContext context) {
    return h4.copyWith(
      color: ThemeConstants.textPrimary(context),
    );
  }

  /// نص للمحتوى الرئيسي
  static TextStyle contentText(BuildContext context) {
    return body1.copyWith(
      color: ThemeConstants.textPrimary(context),
    );
  }

  /// نص للمعلومات الثانوية
  static TextStyle secondaryText(BuildContext context) {
    return body2.copyWith(
      color: ThemeConstants.textSecondary(context),
    );
  }

  /// نص للتلميحات
  static TextStyle hintText(BuildContext context) {
    return caption.copyWith(
      color: ThemeConstants.textSecondary(context).withValues(alpha: 0.7),
    );
  }

  /// نص للأخطاء
  static TextStyle errorText(BuildContext context) {
    return caption.copyWith(
      color: ThemeConstants.error,
    );
  }

  /// نص للنجاح
  static TextStyle successText(BuildContext context) {
    return body2.copyWith(
      color: ThemeConstants.success,
      fontWeight: AppConstants.medium,
    );
  }

  /// نص للتحذيرات
  static TextStyle warningText(BuildContext context) {
    return body2.copyWith(
      color: ThemeConstants.warning,
      fontWeight: AppConstants.medium,
    );
  }

  /// نص للمعلومات
  static TextStyle infoText(BuildContext context) {
    return body2.copyWith(
      color: ThemeConstants.info,
    );
  }

  /// نص للروابط
  static TextStyle linkText(BuildContext context) {
    return body2.copyWith(
      color: ThemeConstants.primary,
      decoration: TextDecoration.underline,
    );
  }
}