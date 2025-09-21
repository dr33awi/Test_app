// lib/app/themes/app_theme.dart - محسن وموحد
import 'package:athkar_app/app/themes/core/color_helper.dart';
import 'package:athkar_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_styles.dart';
import 'core/theme_extensions.dart';

// ===== Barrel Exports - منظف =====
export 'core/app_colors.dart';
export '../constants/app_constants.dart';
export 'text_styles.dart';
export 'core/theme_extensions.dart';
export '../utils/color_utils.dart';

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

/// نظام الثيم الموحد للتطبيق - محسن ومبسط
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
      fontFamily: AppConstants.fontFamily,
      
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
          size: AppConstants.iconMd,
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
        elevation: AppConstants.elevationNone,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
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
        thickness: AppConstants.borderLight,
        space: AppConstants.space1,
      ),
      
      iconTheme: IconThemeData(
        color: textPrimaryColor,
        size: AppConstants.iconMd,
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor.withValues(alpha: AppConstants.opacity50),
        circularTrackColor: dividerColor.withValues(alpha: AppConstants.opacity50),
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
        unselectedItemColor: textSecondaryColor.withValues(alpha: AppConstants.opacity70),
        type: BottomNavigationBarType.fixed,
        elevation: AppConstants.elevation8,
        selectedLabelStyle: AppTextStyles.label2.copyWith(
          fontWeight: AppConstants.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.label2,
        selectedIconTheme: const IconThemeData(size: AppConstants.iconMd),
        unselectedIconTheme: const IconThemeData(size: AppConstants.iconMd),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        deleteIconColor: textSecondaryColor,
        disabledColor: AppColors.lightTextHint.withValues(alpha: AppConstants.opacity30),
        selectedColor: primaryColor,
        secondarySelectedColor: AppColors.accent,
        labelPadding: const EdgeInsets.symmetric(horizontal: AppConstants.space2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space3,
          vertical: AppConstants.space1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        labelStyle: AppTextStyles.label2.copyWith(color: textPrimaryColor),
        secondaryLabelStyle: AppTextStyles.label2.copyWith(color: onPrimaryColor),
        brightness: brightness,
      ),
      
      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor.withValues(alpha: AppConstants.opacity70),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            width: AppConstants.borderThick,
          ),
        ),
        labelStyle: AppTextStyles.label1.copyWith(
          fontWeight: AppConstants.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.label1,
      ),
      
      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: AppConstants.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        titleTextStyle: AppTextStyles.h5.copyWith(color: textPrimaryColor),
        contentTextStyle: AppTextStyles.body2.copyWith(color: textSecondaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        elevation: AppConstants.elevation8,
      ),
      
      // Switch Theme
      switchTheme: _switchTheme(isDark, primaryColor),
      
      // Checkbox Theme
      checkboxTheme: _checkboxTheme(isDark, primaryColor, onPrimaryColor),
      
      // Radio Theme
      radioTheme: _radioTheme(primaryColor, textSecondaryColor),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: AppConstants.opacity30),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: AppConstants.opacity20),
        valueIndicatorColor: primaryColor.darken(0.1),
        valueIndicatorTextStyle: AppTextStyles.caption.copyWith(color: onPrimaryColor),
      ),
      
      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              .withValues(alpha: AppConstants.opacity90),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: textPrimaryColor),
        preferBelow: false,
      ),
    );
  }

  // ===== Button Styles =====
  
  static ButtonStyle _elevatedButtonStyle(Color primaryColor, Color onPrimaryColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      disabledBackgroundColor: AppColors.lightTextHint.withValues(alpha: AppConstants.opacity30),
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: AppConstants.opacity70),
      elevation: AppConstants.elevationNone,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space6,
        vertical: AppConstants.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
      minimumSize: const Size(AppConstants.heightLg, AppConstants.buttonHeight),
    );
  }

  static ButtonStyle _outlinedButtonStyle(Color primaryColor) {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(
        color: primaryColor,
        width: AppConstants.borderMedium,
      ),
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: AppConstants.opacity70),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space6,
        vertical: AppConstants.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
      minimumSize: const Size(AppConstants.heightLg, AppConstants.buttonHeight),
    );
  }

  static ButtonStyle _textButtonStyle(Color primaryColor) {
    return TextButton.styleFrom(
      foregroundColor: primaryColor,
      disabledForegroundColor: AppColors.lightTextHint.withValues(alpha: AppConstants.opacity70),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space4,
        vertical: AppConstants.space2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      textStyle: AppTextStyles.button,
    );
  }

  // ===== Input Decoration Theme =====
  
  static InputDecorationTheme _inputDecorationTheme({
    required bool isDark,
    required Color primaryColor,
    required Color surfaceColor,
    required Color dividerColor,
    required Color textSecondaryColor,
  }) {
    return InputDecorationTheme(
      fillColor: surfaceColor.withValues(
        alpha: isDark ? AppConstants.opacity10 : AppConstants.opacity50
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space4,
        vertical: AppConstants.space4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(
          color: dividerColor,
          width: AppConstants.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(
          color: dividerColor,
          width: AppConstants.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(
          color: primaryColor,
          width: AppConstants.borderThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppConstants.borderLight,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppConstants.borderThick,
        ),
      ),
      hintStyle: AppTextStyles.body2.copyWith(
        color: textSecondaryColor.withValues(alpha: AppConstants.opacity70),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: textSecondaryColor),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      alignLabelWithHint: true,
    );
  }

  // ===== Switch Theme =====
  
  static SwitchThemeData _switchTheme(bool isDark, Color primaryColor) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        if (states.contains(WidgetState.disabled)) {
          return isDark ? AppColors.darkSurface : AppColors.lightSurface;
        }
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withValues(alpha: AppConstants.opacity50);
        }
        if (states.contains(WidgetState.disabled)) {
          return (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              .withValues(alpha: AppConstants.opacity50);
        }
        return (isDark ? AppColors.darkTextSecondary : AppColors.lightTextHint)
            .withValues(alpha: AppConstants.opacity30);
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return primaryColor.withValues(alpha: AppConstants.opacity10);
        }
        return null;
      }),
    );
  }

  // ===== Checkbox Theme =====
  
  static CheckboxThemeData _checkboxTheme(
    bool isDark,
    Color primaryColor,
    Color onPrimaryColor,
  ) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        if (states.contains(WidgetState.disabled)) {
          return isDark ? AppColors.darkSurface : AppColors.lightSurface;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryColor),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            width: AppConstants.borderMedium,
            color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextHint)
                .withValues(alpha: AppConstants.opacity50),
          );
        }
        return BorderSide(
          width: AppConstants.borderMedium,
          color: primaryColor,
        );
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return primaryColor.withValues(alpha: AppConstants.opacity10);
        }
        return null;
      }),
    );
  }

  // ===== Radio Theme =====
  
  static RadioThemeData _radioTheme(Color primaryColor, Color textSecondaryColor) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        if (states.contains(WidgetState.disabled)) {
          return textSecondaryColor.withValues(alpha: AppConstants.opacity50);
        }
        return textSecondaryColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
          return primaryColor.withValues(alpha: AppConstants.opacity10);
        }
        return null;
      }),
    );
  }
}