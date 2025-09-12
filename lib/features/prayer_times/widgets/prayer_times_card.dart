// lib/features/prayer_times/widgets/prayer_times_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/prayer_time_model.dart';

/// بطاقة وقت الصلاة المحسنة بدون زر الإشعارات
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
              color: _getPrayerColor().withValues(alpha: 0.2),
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
              gradient: useGradient ? _getGradient() : null,
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
                  // أيقونة الصلاة
                  _buildPrayerIcon(context, useGradient),
                  
                  ThemeConstants.space4.w,
                  
                  // معلومات الصلاة
                  Expanded(
                    child: _buildPrayerInfo(context, useGradient),
                  ),
                  
                  ThemeConstants.space3.w,
                  
                  // الوقت
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
    final iconColor = useGradient ? Colors.white : _getPrayerColor();
    final bgColor = useGradient 
      ? Colors.white.withValues(alpha: 0.2)
      : _getPrayerColor().withValues(alpha: 0.1);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: useGradient 
            ? Colors.white.withValues(alpha: 0.3)
            : _getPrayerColor().withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Icon(
        _getPrayerIcon(),
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
        // اسم الصلاة
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
        
        // حالة الصلاة
        _buildPrayerStatus(context, useGradient),
      ],
    );
  }

  Widget _buildPrayerStatus(BuildContext context, bool useGradient) {
    if (prayer.isNext) {
      return _buildNextPrayerStatus(context, useGradient);
    } else if (prayer.isPassed) {
      return _buildPassedPrayerStatus(context, useGradient);
    } else {
      return _buildUpcomingPrayerStatus(context, useGradient);
    }
  }

  Widget _buildNextPrayerStatus(BuildContext context, bool useGradient) {
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
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: Colors.white,
          ),
          ThemeConstants.space1.w,
          Text(
            prayer.remainingTimeText,
            style: context.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: ThemeConstants.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassedPrayerStatus(BuildContext context, bool useGradient) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: useGradient 
            ? Colors.white 
            : ThemeConstants.success,
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
  }

  Widget _buildUpcomingPrayerStatus(BuildContext context, bool useGradient) {
    return Text(
      "متبقي ${_formatTimeUntil(prayer.time)}",
      style: context.bodySmall?.copyWith(
        color: _getTextColor(context, useGradient).withValues(alpha: 0.8),
      ),
    );
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
          : _getPrayerColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: useGradient 
            ? Colors.white.withValues(alpha: 0.3)
            : _getPrayerColor().withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        _formatTime(prayer.time),
        style: context.titleLarge?.copyWith(
          color: useGradient ? Colors.white : _getPrayerColor(),
          fontWeight: ThemeConstants.bold,
        ),
      ),
    );
  }

  // Helper methods
  Color _getTextColor(BuildContext context, bool useGradient) {
    if (useGradient) return Colors.white;
    if (prayer.isPassed) return context.textSecondaryColor;
    return context.textPrimaryColor;
  }

  Color _getPrayerColor() {
    return ThemeConstants.getPrayerColor(prayer.type.name);
  }

  IconData _getPrayerIcon() {
    return ThemeConstants.getPrayerIcon(prayer.type.name);
  }

  LinearGradient _getGradient() {
    final baseColor = _getPrayerColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, baseColor.darken(0.2)],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  String _formatTimeUntil(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);
    
    if (diff.inHours > 0) {
      return '${diff.inHours}س ${diff.inMinutes % 60}د';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}د';
    } else {
      return 'الآن';
    }
  }

  void _showPrayerDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => PrayerDetailsDialog(prayer: prayer),
    );
  }
}

// ============================================================================
// Dialog تفاصيل الصلاة

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
          gradient: ThemeConstants.prayerGradient(prayer.type.name),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الحوار
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    ThemeConstants.getPrayerIcon(prayer.type.name),
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
            
            // معلومات الصلاة
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
                    value: _formatTime(prayer.time),
                  ),
                  
                  if (prayer.isNext) ...[
                    ThemeConstants.space2.h,
                    _buildDetailRow(
                      context,
                      icon: Icons.hourglass_empty,
                      label: 'الوقت المتبقي',
                      value: prayer.remainingTimeText,
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
                  
                  if (prayer.adhanTime != null) ...[
                    ThemeConstants.space2.h,
                    _buildDetailRow(
                      context,
                      icon: Icons.volume_up,
                      label: 'وقت الأذان',
                      value: _formatTime(prayer.adhanTime!),
                    ),
                  ],
                  
                  if (prayer.iqamaTime != null) ...[
                    ThemeConstants.space2.h,
                    _buildDetailRow(
                      context,
                      icon: Icons.groups,
                      label: 'وقت الإقامة',
                      value: _formatTime(prayer.iqamaTime!),
                    ),
                  ],
                ],
              ),
            ),
            
            ThemeConstants.space4.h,
            
            // أزرار الإجراءات
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

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}