// lib/features/statistics/widgets/achievement_card.dart

import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../models/statistics_models.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      _getCategoryColor(achievement.category),
                      _getCategoryColor(achievement.category).lighten(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isUnlocked ? context.cardColor : null,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: isUnlocked
                  ? Colors.white.withValues(alpha: 0.3)
                  : context.dividerColor.withValues(alpha: 0.3),
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: _getCategoryColor(achievement.category).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الأيقونة أو الصورة
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.white.withValues(alpha: 0.2)
                        : context.dividerColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getAchievementIcon(achievement),
                      size: 32,
                      color: isUnlocked
                          ? Colors.white
                          : context.textSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                
                ThemeConstants.space3.h,
                
                // العنوان
                Text(
                  achievement.title,
                  style: context.titleSmall?.copyWith(
                    color: isUnlocked
                        ? Colors.white
                        : context.textPrimaryColor,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                ThemeConstants.space1.h,
                
                // الوصف
                Text(
                  achievement.description,
                  style: context.labelSmall?.copyWith(
                    color: isUnlocked
                        ? Colors.white.withValues(alpha: 0.8)
                        : context.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (isUnlocked && achievement.unlockedAt != null) ...[
                  ThemeConstants.space2.h,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space2,
                      vertical: ThemeConstants.space1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    ),
                    child: Text(
                      _formatDate(achievement.unlockedAt!),
                      style: context.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                
                // القفل للإنجازات غير المفتوحة
                if (!isUnlocked) ...[
                  ThemeConstants.space2.h,
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.athkar:
        return ThemeConstants.primary;
      case AchievementCategory.tasbih:
        return ThemeConstants.accent;
      case AchievementCategory.streak:
        return ThemeConstants.error;
      case AchievementCategory.points:
        return ThemeConstants.warning;
      case AchievementCategory.special:
        return ThemeConstants.tertiary;
    }
  }

  IconData _getAchievementIcon(Achievement achievement) {
    switch (achievement.category) {
      case AchievementCategory.athkar:
        return Icons.menu_book;
      case AchievementCategory.tasbih:
        return Icons.radio_button_checked;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.points:
        return Icons.star;
      case AchievementCategory.special:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
