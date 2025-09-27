// lib/features/home/widgets/category_grid.dart - مُحدث مع المسار الصحيح

import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryGrid extends StatefulWidget {
  const CategoryGrid({super.key});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {

  // بيانات ثابتة للأداء مع المسار الصحيح لأسماء الله الحسنى
  static const List<CategoryItem> _categories = [
    CategoryItem(
      id: 'prayer_times',
      title: 'مواقيت الصلاة',
      subtitle: 'أوقات الصلوات الخمس',
      icon: Icons.mosque,
      routeName: '/prayer-times',
      progress: 0.8,
      isInDevelopment: false,
    ),
    CategoryItem(
      id: 'athkar',
      title: 'الأذكار اليومية',
      subtitle: 'أذكار الصباح والمساء',
      icon: Icons.auto_awesome,
      routeName: '/athkar',
      progress: 0.6,
      isInDevelopment: false,
    ),
    CategoryItem(
      id: 'asma_allah',  
      title: 'أسماء الله الحسنى',  
      subtitle: 'الأسماء والصفات',  
      icon: Icons.star_purple500_outlined,  
      routeName: '/asma-allah',  // المسار الصحيح مع الشرطة
      progress: 0.4,
      isInDevelopment: false,  // معطلة مؤقتاً
    ),
    CategoryItem(
      id: 'qibla',
      title: 'اتجاه القبلة',
      subtitle: 'البوصلة الذكية',
      icon: Icons.explore,
      routeName: '/qibla',
      progress: 1.0,
      isInDevelopment: false,
    ),
    CategoryItem(
      id: 'tasbih',
      title: 'المسبحة الرقمية',
      subtitle: 'عداد التسبيح',
      icon: Icons.radio_button_checked,
      routeName: '/tasbih',
      progress: 0.9,
      isInDevelopment: false,
    ),
    CategoryItem(
      id: 'dua',
      title: 'الأدعية المأثورة',
      subtitle: 'أدعية من الكتاب والسنة',
      icon: Icons.pan_tool_rounded,
      routeName: '/dua',
      progress: 0.8,
      isInDevelopment: false,
    ),
  ];

  void _onCategoryTap(CategoryItem category) {
    HapticFeedback.lightImpact();
    
    // إذا كانت الفئة قيد التطوير، اعرض رسالة خاصة
    if (category.isInDevelopment) {
      _showDevelopmentDialog(category);
      return;
    }
    
    if (category.routeName != null) {
      Navigator.pushNamed(context, category.routeName!).catchError((error) {
        if (mounted) {
          context.showWarningSnackBar('هذه الميزة قيد التطوير');
        }
        return null;
      });
    }
  }

  void _showDevelopmentDialog(CategoryItem category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.construction,
              color: ThemeConstants.warning,
              size: ThemeConstants.iconLg,
            ),
            ThemeConstants.space3.w,
            Text(
              category.title,
              style: context.titleLarge?.copyWith(
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space3),
              decoration: BoxDecoration(
                color: ThemeConstants.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                border: Border.all(
                  color: ThemeConstants.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ThemeConstants.warning,
                    size: ThemeConstants.iconMd,
                  ),
                  ThemeConstants.space2.w,
                  Expanded(
                    child: Text(
                      'هذه الميزة معطلة مؤقتاً للصيانة والتطوير',
                      style: context.bodyMedium?.copyWith(
                        color: ThemeConstants.warning.darken(0.2),
                        fontWeight: ThemeConstants.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ThemeConstants.space3.h,
            Text(
              'نعمل حالياً على تطوير وتحسين هذه الخدمة لتقديم أفضل تجربة ممكنة.',
              style: context.bodyMedium,
            ),
            ThemeConstants.space3.h,
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space3),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: context.primaryColor,
                    size: ThemeConstants.iconMd,
                  ),
                  ThemeConstants.space2.w,
                  Expanded(
                    child: Text(
                      'ستكون متوفرة قريباً بإذن الله',
                      style: context.bodyMedium?.copyWith(
                        color: context.primaryColor,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.space4),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // الصف الأول: المفضلة وإنجاز اليوم
          Row(
            children: [
              // المفضلة (عريضة)
              Expanded(
                flex: 2,
                child: _buildCategoryItem(context, _categories[4]), // tasbih
              ),
              ThemeConstants.space4.w,
              // إنجاز اليوم (مربعة)
              Expanded(
                child: _buildSquareCategoryItem(context, _categories[1]), // athkar
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // الصف الثاني: أسماء الله الحسنى ومواقيت الصلاة
          Row(
            children: [
              // أسماء الله الحسنى (مربعة)
              Expanded(
                child: _buildSquareCategoryItem(context, _categories[2]), // asma_allah
              ),
              ThemeConstants.space4.w,
              // مواقيت الصلاة (عريضة)
              Expanded(
                flex: 2,
                child: _buildCategoryItem(context, _categories[0]), // prayer_times
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // الصف الثالث: اتجاه القبلة والأدعية
          Row(
            children: [
              // اتجاه القبلة
              Expanded(
                child: _buildCategoryItem(context, _categories[3]), // qibla
              ),
              ThemeConstants.space4.w,
              // الأدعية
              Expanded(
                child: _buildCategoryItem(context, _categories[5]), // dua
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildSquareCategoryItem(BuildContext context, CategoryItem category) {
    // حساب الألوان مرة واحدة
    final gradient = category.isInDevelopment 
        ? _getDevelopmentGradient() 
        : AppColors.getCategoryGradient(category.id);
    
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: InkWell(
          onTap: () => _onCategoryTap(category),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الأيقونة
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        category.isInDevelopment ? Icons.construction : category.icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // العنوان
                    Text(
                      category.title,
                      style: context.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: ThemeConstants.bold,
                        fontSize: 16,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                // شارة "قيد التطوير"
                if (category.isInDevelopment)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.warning,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeConstants.warning.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'قيد التطوير',
                        style: context.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryItem category) {
    // حساب الألوان مرة واحدة
    final gradient = category.isInDevelopment 
        ? _getDevelopmentGradient() 
        : AppColors.getCategoryGradient(category.id);
    
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: InkWell(
          onTap: () => _onCategoryTap(category),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الأيقونة
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        category.isInDevelopment ? Icons.construction : category.icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // النص والتقدم
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // العنوان
                          Text(
                            category.title,
                            style: context.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: ThemeConstants.bold,
                              fontSize: 17,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // شريط التقدم
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: category.isInDevelopment 
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // شارة "قيد التطوير"
                if (category.isInDevelopment)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.warning,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeConstants.warning.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'قيد التطوير',
                        style: context.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تدرج لوني خاص بالعناصر قيد التطوير
  LinearGradient _getDevelopmentGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ThemeConstants.warning.withValues(alpha: 0.9),
        ThemeConstants.warning.darken(0.2).withValues(alpha: 0.9),
      ],
    );
  }
}

/// نموذج بيانات الفئة المحسن مع حالة التطوير
class CategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? routeName;
  final double progress;
  final bool isInDevelopment;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.routeName,
    required this.progress,
    this.isInDevelopment = false,
  });
}