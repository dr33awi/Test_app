// lib/features/statistics/screens/statistics_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';
import '../widgets/statistics_card.dart';
import '../widgets/goal_progress_card.dart';
// استيراد الشاشة الكاملة
import 'complete_statistics_dashboard.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  late final StatisticsService _service;
  
  @override
  void initState() {
    super.initState();
    _service = getIt<StatisticsService>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          title: const Text('الإحصائيات'),
          centerTitle: true,
          backgroundColor: context.cardColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الملخص السريع
              _buildQuickSummarySection(),
              
              const SizedBox(height: 20),
              
              // زر للانتقال للوحة الكاملة
              _buildFullDashboardButton(),
              
              const SizedBox(height: 20),
              
              // إحصائيات اليوم
              _buildTodayStatisticsSection(),
              
              const SizedBox(height: 20),
              
              // الأهداف الحالية
              _buildCurrentGoalsSection(),
              
              const SizedBox(height: 20),
              
              // خيارات إضافية
              _buildAdditionalOptions(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickSummarySection() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final todayStats = service.getTodayStatistics();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeConstants.primary.withOpacity(0.1),
                ThemeConstants.primaryLight.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ThemeConstants.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: ThemeConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص سريع',
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'إحصائياتك لهذا اليوم',
                          style: context.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // النقاط الإجمالية
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeConstants.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: ThemeConstants.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.totalPoints}',
                          style: context.labelMedium?.copyWith(
                            color: ThemeConstants.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // الإحصائيات السريعة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    icon: Icons.local_fire_department,
                    value: '${service.currentStreak}',
                    label: 'سلسلة',
                    color: ThemeConstants.error,
                  ),
                  _buildQuickStat(
                    icon: Icons.menu_book,
                    value: '${todayStats.athkarCompleted}',
                    label: 'أذكار',
                    color: ThemeConstants.primary,
                  ),
                  _buildQuickStat(
                    icon: Icons.radio_button_checked,
                    value: '${todayStats.tasbihCount}',
                    label: 'تسبيح',
                    color: ThemeConstants.accent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.labelSmall?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFullDashboardButton() {
    return InkWell(
      onTap: () {
        // الانتقال إلى لوحة الإحصائيات الكاملة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteStatisticsDashboard(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeConstants.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة الإحصائيات الشاملة',
                    style: context.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'عرض جميع الإحصائيات والتحديات والإنجازات',
                    style: context.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTodayStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إحصائيات اليوم',
              style: context.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // الانتقال مباشرة إلى تبويب النظرة العامة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteStatisticsDashboard(),
                  ),
                );
              },
              child: const Text('عرض المزيد'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<StatisticsService>(
          builder: (context, service, _) {
            final todayStats = service.getTodayStatistics();
            
            return Row(
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
                const SizedBox(width: 12),
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
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildCurrentGoalsSection() {
    return Consumer<StatisticsService>(
      builder: (context, service, _) {
        final goals = service.activeGoals;
        
        if (goals.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 48,
                  color: context.textSecondaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد أهداف نشطة',
                  style: context.bodyMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // إضافة هدف جديد
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إضافة هدف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأهداف الحالية',
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompleteStatisticsDashboard(),
                      ),
                    );
                  },
                  child: Text('عرض الكل (${goals.length})'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...goals.take(3).map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GoalProgressCard(goal: goal),
            )),
          ],
        );
      },
    );
  }
  
  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'خيارات إضافية',
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildOptionCard(
              icon: Icons.military_tech,
              title: 'الرتب',
              subtitle: 'عرض نظام الرتب',
              color: ThemeConstants.tertiary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteStatisticsDashboard(),
                  ),
                ).then((_) {
                  // يمكن تحديد التبويب الافتراضي هنا
                });
              },
            ),
            _buildOptionCard(
              icon: Icons.flag,
              title: 'التحديات',
              subtitle: 'التحديات النشطة',
              color: ThemeConstants.accent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteStatisticsDashboard(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              icon: Icons.calendar_view_month,
              title: 'النشاط',
              subtitle: 'خريطة النشاط',
              color: ThemeConstants.success,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteStatisticsDashboard(),
                  ),
                );
              },
            ),
            _buildOptionCard(
              icon: Icons.emoji_events,
              title: 'الإنجازات',
              subtitle: 'عرض الإنجازات',
              color: ThemeConstants.warning,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteStatisticsDashboard(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: context.labelSmall?.copyWith(
                color: context.textSecondaryColor,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}