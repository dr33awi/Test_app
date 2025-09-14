// lib/features/statistics/widgets/unified_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';
import '../screens/statistics_dashboard_screen.dart';

/// ويدجت الإحصائيات الموحدة - يستبدل جميع ويدجتات الإحصائيات المتفرقة
class UnifiedStatsWidget extends StatefulWidget {
  final bool showDetailedStats;
  final bool isCompact;
  final VoidCallback? onTap;
  
  const UnifiedStatsWidget({
    super.key,
    this.showDetailedStats = true,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<UnifiedStatsWidget> createState() => _UnifiedStatsWidgetState();
}

class _UnifiedStatsWidgetState extends State<UnifiedStatsWidget> 
    with SingleTickerProviderStateMixin {
  late final StatisticsService _statsService;
  late DailyStatistics _todayStats;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // بيانات الإحصائيات
  int _currentStreak = 0;
  int _completedCategories = 0;
  int _inProgressCategories = 0;
  int _averageProgress = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
    _setupAnimation();
  }
  
  void _initializeService() {
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService = getIt<StatisticsService>();
      _loadStatistics();
      _statsService.addListener(_onStatsChanged);
    } else {
      // قيم افتراضية إذا لم تكن الخدمة متاحة
      _todayStats = DailyStatistics.empty(DateTime.now());
    }
  }
  
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: ThemeConstants.durationNormal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }
  
  void _loadStatistics() {
    setState(() {
      _todayStats = _statsService.getTodayStatistics();
      _currentStreak = _statsService.currentStreak;
      _calculateCategoryStats();
    });
  }
  
  void _calculateCategoryStats() {
    // حساب إحصائيات الفئات من البيانات المحلية
    // يمكن تحسين هذا بإضافة دوال في StatisticsService
    _completedCategories = _todayStats.athkarCategories;
    _inProgressCategories = 0; // يحتاج لحساب من البيانات
    _averageProgress = _todayStats.athkarCompleted > 0 ? 
        ((_todayStats.athkarCompleted / 100) * 100).round() : 0;
  }
  
  void _onStatsChanged() {
    if (mounted) {
      _loadStatistics();
    }
  }
  
  @override
  void dispose() {
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService.removeListener(_onStatsChanged);
    }
    _animationController.dispose();
    super.dispose();
  }
  
  void _navigateToDetailedStats() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatisticsDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap ?? _navigateToDetailedStats,
        child: widget.isCompact ? _buildCompactView() : _buildFullView(),
      ),
    );
  }
  
  /// العرض الكامل - للصفحة الرئيسية
  Widget _buildFullView() {
    return Column(
      children: [
        // البطاقة الرئيسية - التقدم اليومي
        _buildProgressCard(),
        
        if (widget.showDetailedStats) ...[
          ThemeConstants.space3.h,
          // بطاقة إحصائيات اليوم
          _buildTodayStatsCard(),
        ],
      ],
    );
  }
  
  /// العرض المضغوط - للشاشات الفرعية
  Widget _buildCompactView() {
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
          _CompactStatItem(
            icon: Icons.menu_book,
            value: '${_todayStats.athkarCompleted}',
            label: 'أذكار',
            color: ThemeConstants.primary,
          ),
          _buildDivider(),
          _CompactStatItem(
            icon: Icons.radio_button_checked,
            value: '${_todayStats.tasbihCount}',
            label: 'تسبيح',
            color: ThemeConstants.accent,
          ),
          _buildDivider(),
          _CompactStatItem(
            icon: Icons.local_fire_department,
            value: '$_currentStreak',
            label: 'سلسلة',
            color: ThemeConstants.error,
          ),
          _buildDivider(),
          _CompactStatItem(
            icon: Icons.star,
            value: '${_todayStats.totalPoints}',
            label: 'نقاط',
            color: ThemeConstants.warning,
          ),
        ],
      ),
    );
  }
  
  /// بطاقة التقدم الرئيسية
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'إحصائيات الأذكار',
                style: context.titleMedium?.copyWith(
                  fontWeight: ThemeConstants.bold,
                ),
              ),
              const Spacer(),
              // زر المزيد
              IconButton(
                onPressed: _navigateToDetailedStats,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: ThemeConstants.iconSm,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: ThemeConstants.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // الإحصائيات الثلاثة الرئيسية
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.percent,
                  value: '$_averageProgress%',
                  label: 'متوسط التقدم',
                  color: ThemeConstants.primary,
                  iconBackground: ThemeConstants.primary.withValues(alpha: 0.15),
                ),
              ),
              ThemeConstants.space3.w,
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  value: '$_inProgressCategories',
                  label: 'قيد التقدم',
                  color: ThemeConstants.warning,
                  iconBackground: ThemeConstants.warning.withValues(alpha: 0.15),
                ),
              ),
              ThemeConstants.space3.w,
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '$_completedCategories',
                  label: 'مكتملة',
                  color: ThemeConstants.success,
                  iconBackground: ThemeConstants.success.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// بطاقة إحصائيات اليوم التفصيلية
  Widget _buildTodayStatsCard() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConstants.primary.withValues(alpha: 0.08),
            ThemeConstants.primaryLight.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: ThemeConstants.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
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
                  Icons.today,
                  size: ThemeConstants.iconSm,
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
          
          // الإحصائيات بتصميم grid 2x2
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: ThemeConstants.space3,
            crossAxisSpacing: ThemeConstants.space3,
            childAspectRatio: 1,
            children: [
              _MiniStatCard(
                icon: Icons.star,
                value: '${_todayStats.totalPoints}',
                label: 'نقاط',
                color: ThemeConstants.warning,
                background: Colors.white.withValues(alpha: 0.7),
              ),
              _MiniStatCard(
                icon: Icons.local_fire_department,
                value: '$_currentStreak',
                label: 'سلسلة',
                color: ThemeConstants.error,
                background: Colors.white.withValues(alpha: 0.7),
              ),
              _MiniStatCard(
                icon: Icons.radio_button_checked,
                value: '${_todayStats.tasbihCount}',
                label: 'تسبيح',
                color: ThemeConstants.accent,
                background: Colors.white.withValues(alpha: 0.7),
              ),
              _MiniStatCard(
                icon: Icons.menu_book,
                value: '${_todayStats.athkarCompleted}',
                label: 'أذكار',
                color: ThemeConstants.primary,
                background: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
          
          // شريط التقدم اليومي
          if (_todayStats.athkarCompleted > 0 || _todayStats.tasbihCount > 0) ...[
            ThemeConstants.space3.h,
            _buildDailyProgressBar(),
          ],
        ],
      ),
    );
  }
  
  /// شريط التقدم اليومي
  Widget _buildDailyProgressBar() {
    const dailyGoal = 100; // هدف يومي افتراضي
    final progress = ((_todayStats.athkarCompleted + _todayStats.tasbihCount) / dailyGoal)
        .clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الهدف اليومي',
              style: context.labelMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: context.labelMedium?.copyWith(
                color: ThemeConstants.primary,
                fontWeight: ThemeConstants.semiBold,
              ),
            ),
          ],
        ),
        ThemeConstants.space2.h,
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: ThemeConstants.primary.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? ThemeConstants.success : ThemeConstants.primary,
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: context.dividerColor.withValues(alpha: 0.5),
    );
  }
}

/// عنصر إحصائية كبير
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color iconBackground;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: ThemeConstants.iconMd,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            value,
            style: context.titleMedium?.copyWith(
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
      ),
    );
  }
}

/// عنصر إحصائية صغير
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: ThemeConstants.iconSm),
          ThemeConstants.space1.h,
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
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر إحصائية مضغوط
class _CompactStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _CompactStatItem({
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