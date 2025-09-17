// lib/features/prayer_times/widgets/shared/prayer_state_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/themes/app_theme.dart';
import '../../utils/prayer_utils.dart';

/// Widget موحد لحالة التحميل
class PrayerLoadingWidget extends StatelessWidget {
  final String? message;
  final bool isCompact;

  const PrayerLoadingWidget({
    super.key,
    this.message,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(ThemeConstants.space3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
            ),
            if (message != null) ...[
              ThemeConstants.space2.w,
              Text(
                message!,
                style: context.labelMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoading.circular(size: LoadingSize.large),
          if (message != null) ...[
            ThemeConstants.space4.h,
            Text(
              message!,
              style: context.bodyLarge?.copyWith(
                fontWeight: ThemeConstants.medium,
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

/// Widget موحد لحالة الخطأ
class PrayerErrorWidget extends StatelessWidget {
  final dynamic error;
  final String? customMessage;
  final VoidCallback? onRetry;
  final bool isCompact;
  final bool showSettings;

  const PrayerErrorWidget({
    super.key,
    required this.error,
    this.customMessage,
    this.onRetry,
    this.isCompact = false,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = customMessage ?? PrayerUtils.getErrorMessage(error);
    final errorType = PrayerUtils.getErrorType(error);
    
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(ThemeConstants.space3),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          border: Border.all(
            color: ThemeConstants.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getErrorIcon(errorType),
                  color: ThemeConstants.error,
                  size: ThemeConstants.iconMd,
                ),
                ThemeConstants.space2.w,
                Expanded(
                  child: Text(
                    errorMessage,
                    style: context.bodyMedium?.copyWith(
                      color: ThemeConstants.error,
                    ),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              ThemeConstants.space2.h,
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  text: 'إعادة المحاولة',
                  onPressed: onRetry!,
                  size: ButtonSize.small,
                  icon: Icons.refresh,
                  backgroundColor: ThemeConstants.error,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ThemeConstants.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(errorType),
                size: 40,
                color: ThemeConstants.error,
              ),
            ),
            
            ThemeConstants.space4.h,
            
            // العنوان
            Text(
              _getErrorTitle(errorType),
              style: context.titleLarge?.copyWith(
                color: ThemeConstants.error,
                fontWeight: ThemeConstants.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            ThemeConstants.space2.h,
            
            // الرسالة
            Text(
              errorMessage,
              style: context.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            ThemeConstants.space4.h,
            
            // الأزرار
            _buildActionButtons(context, errorType),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ErrorType errorType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onRetry != null)
          Expanded(
            child: AppButton.primary(
              text: 'إعادة المحاولة',
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry!();
              },
              icon: Icons.refresh,
              backgroundColor: ThemeConstants.primary,
            ),
          ),
        
        if (showSettings && (errorType == ErrorType.permission || errorType == ErrorType.locationService)) ...[
          if (onRetry != null) ThemeConstants.space3.w,
          Expanded(
            child: AppButton.outline(
              text: 'الإعدادات',
              onPressed: () {
                HapticFeedback.lightImpact();
                _openSettings(context, errorType);
              },
              icon: Icons.settings,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.permission:
        return Icons.lock_outline;
      case ErrorType.locationService:
        return Icons.location_off;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.hourglass_empty;
      case ErrorType.location:
        return Icons.location_searching;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.permission:
        return 'صلاحية مطلوبة';
      case ErrorType.locationService:
        return 'خدمة الموقع معطلة';
      case ErrorType.network:
        return 'لا يوجد اتصال';
      case ErrorType.timeout:
        return 'انتهت المهلة';
      case ErrorType.location:
        return 'خطأ في الموقع';
      case ErrorType.unknown:
        return 'حدث خطأ';
    }
  }

  void _openSettings(BuildContext context, ErrorType type) {
    if (type == ErrorType.permission) {
      context.showInfoSnackBar('يرجى الذهاب لإعدادات التطبيق وتفعيل صلاحية الموقع');
    } else if (type == ErrorType.locationService) {
      context.showInfoSnackBar('يرجى تفعيل خدمة الموقع من إعدادات الجهاز');
    }
  }
}

/// Widget موحد لحالة عدم وجود بيانات
class PrayerEmptyWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const PrayerEmptyWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            
            ThemeConstants.space4.h,
            
            Text(
              title ?? 'لا توجد بيانات',
              style: context.titleLarge?.copyWith(
                fontWeight: ThemeConstants.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (message != null) ...[
              ThemeConstants.space2.h,
              Text(
                message!,
                style: context.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (onAction != null && actionText != null) ...[
              ThemeConstants.space4.h,
              AppButton.primary(
                text: actionText!,
                onPressed: onAction!,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget لإعادة المحاولة
class RetryButton extends StatefulWidget {
  final VoidCallback onRetry;
  final String text;
  final bool isLoading;

  const RetryButton({
    super.key,
    required this.onRetry,
    this.text = 'إعادة المحاولة',
    this.isLoading = false,
  });

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() => _isRetrying = true);
    HapticFeedback.lightImpact();
    
    try {
      widget.onRetry();
      // انتظار قليلاً للسماح للـ callback بالبدء
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading || _isRetrying;
    
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _handleRetry,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh, size: 20),
      label: Text(isLoading ? 'جاري المحاولة...' : widget.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space4,
          vertical: ThemeConstants.space3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }
}