// lib/features/athkar/utils/athkar_extensions.dart (منظف من التكرار)
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// امتدادات مساعدة خاصة بالأذكار فقط
extension AthkarHelpers on BuildContext {
  /// عرض رسالة معلومات خاصة بالأذكار
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
  
  /// عرض رسالة نجاح خاصة بالأذكار
  void showAthkarSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
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
        backgroundColor: ThemeConstants.success,
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

/// مساعد لحوارات التأكيد الخاصة بالأذكار
class AthkarConfirmDialog {
  static Future<bool?> show({
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
