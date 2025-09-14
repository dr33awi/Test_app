// lib/features/statistics/widgets/quick_stats_widget.dart

import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';

class QuickStatsWidget extends StatefulWidget {
  const QuickStatsWidget({super.key});

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget> {
  late final StatisticsService _statsService;
  late DailyStatistics _todayStats;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  void _initializeService() {
    // استخدام GetIt بدلاً من Provider
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService = getIt<StatisticsService>();
      _todayStats = _statsService.getTodayStatistics();
      
      // الاستماع للتغييرات
      _statsService.addListener(_onStatsChanged);
    } else {
      // إذا لم تكن الخدمة مسجلة، استخدم قيم افتراضية
      _todayStats = DailyStatistics.empty(DateTime.now());
    }
  }
  
  void _onStatsChanged() {
    if (mounted) {
      setState(() {
        _todayStats = _statsService.getTodayStatistics();
      });
    }
  }
  
  @override
  void dispose() {
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService.removeListener(_onStatsChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود الخدمة
    if (!getIt.isRegistered<StatisticsService>()) {
      return _buildEmptyStats(context);
    }
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space1),
                decoration: BoxDecoration(
                  color: ThemeConstants.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  size: 16,
                  color: ThemeConstants.primary,
                ),
              ),
              ThemeConstants.space2.w,
              Text(
                'إحصائيات اليوم',
                style: context.labelLarge?.copyWith(
                  color: ThemeConstants.primary,
                  fontWeight: ThemeConstants.semiBold,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space3.h,
          
          // الإحصائيات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStatItem(
                icon: Icons.menu_book,
                value: '${_todayStats.athkarCompleted}',
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
                value: '${_todayStats.tasbihCount}',
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
                value: '${_statsService.currentStreak}',
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
                value: '${_todayStats.totalPoints}',
                label: 'نقاط',
                color: ThemeConstants.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Widget للحالة الفارغة
  Widget _buildEmptyStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: context.textSecondaryColor,
              ),
              ThemeConstants.space2.w,
              Text(
                'ابدأ يومك بالأذكار',
                style: context.labelLarge?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space3.h,
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStatItem(
                icon: Icons.menu_book,
                value: '0',
                label: 'أذكار',
                color: context.textSecondaryColor,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _QuickStatItem(
                icon: Icons.radio_button_checked,
                value: '0',
                label: 'تسبيح',
                color: context.textSecondaryColor,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _QuickStatItem(
                icon: Icons.local_fire_department,
                value: '0',
                label: 'سلسلة',
                color: context.textSecondaryColor,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _QuickStatItem(
                icon: Icons.star,
                value: '0',
                label: 'نقاط',
                color: context.textSecondaryColor,
              ),
            ],
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
        Icon(
          icon, 
          color: color, 
          size: 20,
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: ThemeConstants.durationFast,
          child: Text(
            value,
            key: ValueKey(value),
            style: context.titleSmall?.copyWith(
              color: color,
              fontWeight: ThemeConstants.bold,
            ),
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