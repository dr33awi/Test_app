// lib/features/athkar/utils/athkar_extensions.dart (نظيف من التكرار)
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// امتدادات خاصة بميزة الأذكار فقط
/// تستخدم بجانب الـ extensions العامة من app_theme.dart
extension AthkarSpecificHelpers on BuildContext {
  
  /// عرض رسالة معلومات خاصة بالأذكار
  /// تستخدم للرسائل الإعلامية مثل "تم إعادة تعيين العداد"
  void showAthkarInfoSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
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
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// عرض رسالة تقدم الأذكار
  /// تستخدم عند إكمال ذكر أو مجموعة أذكار
  void showAthkarProgressSnackBar({
    required String message,
    required int progress,
    Color? progressColor,
  }) {
    final color = progressColor ?? ThemeConstants.primary;
    
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // دائرة تقدم صغيرة
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            ThemeConstants.space3.w,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: ThemeConstants.medium,
                    ),
                  ),
                  Text(
                    'التقدم: $progress%',
                    style: labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(ThemeConstants.space4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// عرض رسالة إكمال الأذكار مع أنيميشن
  void showAthkarCompletionSnackBar({
    required String categoryName,
    VoidCallback? onShare,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // أيقونة متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(ThemeConstants.space1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                );
              },
            ),
            ThemeConstants.space3.w,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أحسنت! أكملت $categoryName',
                    style: bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: ThemeConstants.semiBold,
                    ),
                  ),
                  Text(
                    'جعله الله في ميزان حسناتك',
                    style: labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (onShare != null)
              TextButton(
                onPressed: onShare,
                child: Text(
                  'مشاركة',
                  style: labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
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
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// امتدادات خاصة بنصوص الأذكار
extension AthkarTextExtensions on String {
  /// تقصير النص مع إضافة نقاط في النهاية
  String truncateAthkar(int maxLength) {
    if (length <= maxLength) return this;
    
    // البحث عن آخر مسافة قبل الحد الأقصى
    final lastSpace = lastIndexOf(' ', maxLength);
    final cutIndex = lastSpace > 0 ? lastSpace : maxLength;
    
    return '${substring(0, cutIndex)}...';
  }
  
  /// إزالة التشكيل من النص (للبحث)
  String removeArabicDiacritics() {
    return replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }
  
  /// التحقق من أن النص عربي
  bool get isArabicText {
    return contains(RegExp(r'[\u0600-\u06FF]'));
  }
}