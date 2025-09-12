// lib/features/statistics/screens/statistics_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';
import '../widgets/statistics_card.dart';
import '../widgets/achievement_card.dart';
import '../widgets/goal_progress_card.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final StatisticsService _service;
  late final TabController _tabController;
  
  PeriodType _selectedPeriod = PeriodType.daily;
  
  @override
  void initState() {
    super.initState();
    _service = getIt<StatisticsService>();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar مخصص
              _buildCustomAppBar(context),
              
              // TabBar
              Container(
                color: context.cardColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: ThemeConstants.primary,
                  labelColor: ThemeConstants.primary,
                  unselectedLabelColor: context.textSecondaryColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard, size: 20)),
                    Tab(text: 'التقدم', icon: Icon(Icons.trending_up, size: 20)),
                    Tab(text: 'الأهداف', icon: Icon(Icons.flag, size: 20)),
                    Tab(text: 'الإنجازات', icon: Icon(Icons.emoji_events, size: 20)),
                  ],
                ),
              ),
              
              // محتوى التبويبات
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildProgressTab(),
                    _buildGoalsTab(),
                    _buildAchievementsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإحصائيات',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                Consumer<StatisticsService>(
                  builder: (context, service, _) {
                    return Text(
                      'إجمالي النقاط: ${service.totalPoints}',
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // زر التصدير
          Container(
            margin: const EdgeInsets.only(left: ThemeConstants.space2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: InkWell(
                onTap: _exportStatistics,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    border: Border.all(
                      color: context.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.share,
                    color: ThemeConstants.primary,
                    size: ThemeConstants.iconMd,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== تبويب النظرة العامة ====================
  
  Widget _buildOverviewTab() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final todayStats = service.getTodayStatistics();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الترحيب
              _buildWelcomeCard(service),
              
              ThemeConstants.space4.h,
              
              // إحصائيات اليوم
              Text(
                'إحصائيات اليوم',
                style: context.titleMedium?.copyWith(
                  fontWeight: ThemeConstants.bold,
                ),
              ),
              
              ThemeConstants.space3.h,
              
              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: 'الأذكار',
                      value: '${todayStats.athkarCompleted}',
                      subtitle: 'ذكر مكتمل',
                      icon: Icons.menu_book,
                      color: ThemeConstants.primary,
                      progress: todayStats.athkarCompleted / 100,
                    ),
                  ),
                  ThemeConstants.space3.w,
                  Expanded(
                    child: StatisticsCard(
                      title: 'التسبيح',
                      value: '${todayStats.tasbihCount}',
                      subtitle: 'تسبيحة',
                      icon: Icons.radio_button_checked,
                      color: ThemeConstants.accent,
                      progress: todayStats.tasbihCount / 1000,
                    ),
                  ),
                ],
              ),
              
              ThemeConstants.space3.h,
              
              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: 'النقاط',
                      value: '${todayStats.totalPoints}',
                      subtitle: 'نقطة اليوم',
                      icon: Icons.star,
                      color: ThemeConstants.warning,
                      showProgress: false,
                    ),
                  ),
                  ThemeConstants.space3.w,
                  Expanded(
                    child: StatisticsCard(
                      title: 'الوقت',
                      value: _formatDuration(todayStats.totalTime),
                      subtitle: 'وقت العبادة',
                      icon: Icons.timer,
                      color: ThemeConstants.success,
                      showProgress: false,
                    ),
                  ),
                ],
              ),
              
              ThemeConstants.space5.h,
              
              // السلسلة الحالية
              _buildStreakSection(service),
              
              ThemeConstants.space5.h,
              
              // رسم بياني سريع
              _buildQuickChart(service),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(StatisticsService service) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: context.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                ThemeConstants.space2.h,
                Text(
                  _getMotivationalMessage(service.currentStreak),
                  style: context.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                ThemeConstants.space3.h,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.space3,
                    vertical: ThemeConstants.space2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      ),
                      ThemeConstants.space2.w,
                      Text(
                        'سلسلة ${service.currentStreak} يوم',
                        style: context.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ThemeConstants.space4.w,
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(StatisticsService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاستمرارية',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        ThemeConstants.space3.h,
        Container(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStreakItem(
                    'الحالية',
                    service.currentStreak,
                    Icons.local_fire_department,
                    ThemeConstants.error,
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: context.dividerColor,
                  ),
                  _buildStreakItem(
                    'الأطول',
                    service.longestStreak,
                    Icons.emoji_events,
                    ThemeConstants.warning,
                  ),
                ],
              ),
              ThemeConstants.space4.h,
              // شريط أيام الأسبوع
              _buildWeeklyStreakBar(service),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        ThemeConstants.space2.h,
        Text(
          '$value',
          style: context.headlineMedium?.copyWith(
            color: color,
            fontWeight: ThemeConstants.bold,
          ),
        ),
        Text(
          label,
          style: context.labelMedium?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStreakBar(StatisticsService service) {
    final today = DateTime.now();
    final weekDays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = today.subtract(Duration(days: 6 - index));
        final dayStats = service.getTodayStatistics(); // يجب تعديل لاستخدام التاريخ المحدد
        final hasActivity = dayStats.athkarCompleted > 0 || dayStats.tasbihCount > 0;
        
        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasActivity 
                    ? ThemeConstants.success 
                    : context.dividerColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: hasActivity 
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${date.day}',
                        style: context.labelSmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
              ),
            ),
            ThemeConstants.space1.h,
            Text(
              weekDays[date.weekday - 1],
              style: context.labelSmall?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQuickChart(StatisticsService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النشاط الأسبوعي',
              style: context.titleMedium?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _tabController.animateTo(1);
              }),
              child: const Text('عرض المزيد'),
            ),
          ],
        ),
        ThemeConstants.space3.h,
        Container(
          height: 200,
          padding: const EdgeInsets.all(ThemeConstants.space3),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: _buildLineChart(service),
        ),
      ],
    );
  }

  Widget _buildLineChart(StatisticsService service) {
    // الحصول على بيانات الأسبوع الماضي
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    final periodStats = service.getPeriodStatistics(
      startDate: startDate,
      endDate: endDate,
    );
    
    // تجهيز نقاط البيانات
    final athkarSpots = <FlSpot>[];
    final tasbihSpots = <FlSpot>[];
    
    for (int i = 0; i < 7; i++) {
      final dayStats = i < periodStats.dailyStats.length 
          ? periodStats.dailyStats[i]
          : null;
      
      athkarSpots.add(FlSpot(
        i.toDouble(),
        dayStats?.athkarCompleted.toDouble() ?? 0,
      ));
      
      tasbihSpots.add(FlSpot(
        i.toDouble(),
        (dayStats?.tasbihCount ?? 0) / 10, // تقليل المقياس للتسبيح
      ));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.dividerColor.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
                return Text(
                  days[value.toInt() % 7],
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // خط الأذكار
          LineChartBarData(
            spots: athkarSpots,
            isCurved: true,
            color: ThemeConstants.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: ThemeConstants.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: ThemeConstants.primary.withValues(alpha: 0.1),
            ),
          ),
          // خط التسبيح
          LineChartBarData(
            spots: tasbihSpots,
            isCurved: true,
            color: ThemeConstants.accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: ThemeConstants.accent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: ThemeConstants.accent.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== تبويب التقدم ====================
  
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // محدد الفترة
          _buildPeriodSelector(),
          
          ThemeConstants.space4.h,
          
          // إحصائيات الفترة
          _buildPeriodStatistics(),
          
          ThemeConstants.space4.h,
          
          // الرسوم البيانية
          _buildDetailedCharts(),
          
          ThemeConstants.space4.h,
          
          // الأنشطة الأخيرة
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space2),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: PeriodType.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeConstants.space3,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? ThemeConstants.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                ),
                child: Text(
                  period.title,
                  style: context.labelLarge?.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : context.textSecondaryColor,
                    fontWeight: isSelected 
                        ? ThemeConstants.semiBold 
                        : ThemeConstants.regular,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodStatistics() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final periodStats = _getPeriodStatistics(service);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات ${_selectedPeriod.title}',
              style: context.titleMedium?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            ThemeConstants.space3.h,
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: ThemeConstants.space3,
              crossAxisSpacing: ThemeConstants.space3,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'إجمالي الأذكار',
                  '${periodStats.activityBreakdown[ActivityType.athkar] ?? 0}',
                  Icons.menu_book,
                  ThemeConstants.primary,
                ),
                _buildStatCard(
                  'إجمالي التسبيح',
                  '${periodStats.activityBreakdown[ActivityType.tasbih] ?? 0}',
                  Icons.radio_button_checked,
                  ThemeConstants.accent,
                ),
                _buildStatCard(
                  'النقاط المكتسبة',
                  '${periodStats.totalPoints}',
                  Icons.star,
                  ThemeConstants.warning,
                ),
                _buildStatCard(
                  'الأيام النشطة',
                  '${periodStats.activeDays}/${periodStats.totalDays}',
                  Icons.calendar_today,
                  ThemeConstants.success,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          ThemeConstants.space2.h,
          Text(
            value,
            style: context.titleLarge?.copyWith(
              color: color,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          Text(
            title,
            style: context.labelSmall?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحليل البياني',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        ThemeConstants.space3.h,
        Container(
          height: 250,
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: _buildBarChart(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final periodStats = _getPeriodStatistics(service);
        
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label = rodIndex == 0 ? 'أذكار' : 'تسبيح';
                  return BarTooltipItem(
                    '$label\n${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _getBarChartLabel(value.toInt()),
                      style: context.labelSmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 20,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: context.labelSmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: _generateBarGroups(periodStats),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(PeriodStatistics stats) {
    final groups = <BarChartGroupData>[];
    
    for (int i = 0; i < stats.dailyStats.length && i < 7; i++) {
      final dayStats = stats.dailyStats[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayStats.athkarCompleted.toDouble(),
              color: ThemeConstants.primary,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: (dayStats.tasbihCount / 10).toDouble(),
              color: ThemeConstants.accent,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return groups;
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأنشطة الأخيرة',
              style: context.titleMedium?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            TextButton(
              onPressed: _showAllActivities,
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        ThemeConstants.space3.h,
        // قائمة الأنشطة الأخيرة (نعرض أول 5 فقط)
        Consumer<StatisticsService>(
          builder: (context, service, _) {
            // هنا يجب إضافة getter للأنشطة الأخيرة في الخدمة
            return const Center(
              child: Text('سيتم عرض الأنشطة الأخيرة هنا'),
            );
          },
        ),
      ],
    );
  }

  // ==================== تبويب الأهداف ====================
  
  Widget _buildGoalsTab() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final activeGoals = service.activeGoals;
        
        if (activeGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 80,
                  color: context.textSecondaryColor.withValues(alpha: 0.5),
                ),
                ThemeConstants.space4.h,
                Text(
                  'لا توجد أهداف نشطة',
                  style: context.titleLarge?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                ThemeConstants.space2.h,
                Text(
                  'ابدأ بتحديد أهداف يومية أو أسبوعية',
                  style: context.bodyMedium?.copyWith(
                    color: context.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                ),
                ThemeConstants.space4.h,
                ElevatedButton.icon(
                  onPressed: _addNewGoal,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة هدف جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space5,
                      vertical: ThemeConstants.space3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          children: [
            // زر إضافة هدف جديد
            Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.space4),
              child: ElevatedButton.icon(
                onPressed: _addNewGoal,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('إضافة هدف جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            
            // قائمة الأهداف النشطة
            ...activeGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
              child: GoalProgressCard(
                goal: goal,
                onTap: () => _showGoalDetails(goal),
              ),
            )),
          ],
        );
      },
    );
  }

  // ==================== تبويب الإنجازات ====================
  
  Widget _buildAchievementsTab() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final achievements = service.unlockedAchievements;
        
        if (achievements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: context.textSecondaryColor.withValues(alpha: 0.5),
                ),
                ThemeConstants.space4.h,
                Text(
                  'لم تحصل على إنجازات بعد',
                  style: context.titleLarge?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                ThemeConstants.space2.h,
                Text(
                  'استمر في الأذكار والتسبيح لفتح الإنجازات',
                  style: context.bodyMedium?.copyWith(
                    color: context.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: ThemeConstants.space3,
            crossAxisSpacing: ThemeConstants.space3,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return AchievementCard(
              achievement: achievement,
              onTap: () => _showAchievementDetails(achievement),
            );
          },
        );
      },
    );
  }

  // ==================== Helper Methods ====================
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 18) {
      return 'مساء الخير';
    } else {
      return 'مساء النور';
    }
  }

  String _getMotivationalMessage(int streak) {
    if (streak == 0) {
      return 'ابدأ رحلتك اليوم مع الأذكار';
    } else if (streak < 7) {
      return 'أحسنت! استمر للوصول لأسبوع كامل';
    } else if (streak < 30) {
      return 'ممتاز! أنت على الطريق الصحيح';
    } else {
      return 'ما شاء الله! إنجاز رائع';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hoursس $minutesد';
    } else {
      return '$minutes دقيقة';
    }
  }

  PeriodStatistics _getPeriodStatistics(StatisticsService service) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;
    
    switch (_selectedPeriod) {
      case PeriodType.daily:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case PeriodType.weekly:
        startDate = now.subtract(const Duration(days: 6));
        break;
      case PeriodType.monthly:
        startDate = now.subtract(const Duration(days: 29));
        break;
      case PeriodType.yearly:
        startDate = now.subtract(const Duration(days: 364));
        break;
    }
    
    return service.getPeriodStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  String _getBarChartLabel(int value) {
    if (_selectedPeriod == PeriodType.weekly) {
      const days = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
      return days[value % 7];
    } else {
      return '${value + 1}';
    }
  }

  void _exportStatistics() async {
    HapticFeedback.lightImpact();
    
    // تصدير الإحصائيات
    context.showSuccessSnackBar('سيتم تصدير الإحصائيات قريباً');
  }

  void _showAllActivities() {
    // عرض جميع الأنشطة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllActivitiesScreen(),
      ),
    );
  }

  void _addNewGoal() {
    // إضافة هدف جديد
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalBottomSheet(),
    );
  }

  void _showGoalDetails(StatisticsGoal goal) {
    // عرض تفاصيل الهدف
    showDialog(
      context: context,
      builder: (context) => GoalDetailsDialog(goal: goal),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    // عرض تفاصيل الإنجاز
    showDialog(
      context: context,
      builder: (context) => AchievementDetailsDialog(achievement: achievement),
    );
  }
}

enum PeriodType {
  daily('اليوم'),
  weekly('الأسبوع'),
  monthly('الشهر'),
  yearly('السنة');

  const PeriodType(this.title);
  final String title;
}

// Placeholder screens/dialogs (يجب تنفيذها لاحقاً)
class AllActivitiesScreen extends StatelessWidget {
  const AllActivitiesScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جميع الأنشطة')),
      body: const Center(child: Text('قائمة الأنشطة')),
    );
  }
}

class AddGoalBottomSheet extends StatelessWidget {
  const AddGoalBottomSheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: const Text('إضافة هدف جديد'),
    );
  }
}

class GoalDetailsDialog extends StatelessWidget {
  final StatisticsGoal goal;
  const GoalDetailsDialog({super.key, required this.goal});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(goal.title),
      content: Text(goal.description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class AchievementDetailsDialog extends StatelessWidget {
  final Achievement achievement;
  const AchievementDetailsDialog({super.key, required this.achievement});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(achievement.title),
      content: Text(achievement.description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}