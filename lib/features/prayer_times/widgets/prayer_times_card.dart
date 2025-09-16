// lib/features/prayer_times/widgets/prayer_times_card_updated.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/prayer_time_model.dart'; // استخدام النموذج الأصلي
import '../utils/prayer_utils.dart';

/// بطاقة وقت الصلاة المحدثة
class PrayerTimeCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool forceColored;

  const PrayerTimeCard({
    super.key,
    required this.prayer,
    this.forceColored = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = prayer.isNext;
    final isPassed = prayer.isPassed;
    final useGradient = forceColored || isNext;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        boxShadow: [
          if (isNext)
            BoxShadow(
              color: prayer.color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showPrayerDetails(context),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Container(
            decoration: BoxDecoration(
              gradient: useGradient ? prayer.gradient : null,
              color: !useGradient 
                ? (isPassed 
                    ? context.cardColor.darken(0.02) 
                    : context.cardColor) 
                : null,
              border: Border.all(
                color: useGradient 
                  ? Colors.white.withValues(alpha: 0.2)
                  : context.dividerColor.withValues(alpha: 0.2),
                width: isNext ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              child: Row(
                children: [
                  _buildPrayerIcon(context, useGradient),
                  ThemeConstants.space4.w,
                  Expanded(
                    child: _buildPrayerInfo(context, useGradient),
                  ),
                  ThemeConstants.space3.w,
                  _buildTimeSection(context, useGradient),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerIcon(BuildContext context, bool useGradient) {
    final iconColor = useGradient ? Colors.white : prayer.color;
    final bgColor = useGradient 
      ? Colors.white.withValues(alpha: 0.2)
      : prayer.color.withValues(alpha: 0.1);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: useGradient 
            ? Colors.white.withValues(alpha: 0.3)
            : prayer.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Icon(
        prayer.icon,
        color: iconColor,
        size: 28,
      ),
    );
  }

  Widget _buildPrayerInfo(BuildContext context, bool useGradient) {
    final textColor = _getTextColor(context, useGradient);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prayer.nameAr,
          style: context.titleLarge?.copyWith(
            color: textColor,
            fontWeight: prayer.isNext 
              ? ThemeConstants.bold 
              : ThemeConstants.semiBold,
          ),
        ),
        ThemeConstants.space1.h,
        _buildPrayerStatus(context, useGradient),
      ],
    );
  }

  Widget _buildPrayerStatus(BuildContext context, bool useGradient) {
    if (prayer.isNext) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space2,
          vertical: ThemeConstants.space1,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: Colors.white,
            ),
            ThemeConstants.space1.w,
            Text(
              prayer.statusText,
              style: context.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.semiBold,
              ),
            ),
          ],
        ),
      );
    } else if (prayer.isPassed) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: useGradient ? Colors.white : ThemeConstants.success,
          ),
          ThemeConstants.space1.w,
          Text(
            'انتهى الوقت',
            style: context.bodySmall?.copyWith(
              color: useGradient 
                ? Colors.white.withValues(alpha: 0.8)
                : context.textSecondaryColor,
              fontWeight: ThemeConstants.medium,
            ),
          ),
        ],
      );
    } else {
      return Text(
        PrayerUtils.formatTimeUntil(prayer.time),
        style: context.bodySmall?.copyWith(
          color: _getTextColor(context, useGradient).withValues(alpha: 0.8),
        ),
      );
    }
  }

  Widget _buildTimeSection(BuildContext context, bool useGradient) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.space3,
        vertical: ThemeConstants.space2,
      ),
      decoration: BoxDecoration(
        color: useGradient 
          ? Colors.white.withValues(alpha: 0.2)
          : prayer.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: useGradient 
            ? Colors.white.withValues(alpha: 0.3)
            : prayer.color.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        prayer.formattedTime,
        style: context.titleLarge?.copyWith(
          color: useGradient ? Colors.white : prayer.color,
          fontWeight: ThemeConstants.bold,
        ),
      ),
    );
  }

  Color _getTextColor(BuildContext context, bool useGradient) {
    if (useGradient) return Colors.white;
    if (prayer.isPassed) return context.textSecondaryColor;
    return context.textPrimaryColor;
  }

  void _showPrayerDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => PrayerDetailsDialog(prayer: prayer),
    );
  }
}

/// Dialog تفاصيل الصلاة المحدث
class PrayerDetailsDialog extends StatelessWidget {
  final PrayerTime prayer;

  const PrayerDetailsDialog({
    super.key,
    required this.prayer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          gradient: prayer.gradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    prayer.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.nameAr,
                        style: context.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                      Text(
                        prayer.nameEn,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            ThemeConstants.space4.h,
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeConstants.space4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'وقت الصلاة',
                    value: prayer.formattedTime,
                  ),
                  
                  if (prayer.isNext) ...[
                    ThemeConstants.space2.h,
                    _buildDetailRow(
                      context,
                      icon: Icons.hourglass_empty,
                      label: 'الوقت المتبقي',
                      value: prayer.statusText,
                    ),
                  ],
                  
                  if (prayer.isPassed) ...[
                    ThemeConstants.space2.h,
                    _buildDetailRow(
                      context,
                      icon: Icons.check_circle,
                      label: 'الحالة',
                      value: 'انتهى الوقت',
                    ),
                  ],
                ],
              ),
            ),
            
            ThemeConstants.space4.h,
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space3),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/prayer-settings');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                      ),
                    ),
                    child: const Text('الإعدادات'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        ThemeConstants.space2.w,
        Text(
          label,
          style: context.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: context.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: ThemeConstants.semiBold,
          ),
        ),
      ],
    );
  }
}