// lib/features/athkar/screens/athkar_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../app/routes/app_router.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../services/athkar_service.dart';
import '../models/athkar_model.dart';
import '../widgets/athkar_category_card.dart';
import 'notification_settings_screen.dart';
// استيراد نظام الإحصائيات
import '../../statistics/screens/statistics_dashboard_screen.dart';
import '../../statistics/services/statistics_service.dart';
import '../../statistics/models/statistics_models.dart';

class AthkarCategoriesScreen extends StatefulWidget {
  const AthkarCategoriesScreen({super.key});

  @override
  State<AthkarCategoriesScreen> createState() => _AthkarCategoriesScreenState();
}

class _AthkarCategoriesScreenState extends State<AthkarCategoriesScreen> 
    with SingleTickerProviderStateMixin {
  late final AthkarService _service;
  late final PermissionService _permissionService;
  late final StorageService _storage;
  StatisticsService? _statsService;
  
  late Future<List<AthkarCategory>> _futureCategories;
  bool _notificationsEnabled = false;
  
  // خريطة التقدم لكل فئة (categoryId -> percentage)
  final Map<String, int> _progressMap = {};
  bool _progressLoading = true;
  
  // إحصائيات اليوم
  DailyStatistics? _todayStats;
  int _currentStreak = 0;
  
  // للأنيميشن
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _permissionService = getIt<PermissionService>();
    _storage = getIt<StorageService>();
    
    // تهيئة خدمة الإحصائيات إذا كانت متاحة
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService = getIt<StatisticsService>();
      _loadStatistics();
    }
    
    // تهيئة الأنيميشن
    _animationController = AnimationController(
      duration: ThemeConstants.durationNormal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _initialize();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _futureCategories = _service.loadCategories();
    _checkNotificationPermission();
    await _loadProgress();
    
    // مزامنة مع نظام الإحصائيات
    await _service.syncWithStatisticsService();
  }

  void _loadStatistics() {
    if (_statsService != null) {
      setState(() {
        _todayStats = _statsService!.getTodayStatistics();
        _currentStreak = _statsService!.currentStreak;
      });
      
      // الاستماع للتغييرات
      _statsService!.addListener(_onStatsChanged);
    }
  }
  
  void _onStatsChanged() {
    if (mounted && _statsService != null) {
      setState(() {
        _todayStats = _statsService!.getTodayStatistics();
        _currentStreak = _statsService!.currentStreak;
      });
    }
  }

  Future<void> _loadProgress() async {
    try {
      setState(() {
        _progressLoading = true;
      });

      final categories = await _futureCategories;
      final progressMap = <String, int>{};
     
      for (final category in categories) {
        // حساب التقدم الإجمالي بناءً على العدد الفعلي للأذكار المكررة
        int totalCompleted = 0;
        int totalRequired = 0;
       
        // تحميل البيانات المحفوظة لكل فئة
        final key = 'athkar_progress_${category.id}';
        final savedData = _storage.getMap(key);
        final savedProgress = savedData?.map((k, v) => MapEntry(int.parse(k), v as int)) ?? <int, int>{};
       
        for (final item in category.athkar) {
          final currentCount = savedProgress[item.id] ?? 0;
          totalCompleted += currentCount.clamp(0, item.count);
          totalRequired += item.count;
        }
       
        // حساب النسبة المئوية للتقدم الإجمالي
        final percentage = totalRequired > 0 ? ((totalCompleted / totalRequired) * 100).round() : 0;
        progressMap[category.id] = percentage;
      }
     
      if (mounted) {
        setState(() {
          _progressMap.clear();
          _progressMap.addAll(progressMap);
          _progressLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
      if (mounted) {
        setState(() {
          _progressLoading = false;
        });
      }
    }
  }

  Future<void> _checkNotificationPermission() async {
    final status = await _permissionService.checkPermissionStatus(
      AppPermissionType.notification,
    );
    if (mounted) {
      setState(() {
        _notificationsEnabled = status == AppPermissionStatus.granted;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureCategories = _service.loadCategories();
    });
    await _loadProgress();
    
    // إعادة المزامنة مع الإحصائيات
    await _service.syncWithStatisticsService();
    
    // إعادة تحميل الإحصائيات
    if (_statsService != null) {
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Custom AppBar محسن
              _buildCustomAppBar(context),
              
              // باقي المحتوى
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: ThemeConstants.primary,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // مساحة علوية
                      const SliverPadding(
                        padding: EdgeInsets.only(top: ThemeConstants.space2),
                      ),
                      
                      // العنوان التوضيحي مع إحصائيات سريعة
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space4,
                            vertical: ThemeConstants.space2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اختر فئة الأذكار',
                                style: context.titleLarge?.copyWith(
                                  fontWeight: ThemeConstants.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              ThemeConstants.space1.h,
                              Text(
                                'اقرأ الأذكار اليومية وحافظ على ذكر الله في كل وقت',
                                style: context.bodyMedium?.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                              ),
                              
                              // إحصائيات سريعة
                              if (!_progressLoading && _progressMap.isNotEmpty) ...[
                                ThemeConstants.space4.h,
                                _buildQuickStats(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // قائمة الفئات
                      FutureBuilder<List<AthkarCategory>>(
                        future: _futureCategories,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SliverFillRemaining(
                              child: Center(
                                child: AppLoading.page(
                                  message: 'جاري تحميل الأذكار...',
                                ),
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return SliverFillRemaining(
                              child: AppEmptyState.error(
                                message: 'حدث خطأ في تحميل البيانات',
                                onRetry: _refreshData,
                              ),
                            );
                          }
                          
                          final categories = snapshot.data ?? [];
                          
                          if (categories.isEmpty) {
                            return SliverFillRemaining(
                              child: AppEmptyState.noData(
                                message: 'لا توجد أذكار متاحة حالياً',
                              ),
                            );
                          }
                          
                          return SliverPadding(
                            padding: const EdgeInsets.all(ThemeConstants.space4),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: ThemeConstants.space4,
                                crossAxisSpacing: ThemeConstants.space4,
                                childAspectRatio: 0.8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final category = categories[index];
                                  final progress = _progressMap[category.id] ?? 0;
                                  
                                  return AthkarCategoryCardWithProgress(
                                    category: category,
                                    progress: progress,
                                    isProgressLoading: _progressLoading,
                                    onTap: () => _openCategoryDetails(category),
                                  );
                                },
                                childCount: categories.length,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // مساحة إضافية
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: ThemeConstants.space8),
                      ),
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

  Widget _buildQuickStats() {
    final completedCategories = _progressMap.values.where((p) => p >= 100).length;
    final inProgressCategories = _progressMap.values.where((p) => p > 0 && p < 100).length;
    final totalCategories = _progressMap.length;
    final averageProgress = totalCategories > 0 
        ? _progressMap.values.reduce((a, b) => a + b) ~/ totalCategories 
        : 0;

    return Column(
      children: [
        // بطاقة الإحصائيات المحلية
        AppCard(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space2),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: ThemeConstants.primary,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                  ThemeConstants.space3.w,
                  Text(
                    'إحصائيات الأذكار',
                    style: context.titleMedium?.copyWith(
                      fontWeight: ThemeConstants.semiBold,
                    ),
                  ),
                  const Spacer(),
                  // زر الذهاب للإحصائيات التفصيلية
                  if (_statsService != null)
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsDashboardScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space3,
                            vertical: ThemeConstants.space2,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConstants.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                            border: Border.all(
                              color: ThemeConstants.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'المزيد',
                                style: context.labelMedium?.copyWith(
                                  color: ThemeConstants.primary,
                                  fontWeight: ThemeConstants.semiBold,
                                ),
                              ),
                              ThemeConstants.space1.w,
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: ThemeConstants.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              ThemeConstants.space4.h,
              
              // الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: _QuickStatItem(
                      icon: Icons.check_circle_rounded,
                      count: completedCategories,
                      label: 'مكتملة',
                      color: ThemeConstants.success,
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: context.dividerColor,
                  ),
                  
                  Expanded(
                    child: _QuickStatItem(
                      icon: Icons.trending_up_rounded,
                      count: inProgressCategories,
                      label: 'قيد التقدم',
                      color: ThemeConstants.warning,
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: context.dividerColor,
                  ),
                  
                  Expanded(
                    child: _QuickStatItem(
                      icon: Icons.percent_rounded,
                      count: averageProgress,
                      label: 'متوسط التقدم',
                      color: ThemeConstants.primary,
                      isPercentage: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // إحصائيات اليوم من نظام الإحصائيات الموحد
        if (_todayStats != null) ...[
          ThemeConstants.space3.h,
          _buildTodayStatsCard(),
        ],
      ],
    );
  }

  Widget _buildTodayStatsCard() {
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
              _MiniStatItem(
                icon: Icons.menu_book,
                value: '${_todayStats?.athkarCompleted ?? 0}',
                label: 'أذكار',
                color: ThemeConstants.primary,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _MiniStatItem(
                icon: Icons.radio_button_checked,
                value: '${_todayStats?.tasbihCount ?? 0}',
                label: 'تسبيح',
                color: ThemeConstants.accent,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _MiniStatItem(
                icon: Icons.local_fire_department,
                value: '$_currentStreak',
                label: 'سلسلة',
                color: ThemeConstants.error,
              ),
              
              Container(
                width: 1,
                height: 30,
                color: context.dividerColor,
              ),
              
              _MiniStatItem(
                icon: Icons.star,
                value: '${_todayStats?.totalPoints ?? 0}',
                label: 'نقاط',
                color: ThemeConstants.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // الأيقونة الجانبية مع تدرج لوني
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.accent, ThemeConstants.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // العنوان والوصف
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أذكار المسلم',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'اذكر الله كثيراً',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // زر الإحصائيات
          if (_statsService != null)
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsDashboardScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(ThemeConstants.space2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.primary.withValues(alpha: 0.1),
                          ThemeConstants.primaryLight.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                      border: Border.all(
                        color: ThemeConstants.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: ThemeConstants.primary,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                ),
              ),
            ),
          
          // زر إعدادات الإشعارات
          Container(
            margin: const EdgeInsets.only(left: ThemeConstants.space2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AthkarNotificationSettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    border: Border.all(
                      color: context.dividerColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: context.textPrimaryColor,
                        size: ThemeConstants.iconMd,
                      ),
                      if (_notificationsEnabled)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: ThemeConstants.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.backgroundColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCategoryDetails(AthkarCategory category) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRouter.athkarDetails,
      arguments: category.id,
    ).then((_) {
      // إعادة تحميل التقدم عند العودة من صفحة التفاصيل
      _loadProgress();
      
      // تحديث الإحصائيات
      if (_statsService != null) {
        _loadStatistics();
      }
    });
  }
}

// ويدجت عنصر الإحصائيات السريعة
class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final bool isPercentage;

  const _QuickStatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space2),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: ThemeConstants.iconSm,
            ),
          ),
          ThemeConstants.space2.h,
          AnimatedSwitcher(
            duration: ThemeConstants.durationFast,
            child: Text(
              isPercentage ? '$count%' : '$count',
              key: ValueKey('$count'),
              style: context.titleMedium?.copyWith(
                color: color,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
          Text(
            label,
            style: context.labelSmall?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ويدجت عنصر إحصائيات صغير
class _MiniStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatItem({
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

// ويدجت بطاقة الفئة مع التقدم
class AthkarCategoryCardWithProgress extends StatelessWidget {
  final AthkarCategory category;
  final int progress;
  final bool isProgressLoading;
  final VoidCallback onTap;

  const AthkarCategoryCardWithProgress({
    super.key,
    required this.category,
    required this.progress,
    required this.isProgressLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'category_${category.id}',
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // البطاقة الأساسية
            AthkarCategoryCard(
              category: category,
              onTap: onTap,
            ),
            
            // مؤشر التقدم الدائري على اليسار
            if (!isProgressLoading)
              Positioned(
                top: ThemeConstants.space3,
                left: ThemeConstants.space3,
                child: _buildProgressIndicator(context),
              ),
            
            // مؤشر التحميل
            if (isProgressLoading)
              Positioned(
                top: ThemeConstants.space3,
                left: ThemeConstants.space3,
                child: _buildLoadingIndicator(),
              ),
            
            // شارة الإكمال
            if (progress >= 100)
              Positioned(
                top: ThemeConstants.space2,
                right: ThemeConstants.space2,
                child: _buildCompletionBadge(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final effectiveColor = _getProgressColor(progress);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة التقدم الخلفية
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          
          // دائرة التقدم الفعلية
          SizedBox(
            width: 50,
            height: 50,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress / 100),
              duration: ThemeConstants.durationSlow,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveColor,
                  ),
                );
              },
            ),
          ),
          
          // النسبة المئوية
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: ThemeConstants.durationFast,
                child: Text(
                  '$progress%',
                  key: ValueKey('progress_$progress'),
                  style: context.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (progress > 0)
                Icon(
                  _getProgressIcon(progress),
                  color: Colors.white,
                  size: 12,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space1),
      decoration: BoxDecoration(
        color: ThemeConstants.success,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.success.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 100) {
      return ThemeConstants.success;
    } else if (progress >= 75) {
      return Colors.lightGreen;
    } else if (progress >= 50) {
      return ThemeConstants.warning;
    } else if (progress >= 25) {
      return Colors.orange;
    } else if (progress > 0) {
      return ThemeConstants.info;
    } else {
      return Colors.white.withValues(alpha: 0.5);
    }
  }

  IconData _getProgressIcon(int progress) {
    if (progress >= 100) {
      return Icons.check_rounded;
    } else if (progress >= 50) {
      return Icons.trending_up_rounded;
    } else if (progress > 0) {
      return Icons.play_arrow_rounded;
    } else {
      return Icons.radio_button_unchecked_rounded;
    }
  }
}