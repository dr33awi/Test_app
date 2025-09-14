// lib/features/athkar/screens/athkar_details_screen.dart (محسن مع نظام الإحصائيات الموحد)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/themes/app_theme.dart';
// استخدام الـ widgets من athkar_extensions.dart مؤقتاً حتى يتم إنشاء ملفات app/themes
import '../utils/athkar_extensions.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/utils/extensions/string_extensions.dart';
import '../services/athkar_service.dart';
import '../models/athkar_model.dart';
import '../widgets/athkar_item_card.dart';
import '../widgets/athkar_progress_bar.dart';
import '../utils/category_utils.dart';
import '../utils/athkar_extensions.dart'; // فقط للـ helpers الخاصة بالأذكار
import 'notification_settings_screen.dart';
// نظام الإحصائيات الموحد
import '../../statistics/services/statistics_service.dart';

class AthkarDetailsScreen extends StatefulWidget {
  String categoryId;
  
  AthkarDetailsScreen({
    super.key,
    String? categoryId,
  }) : categoryId = categoryId ?? '';

  @override
  State<AthkarDetailsScreen> createState() => _AthkarDetailsScreenState();
}

class _AthkarDetailsScreenState extends State<AthkarDetailsScreen> {
  late final AthkarService _service;
  late final StorageService _storage;
  late final StatisticsService _statsService;
  
  AthkarCategory? _category;
  final Map<int, int> _counts = {};
  final Set<int> _completedItems = {};
  List<AthkarItem> _visibleItems = [];
  int _totalProgress = 0;
  bool _loading = true;
  bool _allCompleted = false;
  bool _wasCompletedOnLoad = false;
  double _fontSize = 18.0;
  
  // متغيرات تتبع الجلسة للإحصائيات
  DateTime? _sessionStartTime;
  int _sessionItemsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _storage = getIt<StorageService>();
    
    // استخدام Provider للإحصائيات
    _statsService = getIt<StatisticsService>();
    
