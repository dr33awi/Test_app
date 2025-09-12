// lib/features/statistics/widgets/quick_stats_widget.dart

import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../hooks/use_statistics.dart';

class QuickStatsWidget extends StatelessWidget {
  const QuickStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = UseStatistics(context);
    final todayStats = stats.todayStats;
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConstants.primary.withValues(alpha: 0.1),
            ThemeConstants.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: ThemeConstants.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickStatItem(
            icon: Icons.menu_book,
            value: '${todayStats.athkarCompleted}',
            label: 'أذكار',
            color: ThemeConstants.primary,
          ),
          
          Container(
            width: 1,
            height: 30,
            color: context.dividerColor,
          ),
          
          _QuickStatItem(
            icon: Icons.radio_button_checked,
            value: '${todayStats.tasbihCount}',
            label: 'تسبيح',
            color: ThemeConstants.accent,
          ),
          
          Container(
            width: 1,
            height: 30,
            color: context.dividerColor,
          ),
          
          _QuickStatItem(
            icon: Icons.local_fire_department,
            value: '${stats.currentStreak}',
            label: 'سلسلة',
            color: ThemeConstants.error,
          ),
          
          Container(
            width: 1,
            height: 30,
            color: context.dividerColor,
          ),
          
          _QuickStatItem(
            icon: Icons.star,
            value: '${todayStats.totalPoints}',
            label: 'نقاط',
            color: ThemeConstants.warning,
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.titleSmall?.copyWith(
            color: color,
            fontWeight: ThemeConstants.bold,
          ),
        ),
        Text(
          label,
          style: context.labelSmall?.copyWith(
            color: context.textSecondaryColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}