// lib/features/athkar/screens/athkar_categories_screen.dart (محدث مع UnifiedStatsWidget)
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
// نظام الإحصائيات الموحد
import '../../statistics/screens/statistics_dashboard_screen.dart';
import '../../statistics/services/statistics_service.dart';
import '../../statistics/widgets/unified_stats_widget.dart';

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
  
  // للأنيميشن
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _permissionService = getIt<PermissionService>();
    _storage = getIt<StorageService>();
    
    // تهيئة خدمة الإحصائيات
    if (getIt.isRegistered<StatisticsService>()) {
      _statsService = getIt<StatisticsService>();
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
                      
                      // العنوان التوضيحي
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
                            ],
                          ),
                        ),
                      ),
                      
                      // لوحة الإحصائيات الموحدة
                      if (!_progressLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ThemeConstants.space4,
                              vertical: ThemeConstants.space3,
                            ),
                            child: UnifiedStatsWidget(
                              isCompact: true,
                              showDetailedStats: false,
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
    });
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