// lib/app/themes/app_theme.dart - محدث مع دعم Neumorphic
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Neumorphism Theme Constants - محدث ليحل محل ThemeConstants الموجود
class ThemeConstants {
  ThemeConstants._();

  // ==================== Color Palette ====================
  
  // Primary Colors (Soft Green Palette)
  static const Color primary = Color(0xFF4A9B8E);           // Soft teal-green
  static const Color primaryLight = Color(0xFF6FB5A8);      // Lighter green
  static const Color primaryDark = Color(0xFF2F7A6B);       // Darker green
  static const Color primarySoft = Color(0xFFE8F5F3);       // Very light green for surfaces
  
  // Accent Colors
  static const Color accent = Color(0xFF7B68EE);             // Soft purple
  static const Color accentLight = Color(0xFF9B8CE8);       // Light purple
  static const Color accentDark = Color(0xFF553C9A);        // Dark purple
  
  // Tertiary Colors
  static const Color tertiary = Color(0xFF8B5CF6);          // Violet
  static const Color tertiaryLight = Color(0xFFA78BFA);     // Light violet
  static const Color tertiaryDark = Color(0xFF7C3AED);      // Dark violet
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF0F2F5);    // Soft off-white
  static const Color darkBackground = Color(0xFF1C1E22);     // Dark mode background
  static const Color cardBackground = Color(0xFFFAFBFC);     // Card background
  static const Color darkCardBackground = Color(0xFF252832); // Dark mode card
  
  // Surface Colors
  static const Color lightSurface = Color(0xFFFFFFFF);       // Pure white
  static const Color darkSurface = Color(0xFF2A2D35);        // Dark surface
  static const Color elevatedSurface = Color(0xFFF8F9FA);    // Slightly elevated
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);        // Dark text
  static const Color textSecondary = Color(0xFF718096);      // Secondary text
  static const Color textHint = Color(0xFFA0AEC0);          // Hint text
  static const Color textOnPrimary = Color(0xFFFFFFFF);      // White text on primary
  
  // Status Colors
  static const Color success = Color(0xFF38A169);            // Success green
  static const Color warning = Color(0xFFD69E2E);           // Warning amber
  static const Color error = Color(0xFFE53E3E);             // Error red
  static const Color info = Color(0xFF3182CE);              // Info blue
  
  // ==================== Shadows ====================
  
  // Light Mode Shadows
  static const List<BoxShadow> lightElevated = [
    BoxShadow(
      color: Color(0x0D000000),                             // 5% black
      offset: Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF),                             // Pure white
      offset: Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> lightPressed = [
    BoxShadow(
      color: Color(0x1A000000),                             // 10% black - inset effect
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];
  
  static const List<BoxShadow> lightFloating = [
    BoxShadow(
      color: Color(0x14000000),                             // 8% black
      offset: Offset(4, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF),                             // Pure white
      offset: Offset(-4, -4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Dark Mode Shadows
  static const List<BoxShadow> darkElevated = [
    BoxShadow(
      color: Color(0x33000000),                             // 20% black
      offset: Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),                             // 5% white
      offset: Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> darkPressed = [
    BoxShadow(
      color: Color(0x4D000000),                             // 30% black - inset effect
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];
  
  static const List<BoxShadow> darkFloating = [
    BoxShadow(
      color: Color(0x40000000),                             // 25% black
      offset: Offset(4, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1AFFFFFF),                             // 10% white
      offset: Offset(-4, -4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // ==================== Border Radius ====================
  
  static const double radiusXs = 4.0;                       // Extra small radius
  static const double radiusSm = 8.0;                       // Small radius
  static const double radiusMd = 12.0;                      // Medium radius
  static const double radiusLg = 16.0;                      // Large radius
  static const double radiusXl = 20.0;                      // Extra large radius
  static const double radius2xl = 24.0;                     // 2X large radius
  static const double radius3xl = 32.0;                     // 3X large radius
  static const double radiusFull = 9999.0;                  // Full radius (circle)
  
  // ==================== Spacing ====================
  
  static const double space1 = 4.0;                         // 4px
  static const double space2 = 8.0;                         // 8px
  static const double space3 = 12.0;                        // 12px
  static const double space4 = 16.0;                        // 16px
  static const double space5 = 20.0;                        // 20px
  static const double space6 = 24.0;                        // 24px
  static const double space7 = 28.0;                        // 28px
  static const double space8 = 32.0;                        // 32px
  static const double space10 = 40.0;                       // 40px
  static const double space12 = 48.0;                       // 48px
  static const double space16 = 64.0;                       // 64px
  
  // ==================== Typography ====================
  
  static const String fontFamily = 'Cairo';                 // Primary font
  static const String fontFamilySecondary = 'Tajawal';      // Secondary font
  static const String fontFamilyQuran = 'Amiri';            // Quran/Arabic text
  static const String fontFamilyArabic = 'Cairo';           // Arabic text
  
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  // Font Sizes
  static const double fontXs = 12.0;                        // Extra small
  static const double fontSm = 14.0;                        // Small
  static const double fontBase = 16.0;                      // Base size
  static const double fontLg = 18.0;                        // Large
  static const double fontXl = 20.0;                        // Extra large
  static const double font2xl = 24.0;                       // 2X large
  static const double font3xl = 30.0;                       // 3X large
  static const double font4xl = 36.0;                       // 4X large
  
  // ==================== Icons ====================
  
  static const double iconXs = 16.0;                        // Extra small icon
  static const double iconSm = 20.0;                        // Small icon
  static const double iconMd = 24.0;                        // Medium icon
  static const double iconLg = 32.0;                        // Large icon
  static const double iconXl = 40.0;                        // Extra large icon
  static const double icon2xl = 48.0;                       // 2X large icon
  
  // ==================== Animation ====================
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationSlowest = Duration(milliseconds: 600);
  
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerated = Curves.easeOut;
  static const Curve curveAccelerated = Curves.easeIn;
  
  // ==================== Gradients ====================
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [lightSurface, elevatedSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ==================== Helper Methods ====================
  
  /// Get shadows based on theme mode and elevation type
  static List<BoxShadow> getShadows({
    required bool isDark,
    ShadowType type = ShadowType.elevated,
  }) {
    switch (type) {
      case ShadowType.elevated:
        return isDark ? darkElevated : lightElevated;
      case ShadowType.pressed:
        return isDark ? darkPressed : lightPressed;
      case ShadowType.floating:
        return isDark ? darkFloating : lightFloating;
    }
  }
  
  /// Get background color based on theme mode
  static Color getBackgroundColor(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }
  
  /// Get surface color based on theme mode
  static Color getSurfaceColor(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }
  
  /// Get card background color based on theme mode
  static Color getCardColor(bool isDark) {
    return isDark ? darkCardBackground : cardBackground;
  }
  
  /// Get text color based on theme mode
  static Color getTextColor(bool isDark, {bool isSecondary = false}) {
    if (isDark) {
      return isSecondary ? const Color(0xFFA0AEC0) : const Color(0xFFFFFFFF);
    } else {
      return isSecondary ? textSecondary : textPrimary;
    }
  }
  
  /// Create a neumorphic container decoration
  static BoxDecoration neumorphicDecoration({
    required bool isDark,
    ShadowType shadowType = ShadowType.elevated,
    double borderRadius = radiusMd,
    Color? backgroundColor,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? (isDark ? darkCardBackground : cardBackground),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isPressed 
          ? getShadows(isDark: isDark, type: ShadowType.pressed)
          : getShadows(isDark: isDark, type: shadowType),
    );
  }
  
  /// Create a neumorphic border
  static Border? neumorphicBorder(bool isDark) {
    return Border.all(
      color: isDark 
          ? const Color(0x1AFFFFFF) 
          : const Color(0x1A000000),
      width: 0.5,
    );
  }
}

/// Shadow types for neumorphic design
enum ShadowType {
  elevated,   // Normal elevation shadow
  pressed,    // Pressed/inset shadow
  floating,   // High elevation shadow
}

/// AppTheme - محدث مع دعم Neumorphic
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Basic Theme Configuration
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConstants.primary,
        brightness: Brightness.light,
        primary: ThemeConstants.primary,
        secondary: ThemeConstants.accent,
        tertiary: ThemeConstants.success,
        surface: ThemeConstants.lightSurface,
        background: ThemeConstants.lightBackground,
        error: ThemeConstants.error,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: ThemeConstants.lightBackground,
      
      // Card Theme
      cardTheme: CardTheme(
        color: ThemeConstants.cardBackground,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.lightBackground,
        foregroundColor: ThemeConstants.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontLg,
          fontWeight: ThemeConstants.bold,
          color: ThemeConstants.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font4xl,
          fontWeight: ThemeConstants.extraBold,
          color: ThemeConstants.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font3xl,
          fontWeight: ThemeConstants.bold,
          color: ThemeConstants.textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font2xl,
          fontWeight: ThemeConstants.bold,
          color: ThemeConstants.textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXl,
          fontWeight: ThemeConstants.bold,
          color: ThemeConstants.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontLg,
          fontWeight: ThemeConstants.semiBold,
          color: ThemeConstants.textPrimary,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontBase,
          fontWeight: ThemeConstants.medium,
          color: ThemeConstants.textPrimary,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontBase,
          fontWeight: ThemeConstants.regular,
          color: ThemeConstants.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontSm,
          fontWeight: ThemeConstants.regular,
          color: ThemeConstants.textPrimary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXs,
          fontWeight: ThemeConstants.regular,
          color: ThemeConstants.textSecondary,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontSm,
          fontWeight: ThemeConstants.medium,
          color: ThemeConstants.textSecondary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXs,
          fontWeight: ThemeConstants.medium,
          color: ThemeConstants.textSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: 11,
          fontWeight: ThemeConstants.medium,
          color: ThemeConstants.textSecondary,
          height: 1.4,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space3,
          ),
          textStyle: const TextStyle(
            fontFamily: ThemeConstants.fontFamily,
            fontSize: ThemeConstants.fontBase,
            fontWeight: ThemeConstants.semiBold,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.elevatedSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: ThemeConstants.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space4,
          vertical: ThemeConstants.space3,
        ),
        hintStyle: const TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          color: ThemeConstants.textHint,
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConstants.primary,
        brightness: Brightness.dark,
        primary: ThemeConstants.primary,
        secondary: ThemeConstants.accent,
        tertiary: ThemeConstants.success,
        surface: ThemeConstants.darkSurface,
        background: ThemeConstants.darkBackground,
        error: ThemeConstants.error,
      ),
      
      scaffoldBackgroundColor: ThemeConstants.darkBackground,
      
      cardTheme: CardTheme(
        color: ThemeConstants.darkCardBackground,
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontLg,
          fontWeight: ThemeConstants.bold,
          color: Colors.white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font4xl,
          fontWeight: ThemeConstants.extraBold,
          color: Colors.white,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font3xl,
          fontWeight: ThemeConstants.bold,
          color: Colors.white,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.font2xl,
          fontWeight: ThemeConstants.bold,
          color: Colors.white,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXl,
          fontWeight: ThemeConstants.bold,
          color: Colors.white,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontLg,
          fontWeight: ThemeConstants.semiBold,
          color: Colors.white,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontBase,
          fontWeight: ThemeConstants.medium,
          color: Colors.white,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontBase,
          fontWeight: ThemeConstants.regular,
          color: Colors.white,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontSm,
          fontWeight: ThemeConstants.regular,
          color: Colors.white,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXs,
          fontWeight: ThemeConstants.regular,
          color: Color(0xFFA0AEC0),
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontSm,
          fontWeight: ThemeConstants.medium,
          color: Color(0xFFA0AEC0),
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: ThemeConstants.fontXs,
          fontWeight: ThemeConstants.medium,
          color: Color(0xFFA0AEC0),
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          fontSize: 11,
          fontWeight: ThemeConstants.medium,
          color: Color(0xFFA0AEC0),
          height: 1.4,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space3,
          ),
          textStyle: const TextStyle(
            fontFamily: ThemeConstants.fontFamily,
            fontSize: ThemeConstants.fontBase,
            fontWeight: ThemeConstants.semiBold,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: ThemeConstants.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space4,
          vertical: ThemeConstants.space3,
        ),
        hintStyle: const TextStyle(
          fontFamily: ThemeConstants.fontFamily,
          color: Color(0xFFA0AEC0),
        ),
      ),
    );
  }
}

/// Helper extensions for snackbar support
extension BuildContextExtensions on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }
  
  void showWarningSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }
  
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }
}