// lib/features/athkar/screens/athkar_details_screen.dart (مُحدث بدون شريط التقدم)
import 'package:athkar_app/features/athkar/utils/athkar_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/utils/extensions/string_extensions.dart';
import '../services/athkar_service.dart';
import '../models/athkar_model.dart';
import '../widgets/athkar_item_card.dart';
import '../utils/category_utils.dart';
import 'notification_settings_screen.dart';


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
  
  AthkarCategory? _category;
  final Map<int, int> _counts = {};
  final Set<int> _completedItems = {};
  List<AthkarItem> _visibleItems = [];
  bool _loading = true;
  bool _allCompleted = false;
  bool _wasCompletedOnLoad = false;
  double _fontSize = 18.0; // حجم الخط

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _storage = getIt<StorageService>();
    _load();
  }

  @override
  void dispose() {
    // Auto-reset if category was completed and user is navigating back
    if (_allCompleted && !_wasCompletedOnLoad) {
      _resetAllSilently();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cat = await _service.getCategoryById(widget.categoryId);
      if (!mounted) return;
      
      // تحميل التقدم المحفوظ
      final savedProgress = _loadSavedProgress();
      
      // تحميل حجم الخط المحفوظ
      _fontSize = await _service.getSavedFontSize();
      
      // Check if category was already completed when loading
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
          // تهيئة العدادات
          for (var i = 0; i < cat.athkar.length; i++) {
            final item = cat.athkar[i];
            _counts[item.id] = savedProgress[item.id] ?? 0;
            if (_counts[item.id]! >= item.count) {
              _completedItems.add(item.id);
            }
          }
          _updateVisibleItems();
          _checkCompletion();
        }
        _loading = false;
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في تحميل الأذكار'),
          backgroundColor: ThemeConstants.error,
        ),
      );
    }
  }

  void _updateVisibleItems() {
    if (_category == null) return;
    
    // عرض فقط الأذكار غير المكتملة
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

  void _checkCompletion() {
    if (_category == null) return;
    
    int completed = 0;
    int total = 0;
    
    for (final item in _category!.athkar) {
      final count = _counts[item.id] ?? 0;
      completed += count.clamp(0, item.count);
      total += item.count;
    }
    
    setState(() {
      _allCompleted = completed >= total && total > 0;
    });
  }

  void _onItemTap(AthkarItem item) {
    HapticFeedback.lightImpact();
    
    setState(() {
      final currentCount = _counts[item.id] ?? 0;
      if (currentCount < item.count) {
        _counts[item.id] = currentCount + 1;
        
        // إضافة للمكتملة إذا وصلت للعدد المطلوب
        if (_counts[item.id]! >= item.count) {
          _completedItems.add(item.id);
          HapticFeedback.mediumImpact();
          _updateVisibleItems(); // إخفاء الذكر المكتمل
        }
      }
      _checkCompletion();
    });
    
    _saveProgress();
  }

  void _onItemLongPress(AthkarItem item) {
    HapticFeedback.mediumImpact();
    
    // إعادة تعيين العداد
    setState(() {
      _counts[item.id] = 0;
      _completedItems.remove(item.id);
      _updateVisibleItems();
      _checkCompletion();
    });
    
    _saveProgress();
    context.showAthkarInfoSnackBar('تم إعادة تعيين العداد');
  }

  Future<void> _shareProgress() async {
    // مشاركة التقدم
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
      _wasCompletedOnLoad = false;
      _updateVisibleItems();
    });
    _saveProgress();
  }

  // Silent reset method that doesn't update UI
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

  // إظهار حوار حجم الخط
  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        title: Row(
          children: [
            const Icon(
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

  // بناء خيار حجم الخط
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
            
            // حفظ حجم الخط المختار
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
              // Custom AppBar
              _buildCustomAppBar(context, 'جاري تحميل الأذكار...'),
              
              // Loading content
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
              // Custom AppBar
              _buildCustomAppBar(context, 'الأذكار'),
              
              // Error content
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
            // Custom AppBar
            _buildCustomAppBar(context, category.title, category: category),
            
            // قائمة الأذكار
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
          // زر الرجوع
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // الأيقونة الجانبية
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
          
          // العنوان والوصف
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
                    '${category.athkar.length} ذكر - ${_completedItems.length} مكتمل',
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
          
          // الأزرار
          if (category != null) ...[
            // زر حجم الخط
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
        ],
      ),
    );
  }

  Widget _buildContent(AthkarCategory category) {
    if (_visibleItems.isEmpty && _completedItems.isNotEmpty) {
      // عرض رسالة الإكمال
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
    
    // عرض الأذكار
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        itemCount: _visibleItems.length,
        itemBuilder: (context, index) {
          final item = _visibleItems[index];
          final currentCount = _counts[item.id] ?? 0;
          final isCompleted = _completedItems.contains(item.id);
          
          // إيجاد الفهرس الأصلي
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