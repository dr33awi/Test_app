// lib/features/statistics/widgets/goal_progress_card.dart

import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../models/statistics_models.dart';

class GoalProgressCard extends StatelessWidget {
  final StatisticsGoal goal;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final isCompleted = goal.isCompleted;
    final isExpired = goal.isExpired;
    
    Color statusColor;
    IconData statusIcon;
    
    if (isCompleted) {
      statusColor = ThemeConstants.success;
      statusIcon = Icons.check_circle;
    } else if (isExpired) {
      statusColor = ThemeConstants.error;
      statusIcon = Icons.cancel;
    } else {
      statusColor = ThemeConstants.primary;
      statusIcon = Icons.flag;
    }
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرأس
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                  
                  ThemeConstants.space3.w,
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: context.titleMedium?.copyWith(
                            fontWeight: ThemeConstants.semiBold,
                          ),
                        ),
                        Text(
                          goal.description,
                          style: context.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // النقاط
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space2,
                      vertical: ThemeConstants.space1,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: ThemeConstants.warning,
                        ),
                        ThemeConstants.space1.w,
                        Text(
                          '${goal.rewardPoints}',
                          style: context.labelSmall?.copyWith(
                            color: ThemeConstants.warning,
                            fontWeight: ThemeConstants.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              ThemeConstants.space4.h,
              
              // شريط التقدم
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${goal.currentValue} / ${goal.targetValue}',
                        style: context.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: ThemeConstants.medium,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: context.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  ThemeConstants.space2.h,
                  
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ],
              ),
              
              ThemeConstants.space3.h,
              
              // التاريخ والنوع
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space2,
                      vertical: ThemeConstants.space1,
                    ),
                    decoration: BoxDecoration(
                      color: context.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: context.textSecondaryColor,
                        ),
                        ThemeConstants.space1.w,
                        Text(
                          goal.type.title,
                          style: context.labelSmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  ThemeConstants.space2.w,
                  
                  if (!isCompleted && !isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space2,
                        vertical: ThemeConstants.space1,
                      ),
                      decoration: BoxDecoration(
                        color: context.dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: context.textSecondaryColor,
                          ),
                          ThemeConstants.space1.w,
                          Text(
                            _getTimeRemaining(goal.deadline),
                            style: context.labelSmall?.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // حالة الهدف
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space2,
                        vertical: ThemeConstants.space1,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 12,
                            color: ThemeConstants.success,
                          ),
                          ThemeConstants.space1.w,
                          Text(
                            'مكتمل',
                            style: context.labelSmall?.copyWith(
                              color: ThemeConstants.success,
                              fontWeight: ThemeConstants.semiBold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space2,
                        vertical: ThemeConstants.space1,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 12,
                            color: ThemeConstants.error,
                          ),
                          ThemeConstants.space1.w,
                          Text(
                            'منتهي',
                            style: context.labelSmall?.copyWith(
                              color: ThemeConstants.error,
                              fontWeight: ThemeConstants.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'قريباً';
    }
  }
}