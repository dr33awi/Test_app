// lib/app/themes/neumorphism_theme_constants.dart
import 'package:flutter/material.dart';

/// Neumorphism (Soft UI) Theme Constants
/// This file defines all colors, shadows, and styling for the Neumorphism design system
class ThemeConstants {
  ThemeConstants._();

  // ==================== Color Palette ====================
  
  // Primary Colors (Soft Green Palette)
  static const Color primary = Color(0xFF4A9B8E);           // Soft teal-green
  static const Color primaryLight = Color(0xFF6FB5A8);      // Lighter green
  static const Color primaryDark = Color(0xFF2F7A6B);       // Darker green
  static const Color primarySoft = Color(0xFFE8F5F3);       // Very light green for surfaces
  
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