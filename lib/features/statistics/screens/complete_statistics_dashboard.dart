// lib/features/statistics/screens/complete_statistics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';
import '../models/ranking_system.dart';
import '../models/challenges_system.dart';
import '../widgets/activity_heatmap_widget.dart';
import '../widgets/statistics_card.dart';
import '../widgets/achievement_card.dart';
import '../widgets/goal_progress_card.dart';

/// لوحة القيادة الشاملة للإحصائيات - تجمع جميع المكونات
class CompleteStatisticsDashboard extends StatefulWidget {
  const CompleteStatisticsDashboard({super.key});

  @override
  State<CompleteStatisticsDashboard> createState() => _CompleteStatisticsDashboardState();
}

class _CompleteStatisticsDashboardState extends State<CompleteStatisticsDashboard>
    with TickerProviderStateMixin {
  late final StatisticsService _service;
  late final TabController _mainTabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // البيانات
  UserRank? _currentRank;
  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  List<Challenge> _specialChallenges = [];
  Map<DateTime, int> _heatmapData = {};
  
  @override
  void initState() {
    super.initState();
    _service = getIt<StatisticsService>();
    _mainTabController = TabController(length: 5, vsync: this);
    _setupAnimations();
    _loadData();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  void _loadData() {
    setState(() {
      _currentRank = _service.currentRank;
      _dailyChallenges = _service.activeDailyChallenges;
      _weeklyChallenges = _service.activeWeeklyChallenges;
      _specialChallenges = _service.activeSpecialChallenges;
      _heatmapData = _service.getHeatmapDataForPeriod(
        startDate: DateTime.now().subtract(const Duration(days: 364)),
        endDate: DateTime.now(),
      );
    });
  }
  
  @override
  void dispose() {
    _mainTabController.dispose();
    _animationController.dispose();
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
              // AppBar مخصص مع عرض الرتبة
              _buildCustomAppBar(),
              
              // TabBar الرئيسي
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _mainTabController,
                  indicatorColor: ThemeConstants.primary,
                  indicatorWeight: 3,
                  labelColor: ThemeConstants.primary,
                  unselectedLabelColor: context.textSecondaryColor,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard, size: 18)),
                    Tab(text: 'الرتب', icon: Icon(Icons.military_tech, size: 18)),
                    Tab(text: 'التحديات', icon: Icon(Icons.flag, size: 18)),
                    Tab(text: 'النشاط', icon: Icon(Icons.calendar_view_month, size: 18)),
                    Tab(text: 'الإنجازات', icon: Icon(Icons.emoji_events, size: 18)),
                  ],
                ),
              ),
              
              // محتوى التبويبات
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    controller: _mainTabController,
                    children: [
                      _buildOverviewTab(),
                      _buildRankingTab(),
                      _buildChallengesTab(),
                      _buildActivityTab(),
                      _buildAchievementsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ==================== Custom AppBar ====================
  
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            style: IconButton.styleFrom(
              backgroundColor: context.surfaceColor,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // العنوان والرتبة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة الإحصائيات الشاملة',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                if (_currentRank != null) ...[
                  const SizedBox(height: 4),
                  // عرض الرتبة الحالية بشكل مضغوط
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _currentRank!.gradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentRank!.icon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentRank!.title,
                          style: context.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: ThemeConstants.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // النقاط الإجمالية
          Consumer<StatisticsService>(
            builder: (context, service, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemeConstants.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeConstants.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: ThemeConstants.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${service.totalPoints}',
                      style: context.titleSmall?.copyWith(
                        color: ThemeConstants.warning,
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // ==================== Overview Tab ====================
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة ملخص سريع
          _buildQuickSummaryCard(),
          
          const SizedBox(height: 20),
          
          // عرض مضغوط للرتبة الحالية
          if (_currentRank != null) ...[
            _buildCompactRankCard(),
            const SizedBox(height: 20),
          ],
          
          // التحديات النشطة (عرض مضغوط)
          _buildActiveChallengesSummary(),
          
          const SizedBox(height: 20),
          
          // خريطة النشاط المصغرة
          _buildMiniHeatmap(),
          
          const SizedBox(height: 20),
          
          // إحصائيات اليوم
          _buildTodayStats(),
        ],
      ),
    );
  }
  
  Widget _buildQuickSummaryCard() {
    final todayStats = _service.getTodayStatistics();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                _getGreeting(),
                style: context.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: ThemeConstants.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'أنت في يوم رائع! استمر في تحقيق أهدافك',
            style: context.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                Icons.local_fire_department,
                '${_service.currentStreak}',
                'سلسلة',
              ),
              _buildSummaryItem(
                Icons.menu_book,
                '${todayStats.athkarCompleted}',
                'أذكار اليوم',
              ),
              _buildSummaryItem(
                Icons.radio_button_checked,
                '${todayStats.tasbihCount}',
                'تسبيح اليوم',
              ),
              _buildSummaryItem(
                Icons.star,
                '${todayStats.totalPoints}',
                'نقاط اليوم',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: ThemeConstants.bold,
          ),
        ),
        Text(
          label,
          style: context.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompactRankCard() {
    if (_currentRank == null) return const SizedBox();
    
    final nextRank = _service.getNextRank();
    final progress = _service.getProgressToNextRank();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _currentRank!.gradient.map((c) => c.withValues(alpha: 0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentRank!.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _currentRank!.gradient),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentRank!.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentRank!.title,
                      style: context.titleMedium?.copyWith(
                        color: _currentRank!.color,
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                    Text(
                      _currentRank!.subtitle,
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentRank!.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'المستوى ${_currentRank!.level}',
                  style: context.labelMedium?.copyWith(
                    color: _currentRank!.color,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
              ),
            ],
          ),
          if (nextRank != null) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم للرتبة التالية',
                      style: context.labelMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: context.labelMedium?.copyWith(
                        color: _currentRank!.color,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _currentRank!.color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_currentRank!.color),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الرتبة التالية: ${nextRank.title}',
                      style: context.labelSmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      'باقي ${_service.getPointsToNextRank()} نقطة',
                      style: context.labelSmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActiveChallengesSummary() {
    final totalChallenges = _dailyChallenges.length + 
                           _weeklyChallenges.length + 
                           _specialChallenges.length;
    
    if (totalChallenges == 0) {
      return const SizedBox();
    }
    
    // عرض أول 3 تحديات فقط
    final displayChallenges = [
      ..._dailyChallenges.take(2),
      ..._weeklyChallenges.take(1),
    ].take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التحديات النشطة',
              style: context.titleMedium?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            TextButton(
              onPressed: () => _mainTabController.animateTo(2),
              child: Text('عرض الكل ($totalChallenges)'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayChallenges.map((challenge) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMiniChallengeCard(challenge),
        )),
      ],
    );
  }
  
  Widget _buildMiniChallengeCard(Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: challenge.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              challenge.icon,
              color: challenge.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: context.labelLarge?.copyWith(
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: challenge.progress,
                  backgroundColor: challenge.color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeConstants.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: ThemeConstants.warning),
                const SizedBox(width: 4),
                Text(
                  '${challenge.rewardPoints}',
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
    );
  }
  
  Widget _buildMiniHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نشاطك هذا الشهر',
              style: context.titleMedium?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            TextButton(
              onPressed: () => _mainTabController.animateTo(3),
              child: const Text('عرض السنة كاملة'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ActivityHeatMapWidget(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          activityData: _heatmapData,
          isCompact: true,
          showLabels: false,
          showLegend: false,
          onDayTap: (date) {
            // عرض تفاصيل اليوم
          },
        ),
      ],
    );
  }
  
  Widget _buildTodayStats() {
    final todayStats = _service.getTodayStatistics();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات اليوم التفصيلية',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        const SizedBox(height: 12),
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
        ),
      ],
    );
  }
  
  // ==================== Ranking Tab ====================
  
  Widget _buildRankingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // عرض الرتبة الحالية بالتفصيل
          if (_currentRank != null)
            RankDisplayWidget(
              currentPoints: _service.totalPoints,
              showProgress: true,
              isCompact: false,
            ),
          
          const SizedBox(height: 20),
          
          // الشارات المفتوحة
          _buildBadgesSection(),
          
          const SizedBox(height: 20),
          
          // قائمة جميع الرتب
          _buildAllRanksList(),
        ],
      ),
    );
  }
  
  Widget _buildBadgesSection() {
    final badges = _service.unlockedBadges;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشارات المكتسبة (${badges.length})',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (badges.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    size: 48,
                    color: context.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم تحصل على شارات بعد',
                    style: context.bodyMedium?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _buildBadgeCard(badge);
            },
          ),
      ],
    );
  }
  
  Widget _buildBadgeCard(SpecialBadge badge) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badge.color.withValues(alpha: 0.2),
            badge.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge.icon,
            color: badge.color,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            badge.title,
            style: context.labelSmall?.copyWith(
              color: badge.color,
              fontWeight: ThemeConstants.semiBold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllRanksList() {
    final rankingSystem = RankingSystem();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'جميع الرتب',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...rankingSystem.ranks.map((rank) {
          final isCurrent = rank == _currentRank;
          final isUnlocked = _service.totalPoints >= rank.minPoints;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRankListItem(rank, isCurrent, isUnlocked),
          );
        }),
      ],
    );
  }
  
  Widget _buildRankListItem(UserRank rank, bool isCurrent, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent 
            ? rank.color.withValues(alpha: 0.1)
            : isUnlocked 
                ? context.cardColor
                : context.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent 
              ? rank.color 
              : context.dividerColor.withValues(alpha: 0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isUnlocked 
                  ? LinearGradient(colors: rank.gradient)
                  : null,
              color: !isUnlocked 
                  ? context.dividerColor.withValues(alpha: 0.3)
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? rank.icon : Icons.lock,
              color: isUnlocked ? Colors.white : context.textSecondaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.title,
                  style: context.titleSmall?.copyWith(
                    fontWeight: ThemeConstants.semiBold,
                    color: isCurrent ? rank.color : null,
                  ),
                ),
                Text(
                  '${rank.minPoints} - ${rank.maxPoints} نقطة',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rank.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv.${rank.level}',
              style: context.labelMedium?.copyWith(
                color: isUnlocked ? rank.color : context.textSecondaryColor,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ==================== Challenges Tab ====================
  
  Widget _buildChallengesTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: ThemeConstants.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: context.textSecondaryColor,
              tabs: [
                Tab(text: 'يومية (${_dailyChallenges.length})'),
                Tab(text: 'أسبوعية (${_weeklyChallenges.length})'),
                Tab(text: 'خاصة (${_specialChallenges.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildChallengesList(_dailyChallenges, 'يومية'),
                _buildChallengesList(_weeklyChallenges, 'أسبوعية'),
                _buildChallengesList(_specialChallenges, 'خاصة'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengesList(List<Challenge> challenges, String type) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد تحديات $type نشطة',
              style: context.titleMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFullChallengeCard(challenge),
        );
      },
    );
  }
  
  Widget _buildFullChallengeCard(Challenge challenge) {
    final isCompleted = challenge.status == ChallengeStatus.completed;
    final isExpired = challenge.isExpired;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? ThemeConstants.success.withValues(alpha: 0.1)
            : isExpired
                ? Colors.grey.withValues(alpha: 0.1)
                : context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted 
              ? ThemeConstants.success.withValues(alpha: 0.3)
              : isExpired
                  ? Colors.grey.withValues(alpha: 0.3)
                  : challenge.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: challenge.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  challenge.icon,
                  color: challenge.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: context.titleSmall?.copyWith(
                        fontWeight: ThemeConstants.semiBold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ThemeConstants.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
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
                      '${challenge.rewardPoints}',
                      style: context.labelMedium?.copyWith(
                        color: ThemeConstants.warning,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم',
                    style: context.labelSmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  Text(
                    '${(challenge.progress * 100).toInt()}%',
                    style: context.labelSmall?.copyWith(
                      color: challenge.color,
                      fontWeight: ThemeConstants.semiBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: challenge.progress,
                backgroundColor: challenge.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? ThemeConstants.success : challenge.color,
                ),
                minHeight: 6,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Footer
          Row(
            children: [
              // Difficulty
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: challenge.difficulty.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.difficulty.title,
                  style: context.labelSmall?.copyWith(
                    color: challenge.difficulty.color,
                    fontWeight: ThemeConstants.medium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.type.title,
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
              const Spacer(),
              // Time remaining or status
              if (!isCompleted && !isExpired)
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeRemaining(challenge.timeRemaining),
                      style: context.labelSmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: ThemeConstants.success,
                  size: 20,
                ),
              if (isExpired && !isCompleted)
                const Icon(
                  Icons.cancel,
                  color: Colors.grey,
                  size: 20,
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // ==================== Activity Tab ====================
  
  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'خريطة النشاط السنوية',
            style: context.titleLarge?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Full Heatmap
          ActivityHeatMapWidget(
            startDate: DateTime.now().subtract(const Duration(days: 364)),
            endDate: DateTime.now(),
            activityData: _heatmapData,
            showLabels: true,
            showLegend: true,
            isCompact: false,
            onDayTap: (date) {
              _showDayDetails(date);
            },
          ),
          
          const SizedBox(height: 20),
          
          // Statistics Summary
          _buildActivityStatsSummary(),
        ],
      ),
    );
  }
  
  Widget _buildActivityStatsSummary() {
    // Calculate stats from heatmap data
    final totalDays = _heatmapData.length;
    final activeDays = _heatmapData.values.where((v) => v > 0).length;
    final totalActivity = _heatmapData.values.fold(0, (sum, v) => sum + v);
    final averageActivity = activeDays > 0 ? (totalActivity / activeDays).round() : 0;
    
    // Find best day
    DateTime? bestDay;
    int maxActivity = 0;
    _heatmapData.forEach((date, value) {
      if (value > maxActivity) {
        maxActivity = value;
        bestDay = date;
      }
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص النشاط',
          style: context.titleMedium?.copyWith(
            fontWeight: ThemeConstants.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'الأيام النشطة',
              '$activeDays/$totalDays',
              Icons.calendar_month,
              ThemeConstants.primary,
            ),
            _buildStatCard(
              'إجمالي النشاط',
              '$totalActivity',
              Icons.trending_up,
              ThemeConstants.success,
            ),
            _buildStatCard(
              'متوسط النشاط',
              '$averageActivity/يوم',
              Icons.analytics,
              ThemeConstants.accent,
            ),
            _buildStatCard(
              'أفضل يوم',
              bestDay != null ? _formatDate(bestDay!) : '-',
              Icons.star,
              ThemeConstants.warning,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.titleMedium?.copyWith(
              color: color,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          Text(
            title,
            style: context.labelSmall?.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // ==================== Achievements Tab ====================
  
  Widget _buildAchievementsTab() {
    final achievements = _service.unlockedAchievements;
    final allAchievements = _getAllAchievements();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConstants.primary.withValues(alpha: 0.1),
                  ThemeConstants.primaryLight.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeConstants.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: ThemeConstants.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإنجازات المفتوحة',
                        style: context.titleMedium?.copyWith(
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                      Text(
                        '${achievements.length} من ${allAchievements.length}',
                        style: context.bodyLarge?.copyWith(
                          color: ThemeConstants.primary,
                          fontWeight: ThemeConstants.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: achievements.length / allAchievements.length,
                  backgroundColor: ThemeConstants.primary.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(ThemeConstants.primary),
                  strokeWidth: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Achievements Grid
          Text(
            'جميع الإنجازات',
            style: context.titleMedium?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              return AchievementCard(
                achievement: achievement,
                onTap: () => _showAchievementDetails(achievement),
              );
            },
          ),
        ],
      ),
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
  
  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة';
    } else {
      return 'قريباً';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
  
  void _showDayDetails(DateTime date) {
    final activity = _heatmapData[date] ?? 0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'نشاط يوم ${date.day}/${date.month}/${date.year}',
              style: context.titleLarge?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.trending_up, size: 32, color: ThemeConstants.primary),
                    const SizedBox(height: 8),
                    Text(
                      '$activity',
                      style: context.headlineMedium?.copyWith(
                        color: ThemeConstants.primary,
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                    Text(
                      'نشاط',
                      style: context.labelMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getAchievementIcon(achievement.category),
              color: _getAchievementColor(achievement.category),
            ),
            const SizedBox(width: 12),
            Text(achievement.title),
          ],
        ),
        content: Text(achievement.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  IconData _getAchievementIcon(AchievementCategory category) {
    switch (category) {
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
  
  Color _getAchievementColor(AchievementCategory category) {
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
  
  List<Achievement> _getAllAchievements() {
    // This should come from the service
    return [
      Achievement(
        id: 'first_athkar',
        title: 'البداية المباركة',
        description: 'أكمل أول فئة أذكار',
        iconAsset: '',
        category: AchievementCategory.athkar,
        requiredPoints: 0,
        level: 1,
        unlockedAt: DateTime.now(),
      ),
      // Add more achievements...
    ];
  }
}