// lib/features/athkar/utils/athkar_extensions.dart (منظف من التكرار)
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// امتدادات مساعدة خاصة بالأذكار فقط
/// تستخدم الـ extensions العامة من app_theme.dart
extension AthkarSpecificHelpers on BuildContext {
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
  
  /// عرض رسالة نجاح خاصة بالأذكار مع أيقونة مخصصة
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