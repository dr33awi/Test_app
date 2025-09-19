// lib/features/dua/screens/dua_categories_screen.dart - محسن ومتناسق
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/dua_service.dart';
import '../models/dua_model.dart';
import 'dua_details_screen.dart';

class DuaCategoriesScreen extends StatefulWidget {
  const DuaCategoriesScreen({super.key});

  @override
  State<DuaCategoriesScreen> createState() => _DuaCategoriesScreenState();
}

class _DuaCategoriesScreenState extends State<DuaCategoriesScreen> {
  late final DuaService _duaService;
  
  List<DuaCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _duaService = getService<DuaService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // تحميل البيانات
      _categories = await _duaService.getCategories();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحميل البيانات');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // شريط التطبيق المحسن (متناسق مع أسماء الله الحسنى)
            _buildEnhancedAppBar(),
            
            // المحتوى الرئيسي
            Expanded(
              child: _isLoading ? _buildLoading() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع (متناسق مع أسماء الله الحسنى)
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // أيقونة مميزة (نفس ستايل أسماء الله الحسنى)
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
              Icons.pan_tool_rounded,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // معلومات العنوان
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأدعية المأثورة',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'أدعية من الكتاب والسنة',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: ThemeConstants.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: ThemeConstants.primary,
              strokeWidth: 3,
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل الأدعية...',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'يرجى الانتظار قليلاً',
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_categories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // عداد الفئات
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space2,
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_rounded,
                size: 16,
                color: context.textSecondaryColor,
              ),
              ThemeConstants.space1.w,
              Text(
                'عدد الفئات: ${_categories.length}',
                style: context.labelMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // قائمة الفئات المضغوطة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: ThemeConstants.space2),
                child: _buildCompactCategoryCard(category, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space6),
            decoration: BoxDecoration(
              color: context.textSecondaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 60,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'لا توجد فئات',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'لم يتم العثور على فئات الأدعية',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space6.h,
          ElevatedButton.icon(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space6,
                vertical: ThemeConstants.space3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCategoryCard(DuaCategory category, int index) {
    final color = _getCategoryColor(category.type);
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      child: InkWell(
        onTap: () => _onCategoryPressed(category),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.space3),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // الرقم مع الخلفية الملونة
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(category.type),
                  color: _shouldUseWhiteIcon(category.type) ? Colors.white : Colors.black87,
                  size: 20,
                ),
              ),
              
              ThemeConstants.space3.w,
              
              // محتوى الفئة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم الفئة
                    Text(
                      category.name,
                      style: context.titleMedium?.copyWith(
                        color: color,
                        fontWeight: ThemeConstants.bold,
                        fontFamily: ThemeConstants.fontFamilyArabic,
                      ),
                    ),
                    
                    ThemeConstants.space1.h,
                    
                    // وصف الفئة
                    Text(
                      category.description,
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    ThemeConstants.space1.h,
                    
                    // عدد الأدعية
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          size: 12,
                          color: ThemeConstants.accent,
                        ),
                        ThemeConstants.space1.w,
                        Text(
                          '${category.duaCount} دعاء',
                          style: context.labelSmall?.copyWith(
                            color: ThemeConstants.accent,
                            fontWeight: ThemeConstants.medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // أيقونة التفاعل
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldUseWhiteIcon(DuaType type) {
    // الألوان الداكنة تحتاج أيقونة بيضاء
    // الألوان الفاتحة تحتاج أيقونة داكنة
    switch (type) {
      case DuaType.morning:
        return false; // ذهبي فاتح - أيقونة داكنة
      case DuaType.evening:
        return true; // بني داكن - أيقونة بيضاء  
      case DuaType.prayer:
        return true; // أزرق - أيقونة بيضاء
      case DuaType.sleep:
        return true; // رمادي - أيقونة بيضاء
      case DuaType.protection:
        return true; // أخضر - أيقونة بيضاء
      case DuaType.food:
        return true; // بني - أيقونة بيضاء
      case DuaType.travel:
        return true; // أخضر زيتي - أيقونة بيضاء
      default:
        return true; // افتراضي - أيقونة بيضاء
    }
  }

  Color _getCategoryColor(DuaType type) {
    switch (type) {
      case DuaType.morning:
        return const Color(0xFFDAA520); // ذهبي فاتح كالشروق
      case DuaType.evening:
        return const Color(0xFF8B6F47); // بني دافئ كالغروب
      case DuaType.prayer:
        return ThemeConstants.primary; // الأساسي
      case DuaType.sleep:
        return const Color(0xFF2D352D); // داكن للليل
      case DuaType.protection:
        return ThemeConstants.accent; // الثانوي
      case DuaType.food:
        return ThemeConstants.tertiary; // الثالث
      case DuaType.travel:
        return const Color(0xFF7A8B6F); // أخضر زيتي فاتح
      default:
        return ThemeConstants.primary; // افتراضي
    }
  }

  IconData _getCategoryIcon(DuaType type) {
    switch (type) {
      case DuaType.general:
        return Icons.auto_awesome;
      case DuaType.morning:
        return Icons.wb_sunny_rounded;
      case DuaType.evening:
        return Icons.nights_stay_rounded;
      case DuaType.prayer:
        return Icons.mosque_rounded;
      case DuaType.food:
        return Icons.restaurant_rounded;
      case DuaType.travel:
        return Icons.flight_takeoff_rounded;
      case DuaType.sleep:
        return Icons.bedtime_rounded;
      case DuaType.protection:
        return Icons.shield_rounded;
      case DuaType.forgiveness:
        return Icons.favorite_rounded;
      case DuaType.gratitude:
        return Icons.celebration_rounded;
      case DuaType.guidance:
        return Icons.explore_rounded;
      case DuaType.health:
        return Icons.healing_rounded;
      case DuaType.wealth:
        return Icons.attach_money_rounded;
      case DuaType.knowledge:
        return Icons.school_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  void _onCategoryPressed(DuaCategory category) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DuaDetailsScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}