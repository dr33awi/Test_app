// lib/app/themes/app_theme.dart - مصحح
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// الاستيرادات المصححة
import 'core/color_helper.dart';
import 'core/color_utils.dart'; 
import 'core/theme_extensions.dart';
import 'text_styles.dart';
import 'theme_constants.dart';

// نقل AppConstants إلى المكان الصحيح أو استخدام ThemeConstants
// import '../../core/constants/app_constants.dart';

// Barrel Exports - مصحح
export 'core/color_helper.dart';
export 'core/color_utils.dart';
export 'core/theme_extensions.dart';
export 'text_styles.dart';
export 'theme_constants.dart';

// Widgets exports
export 'widgets/cards/app_card.dart';
export 'widgets/dialogs/app_info_dialog.dart';
export 'widgets/feedback/app_snackbar.dart';
export 'widgets/feedback/app_notice_card.dart';
export 'widgets/layout/app_bar.dart';
export 'widgets/states/app_empty_state.dart';
export 'widgets/core/app_button.dart';
export 'widgets/core/app_text_field.dart';
export 'widgets/core/app_loading.dart';

/// نظام الثيم الموحد للتطبيق
class AppTheme {
  AppTheme._();

  /// الثيم الفاتح
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    backgroundColor: AppColors.lightBackground,
    surfaceColor: AppColors.lightSurface,
    cardColor: AppColors.lightCard,
    textPrimaryColor: AppColors.lightTextPrimary,
    textSecondaryColor: AppColors.lightTextSecondary,
    dividerColor: AppColors.lightDivider,
  );

  /// الثيم الداكن
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    backgroundColor: AppColors.darkBackground,
    surfaceColor: AppColors.darkSurface,
    cardColor: AppColors.darkCard,
    textPrimaryColor: AppColors.darkTextPrimary,
    textSecondaryColor: AppColors.darkTextSecondary,
    dividerColor: AppColors.darkDivider,
  );

  /// بناء الثيم الموحد
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color cardColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color dividerColor,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color onPrimaryColor = primaryColor.contrastingTextColor;
    final Color onSecondaryColor = AppColors.accent.contrastingTextColor;

    // Create text theme
    final textTheme = AppTextStyles.createTextTheme(
      color: textPrimaryColor,
      secondaryColor: textSecondaryColor,
    );

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,
      fontFamily: ThemeConstants.fontFamily, // استخدام ThemeConstants
      
      // ColorScheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: AppColors.accent,
        onSecondary: onSecondaryColor,
        tertiary: AppColors.accentLight,
        onTertiary: AppColors.accentLight.contrastingTextColor,
        error: AppColors.error,
        onError: Colors.white,
        surface: backgroundColor,
        onSurface: textPrimaryColor,
        surfaceContainerHighest: cardColor,
        onSurfaceVariant: textSecondaryColor,
        outline: dividerColor,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h4.copyWith(color: textPrimaryColor),
        iconTheme: IconThemeData(
          color: textPrimaryColor,
          size: ThemeConstants.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: backgroundColor,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: ThemeConstants.elevationNone,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
      
      // Text Theme
      textTheme: textTheme,
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _elevatedButtonStyle(primaryColor, onPrimaryColor),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(primaryColor),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: _textButtonStyle(primaryColor),
      ),
      
      // Input Theme
      inputDecorationTheme: _inputDecorationTheme(
        isDark: isDark,
        primaryColor: primaryColor,
        surfaceColor: surfaceColor,
        dividerColor: dividerColor,
        textSecondaryColor: textSecondaryColor,
      ),
      
      // Other Themes
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: ThemeConstants.borderLight,
        space: ThemeConstants.space1,
      ),
      
      iconTheme: IconThemeData(
        color: textPrimaryColor,
        size: ThemeConstants.iconMd,
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor.withValues(alpha: ThemeConstants.opacity50),
        circularTrackColor: dividerColor.withValues(alpha: ThemeConstants.opacity50),
      ),
      
      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor.withValues(alpha: ThemeConstants.opacity70),
        type: BottomNavigationBarType.fixed,
        elevation: ThemeConstants.elevation8,
        selectedLabelStyle: AppTextStyles.label2.copyWith(
          fontWeight: ThemeConstants.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.label2,
        selectedIconTheme: IconThemeData(size: ThemeConstants.iconMd),
        unselectedIconTheme: IconThemeData(size: ThemeConstants.iconMd),
      ),
      
      // باقي الكود...
    );
  }

  // Button Styles مع استخدام ThemeConstants
  static ButtonStyle _elevatedButtonStyle(Color primaryColor, Color onPrimaryColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      disabledBackgroundColor: AppColors.lightTextHint.withValues(alpha: ThemeConstants.opacity30),
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: ThemeConstants.opacity70),
      elevation: ThemeConstants.elevationNone,
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConstants.space6,
        vertical: ThemeConstants.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
      minimumSize: Size(ThemeConstants.heightLg, ThemeConstants.buttonHeight),
    );
  }

  static ButtonStyle _outlinedButtonStyle(Color primaryColor) {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(
        color: primaryColor,
        width: ThemeConstants.borderMedium,
      ),
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: ThemeConstants.opacity70),
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConstants.space6,
        vertical: ThemeConstants.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
      minimumSize: Size(ThemeConstants.heightLg, ThemeConstants.buttonHeight),
    );
  }

  static ButtonStyle _textButtonStyle(Color primaryColor) {
    return TextButton.styleFrom(
      foregroundColor: primaryColor,
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: ThemeConstants.opacity70),
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConstants.space4,
        vertical: ThemeConstants.space2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _inputDecorationTheme({
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color dividerColor,
    required Color textSecondaryColor,
  }) {
    return InputDecorationTheme(
      fillColor: surfaceColor.withValues(
        alpha: isDark ? ThemeConstants.opacity10 : ThemeConstants.opacity50
      ),
      filled: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ThemeConstants.space4,
        vertical: ThemeConstants.space4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        borderSide: BorderSide(
          color: dividerColor,
          width: ThemeConstants.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        borderSide: BorderSide(
          color: dividerColor,
          width: ThemeConstants.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        borderSide: BorderSide(
          color: primaryColor,
          width: ThemeConstants.borderThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        borderSide: BorderSide(
          color: AppColors.error,
          width: ThemeConstants.borderLight,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        borderSide: BorderSide(
          color: AppColors.error,
          width: ThemeConstants.borderThick,
        ),
      ),
      hintStyle: AppTextStyles.body2.copyWith(
        color: textSecondaryColor.withValues(alpha: ThemeConstants.opacity70),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: textSecondaryColor),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      alignLabelWithHint: true,
    );
  }
}