    _load();
  }

  @override
  void dispose() {
    _endSession();
    
    if (_allCompleted && !_wasCompletedOnLoad) {
      _resetAllSilently();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cat = await _service.getCategoryById(widget.categoryId);
      if (!mounted) return;
      
      if (cat != null) {
        _startSession();
      }
      
      final savedProgress = _loadSavedProgress();
      _fontSize = await _service.getSavedFontSize();
      
      bool wasAlreadyCompleted = false;
      if (cat != null) {
        int totalRequired = 0;
        int totalCompleted = 0;
        
        for (var item in cat.athkar) {
          totalRequired += item.count;
          final completed = savedProgress[item.id] ?? 0;
          totalCompleted += completed.clamp(0, item.count);
        }
        
        wasAlreadyCompleted = totalCompleted >= totalRequired && totalRequired > 0;
      }
      
      setState(() {
        _category = cat;
        _wasCompletedOnLoad = wasAlreadyCompleted;
        
        if (cat != null) {
          for (var i = 0; i < cat.athkar.length; i++) {
            final item = cat.athkar[i];
            _counts[item.id] = savedProgress[item.id] ?? 0;
            if (_counts[item.id]! >= item.count) {
              _completedItems.add(item.id);
            }
          }
          _updateVisibleItems();
          _calculateProgress();
        }
        _loading = false;
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      context.showErrorSnackBar('حدث خطأ في تحميل الأذكار');
    }
  }

  void _startSession() {
    _sessionStartTime = DateTime.now();
    _sessionItemsCompleted = 0;
  }

  Future<void> _endSession() async {
    if (_category == null || _sessionStartTime == null) return;
    
    final duration = DateTime.now().difference(_sessionStartTime!);
    final totalItems = _category!.athkar.length;
    
    // استخدام StatisticsService مباشرة
    await _statsService.recordAthkarActivity(
      categoryId: widget.categoryId,
      categoryName: _category!.title,
      itemsCompleted: _sessionItemsCompleted,
      totalItems: totalItems,
      duration: duration,
    );
    
    _sessionStartTime = null;
  }

  void _updateVisibleItems() {
    if (_category == null) return;
    
    _visibleItems = _category!.athkar
        .where((item) => !_completedItems.contains(item.id))
        .toList();
  }

  Map<int, int> _loadSavedProgress() {
    final key = 'athkar_progress_${widget.categoryId}';
    final data = _storage.getMap(key);
    if (data == null) return {};
    
    return data.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Future<void> _saveProgress() async {
    final key = 'athkar_progress_${widget.categoryId}';
    final data = _counts.map((k, v) => MapEntry(k.toString(), v));
    await _storage.setMap(key, data);
  }

  void _calculateProgress() {
    if (_category == null) return;
    
    int completed = 0;
    int total = 0;
    
    for (final item in _category!.athkar) {
      final count = _counts[item.id] ?? 0;
      completed += count.clamp(0, item.count);
      total += item.count;
    }
    
    setState(() {
      _totalProgress = total > 0 ? ((completed / total) * 100).round() : 0;
      _allCompleted = completed >= total && total > 0;
    });
  }

  void _onItemTap(AthkarItem item) {
    HapticFeedback.lightImpact();
    
    setState(() {
      final currentCount = _counts[item.id] ?? 0;
      if (currentCount < item.count) {
        _counts[item.id] = currentCount + 1;
        
        if (_counts[item.id]! >= item.count) {
          _completedItems.add(item.id);
          _sessionItemsCompleted++;
          HapticFeedback.mediumImpact();
          _updateVisibleItems();
          
          _recordSingleAthkarCompletion(item);
        }
      }
      _calculateProgress();
    });
    
    _saveProgress();
    
    if (_allCompleted && !_wasCompletedOnLoad) {
      _onCategoryCompleted();
    }
  }

  Future<void> _recordSingleAthkarCompletion(AthkarItem item) async {
    if (_category == null) return;
    
    // تسجيل إكمال ذكر واحد في الإحصائيات
    await _statsService.recordAthkarActivity(
      categoryId: widget.categoryId,
      categoryName: _category!.title,
      itemsCompleted: 1,
      totalItems: 1,
      duration: const Duration(seconds: 30),
    );
  }

  Future<void> _onCategoryCompleted() async {
    if (_category == null) return;
    
    await _endSession();
    _startSession();
    
    if (mounted) {
      context.showAthkarSuccessSnackBar('بارك الله فيك! أكملت ${_category!.title}');
    }
  }

  void _onItemLongPress(AthkarItem item) {
    HapticFeedback.mediumImpact();
    
    setState(() {
      if (_completedItems.contains(item.id)) {
        _sessionItemsCompleted = (_sessionItemsCompleted - 1).clamp(0, _category!.athkar.length);
      }
      
      _counts[item.id] = 0;
      _completedItems.remove(item.id);
      _updateVisibleItems();
      _calculateProgress();
    });
    
    _saveProgress();
    context.showAthkarInfoSnackBar('تم إعادة تعيين العداد');
  }

  Future<void> _shareProgress() async {
    final text = '''
✨ أكملت ${_category!.title} ✨
${_category!.athkar.map((item) => '✓ ${item.text.truncate(50)}').join('\n')}

تطبيق الأذكار
    ''';
    
    await Share.share(text);
  }

  void _resetAll() {
    setState(() {
      _counts.clear();
      _completedItems.clear();
      _allCompleted = false;
      _totalProgress = 0;
      _wasCompletedOnLoad = false;
      _sessionItemsCompleted = 0;
      _updateVisibleItems();
    });
    _saveProgress();
    
    _startSession();
  }

  Future<void> _resetAllSilently() async {
    _counts.clear();
    _completedItems.clear();
    final key = 'athkar_progress_${widget.categoryId}';
    await _storage.remove(key);
  }

  Future<void> _shareItem(AthkarItem item) async {
    final text = '''
${item.text}

${item.fadl != null ? 'الفضل: ${item.fadl}\n' : ''}
${item.source != null ? 'المصدر: ${item.source}' : ''}

تطبيق الأذكار
''';
    
    await Share.share(text);
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.text_fields_rounded,
              color: ThemeConstants.primary,
              size: 24,
            ),
            ThemeConstants.space2.w,
            const Text('حجم الخط'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('صغير', 16.0),
            _buildFontSizeOption('متوسط', 18.0),
            _buildFontSizeOption('كبير', 22.0),
            _buildFontSizeOption('كبير جداً', 26.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    final isSelected = _fontSize == size;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            setState(() => _fontSize = size);
            
            await _service.saveFontSize(size);
            
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? ThemeConstants.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? ThemeConstants.primary.withValues(alpha: 0.3)
                    : context.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? ThemeConstants.primary : context.textSecondaryColor,
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: Text(
                    label,
                    style: context.bodyLarge?.copyWith(
                      fontSize: size,
                      fontWeight: isSelected ? ThemeConstants.semiBold : ThemeConstants.regular,
                      color: isSelected ? ThemeConstants.primary : context.textPrimaryColor,
                    ),
                  ),
                ),
                Text(
                  '${size.toInt()}px',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context, 'جاري تحميل الأذكار...'),
              Expanded(
                child: Center(
                  child: AppLoading.page(
                    message: 'جاري تحميل الأذكار...',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_category == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context, 'الأذكار'),
              Expanded(
                child: AppEmptyState.error(
                  message: 'تعذر تحميل الأذكار المطلوبة',
                  onRetry: _load,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final category = _category!;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context, category.title, category: category),
            AthkarProgressBar(
              progress: _totalProgress,
              color: CategoryUtils.getCategoryThemeColor(category.id),
              completedCount: _completedItems.length,
              totalCount: category.athkar.length,
            ),
            Expanded(
              child: _buildContent(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, String title, {AthkarCategory? category}) {
    const gradient = LinearGradient(
      colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
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
              gradient: gradient,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              category?.icon ?? Icons.menu_book,
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
                  title,
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category != null)
                  Text(
                    'التقدم: ${_completedItems.length}/${category.athkar.length} - $_totalProgress%',
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  )
                else
                  Text(
                    'الأذكار والأدعية الإسلامية',
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          if (category != null) ...[
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showFontSizeDialog();
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
                      Icons.text_fields_rounded,
                      color: context.textPrimaryColor,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                ),
              ),
            ),
            
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
        ],
      ),
    );
  }

  Widget _buildContent(AthkarCategory category) {
    if (_visibleItems.isEmpty && _completedItems.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ThemeConstants.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeConstants.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: ThemeConstants.success,
                ),
              ),
              
              ThemeConstants.space6.h,
              
              Text(
                'أحسنت! أكملت جميع الأذكار',
                style: context.headlineSmall?.copyWith(
                  color: ThemeConstants.success,
                  fontWeight: ThemeConstants.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              ThemeConstants.space3.h,
              
              Text(
                'جعله الله في ميزان حسناتك',
                style: context.bodyLarge?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              ThemeConstants.space8.h,
              
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'مشاركة الإنجاز',
                      icon: Icons.share_rounded,
                      onPressed: _shareProgress,
                      color: ThemeConstants.success,
                    ),
                  ),
                  
                  ThemeConstants.space4.w,
                  
                  Expanded(
                    child: AppButton.primary(
                      text: 'البدء من جديد',
                      icon: Icons.refresh_rounded,
                      onPressed: _resetAll,
                      backgroundColor: ThemeConstants.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        itemCount: _visibleItems.length,
        itemBuilder: (context, index) {
          final item = _visibleItems[index];
          final currentCount = _counts[item.id] ?? 0;
          final isCompleted = _completedItems.contains(item.id);
          
          final originalIndex = category.athkar.indexOf(item);
          final number = originalIndex + 1;
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _visibleItems.length - 1
                  ? ThemeConstants.space3
                  : 0,
            ),
            child: AthkarItemCard(
              item: item,
              currentCount: currentCount,
              isCompleted: isCompleted,
              number: number,
              color: CategoryUtils.getCategoryThemeColor(category.id),
              fontSize: _fontSize,
              onTap: () => _onItemTap(item),
              onLongPress: () => _onItemLongPress(item),
              onShare: () => _shareItem(item),
            ),
          );
        },
      ),
    );
  }
}