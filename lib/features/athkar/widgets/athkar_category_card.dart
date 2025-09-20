// lib/features/athkar/widgets/athkar_category_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/athkar_model.dart';
import '../utils/category_utils.dart';

class AthkarCategoryCard extends StatelessWidget {
  final AthkarCategory category;
  final VoidCallback onTap;

  const AthkarCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryUtils.getCategoryThemeColor(category.id);
    final categoryIcon = CategoryUtils.getCategoryIcon(category.id);
    final description = CategoryUtils.getCategoryDescription(category.id);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          gradient: CategoryUtils.getCategoryGradient(category.id),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // نمط خلفية بسيط
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            
            // المحتوى الرئيسي
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الأيقونة
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: Colors.white,
                      size: ThemeConstants.iconLg,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // معلومات الفئة
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      ThemeConstants.space1.h,
                      
                      Text(
                        description,
                        style: context.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  
                  ThemeConstants.space3.h,
                  
                  // معلومات إضافية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // عدد الأذكار
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.space2,
                          vertical: ThemeConstants.space1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.format_list_numbered_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: ThemeConstants.iconXs,
                            ),
                            ThemeConstants.space1.w,
                            Text(
                              '${category.athkar.length} ذكر',
                              style: context.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: ThemeConstants.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // وقت التنبيه (إذا كان متوفر ومطلوب عرضه)
                      if (category.notifyTime != null && CategoryUtils.shouldShowTime(category.id))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space2,
                            vertical: ThemeConstants.space1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: ThemeConstants.iconXs,
                              ),
                              ThemeConstants.space1.w,
                              Text(
                                category.notifyTime!.format(context),
                                style: context.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: ThemeConstants.medium,
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
          ],
        ),
      ),
    );
  }
}