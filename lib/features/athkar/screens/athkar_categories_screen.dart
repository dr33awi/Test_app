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

class AthkarCategoriesScreen extends StatefulWidget {
  const AthkarCategoriesScreen({super.key});

  @override
  State<AthkarCategoriesScreen> createState() => _AthkarCategoriesScreenState();
}

class _AthkarCategoriesScreenState extends State<AthkarCategoriesScreen> {
  late final AthkarService _service;
  late final PermissionService _permissionService;
  late final StorageService _storage;
  
  late Future<List<AthkarCategory>> _futureCategories;
  bool _notificationsEnabled = false;
  
  // خريطة التقدم لكل فئة (categoryId -> percentage)
  final Map<String, int> _progressMap = {};
  bool _progressLoading = true;

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _permissionService = getIt<PermissionService>();
    _storage = getIt<StorageService>();
    
    _initialize();
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
        child: Column(
          children: [
            // Custom AppBar محسن
            _buildCustomAppBar(context),
            
            // باقي المحتوى
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
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
    );
  }

  Widget _buildQuickStats() {
    final completedCategories = _progressMap.values.where((p) => p >= 100).length;
    final inProgressCategories = _progressMap.values.where((p) => p > 0 && p < 100).length;
    final totalCategories = _progressMap.length;
    final averageProgress = totalCategories > 0 
        ? _progressMap.values.reduce((a, b) => a + b) ~/ totalCategories 
        : 0;

    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: ThemeConstants.primary,
                size: ThemeConstants.iconMd,
              ),
              ThemeConstants.space2.w,
              Text(
                'إحصائياتك',
                style: context.titleMedium?.copyWith(
                  fontWeight: ThemeConstants.semiBold,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space3.h,
          
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
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
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
                  child: Icon(
                    Icons.notifications_outlined,
                    color: context.textPrimaryColor,
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
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ThemeConstants.iconSm,
        ),
        ThemeConstants.space1.h,
        Text(
          isPercentage ? '$count%' : '$count',
          style: context.titleMedium?.copyWith(
            color: color,
            fontWeight: ThemeConstants.bold,
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
    return Stack(
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
            child: Container(
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
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  
                  // النسبة المئوية
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$progress%',
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                          fontSize: 14,
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
            ),
          ),
        
        // مؤشر التحميل
        if (isProgressLoading)
          Positioned(
            top: ThemeConstants.space3,
            left: ThemeConstants.space3,
            child: Container(
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
            ),
          ),
      ],
    );
  }

  Object _getProgressColor(int progress) {
    if (progress >= 100) {
      return ThemeConstants.success;
    } else if (progress >= 50) {
      return ThemeConstants.warning;
    } else if (progress > 0) {
      return ThemeConstants.info;
    } else {
      return ThemeConstants.textSecondary;
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

extension on Object {
  withValues({required double alpha}) {}
}