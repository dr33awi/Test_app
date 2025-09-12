// lib/features/athkar/utils/athkar_extensions.dart (محسن)
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

// lib/features/athkar/utils/athkar_extensions.dart (محسن بدون تضارب)
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// امتدادات مساعدة للأذكار (بدون تضارب مع app_snackbar.dart)
extension AthkarHelpers on BuildContext {
  /// عرض رسالة معلومات (اسم مختلف لتجنب التضارب)
  void showAthkarInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: ThemeConstants.iconSm,
            ),
            ThemeConstants.space2.w,
            Expanded(
              child: Text(
                message,
                style: bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeConstants.info,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(ThemeConstants.space4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// مساعد لحوارات التأكيد
class AppInfoDialog {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required IconData icon,
    bool destructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              icon,
              color: destructive ? ThemeConstants.error : ThemeConstants.primary,
              size: ThemeConstants.iconMd,
            ),
            ThemeConstants.space3.w,
            Expanded(
              child: Text(
                title,
                style: context.titleMedium?.copyWith(
                  fontWeight: ThemeConstants.semiBold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: context.bodyMedium?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive ? ThemeConstants.error : ThemeConstants.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/// مساعد لحالات التحميل والفراغ
class AppLoading {
  static Widget page({String? message}) {
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            ThemeConstants.space4.h,
            Text(
              message,
              style: context.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AppEmptyState {
  static Widget error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: ThemeConstants.error.withValues(alpha: 0.7),
          ),
          ThemeConstants.space4.h,
          Text(
            message,
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            ThemeConstants.space4.h,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }

  static Widget noData({
    required String message,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
          ThemeConstants.space4.h,
          Text(
            message,
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// مساعد للأزرار
class AppButton {
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? backgroundColor,
  }) {
    return Builder(
      builder: (context) => ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ThemeConstants.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
        ),
      ),
    );
  }

  static Widget outline({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? color,
  }) {
    return Builder(
      builder: (context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? ThemeConstants.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(
            color: color ?? ThemeConstants.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
        ),
      ),
    );
  }

  static Widget text({
    required String text,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 48),
      ),
      child: Text(text),
    );
  }

  static Widget custom({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }
}

/// مساعد للبطاقات
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final CardStyle style;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.style = CardStyle.filled,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: style == CardStyle.filled 
            ? context.cardColor 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: style == CardStyle.outlined
            ? Border.all(
                color: context.dividerColor,
                width: 1,
              )
            : null,
        boxShadow: style == CardStyle.elevated && (elevation ?? 0) > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation ?? 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

enum CardStyle { filled, outlined, elevated }

/// مساعد لزر الرجوع (النمط القديم البسيط)
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
    );
  }
}