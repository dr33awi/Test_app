// lib/app/themes/widgets/neumorphic_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme_constants.dart';

/// Extension methods for easy theme access
extension NeumorphicContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  // Colors
  Color get backgroundColor => ThemeConstants.getBackgroundColor(isDarkMode);
  Color get surfaceColor => ThemeConstants.getSurfaceColor(isDarkMode);
  Color get cardColor => ThemeConstants.getCardColor(isDarkMode);
  Color get textPrimaryColor => ThemeConstants.getTextColor(isDarkMode);
  Color get textSecondaryColor => ThemeConstants.getTextColor(isDarkMode, isSecondary: true);

  // Typography
  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
  );
  
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
  );
  
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
    fontWeight: ThemeConstants.bold,
  );
  
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
    fontWeight: ThemeConstants.semiBold,
  );
  
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
    fontWeight: ThemeConstants.medium,
  );
  
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
  );
  
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textPrimaryColor,
  );
  
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textSecondaryColor,
  );
  
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textSecondaryColor,
    fontWeight: ThemeConstants.medium,
  );
  
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textSecondaryColor,
  );
  
  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall?.copyWith(
    fontFamily: ThemeConstants.fontFamily,
    color: textSecondaryColor,
  );
}

/// Neumorphic Card Widget
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final ShadowType shadowType;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  
  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = ThemeConstants.radiusMd,
    this.shadowType = ShadowType.elevated,
    this.backgroundColor,
    this.onTap,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    final decoration = ThemeConstants.neumorphicDecoration(
      isDark: context.isDarkMode,
      shadowType: shadowType,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
    );
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
    
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }
    
    return content;
  }
}

/// Neumorphic Button Widget
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final bool enabled;
  
  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.margin,
    this.borderRadius = ThemeConstants.radiusMd,
    this.backgroundColor,
    this.width,
    this.height,
    this.enabled = true,
  });
  
  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ThemeConstants.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ThemeConstants.curveDefault,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    _resetButton();
  }
  
  void _handleTapCancel() {
    _resetButton();
  }
  
  void _resetButton() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final decoration = ThemeConstants.neumorphicDecoration(
      isDark: context.isDarkMode,
      shadowType: _isPressed ? ShadowType.pressed : ShadowType.elevated,
      borderRadius: widget.borderRadius,
      backgroundColor: widget.backgroundColor,
      isPressed: _isPressed,
    );
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.enabled ? widget.onPressed : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              decoration: decoration.copyWith(
                color: widget.enabled 
                    ? decoration.color 
                    : decoration.color?.withOpacity(0.5),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Neumorphic Icon Button
class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  
  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = ThemeConstants.iconMd,
    this.color,
    this.backgroundColor,
    this.borderRadius = ThemeConstants.radiusMd,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      padding: padding ?? const EdgeInsets.all(ThemeConstants.space3),
      child: Icon(
        icon,
        size: size,
        color: color ?? context.textPrimaryColor,
      ),
    );
  }
}

/// Neumorphic Container with gradient
class NeumorphicGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  
  const NeumorphicGradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius = ThemeConstants.radiusMd,
    this.onTap,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: ThemeConstants.getShadows(
          isDark: context.isDarkMode,
          type: ShadowType.elevated,
        ),
      ),
      child: child,
    );
    
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }
    
    return content;
  }
}

/// Neumorphic Progress Indicator
class NeumorphicProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final double borderRadius;
  
  const NeumorphicProgress({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius = ThemeConstants.radiusSm,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: ThemeConstants.neumorphicDecoration(
        isDark: context.isDarkMode,
        shadowType: ShadowType.pressed,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? ThemeConstants.primary,
          ),
        ),
      ),
    );
  }
}

/// Neumorphic Divider
class NeumorphicDivider extends StatelessWidget {
  final double height;
  final double indent;
  final double endIndent;
  
  const NeumorphicDivider({
    super.key,
    this.height = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? const Color(0x1AFFFFFF) 
            : const Color(0x1A000000),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? const Color(0x0DFFFFFF)
                : const Color(0xFFFFFFFF),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Neumorphic Text Field
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  
  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ThemeConstants.neumorphicDecoration(
        isDark: context.isDarkMode,
        shadowType: ShadowType.pressed,
        borderRadius: ThemeConstants.radiusMd,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        style: context.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: context.bodyMedium?.copyWith(
            color: context.textSecondaryColor,
          ),
          prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon,
                  color: context.textSecondaryColor,
                  size: ThemeConstants.iconSm,
                ) 
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    color: context.textSecondaryColor,
                    size: ThemeConstants.iconSm,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space3,
          ),
        ),
      ),
    );
  }
}

/// Helper extension for TextStyle
extension NeumorphicTextStyle on TextStyle {
  TextStyle get bold => copyWith(fontWeight: ThemeConstants.bold);
  TextStyle get semiBold => copyWith(fontWeight: ThemeConstants.semiBold);
  TextStyle get medium => copyWith(fontWeight: ThemeConstants.medium);
  TextStyle get light => copyWith(fontWeight: ThemeConstants.light);
}

/// Helper extension for sizes
extension NeumorphicSizes on double {
  Widget get h => SizedBox(height: this);
  Widget get w => SizedBox(width: this);
}