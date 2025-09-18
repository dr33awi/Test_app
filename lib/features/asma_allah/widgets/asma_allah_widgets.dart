// lib/features/asma_allah/widgets/asma_allah_widgets.dart - بدون بنفسجي
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import '../extensions/asma_allah_extensions.dart';

// ============================================================================
// UnifiedAsmaAllahCard - البطاقة الموحدة الجديدة
// ============================================================================
class UnifiedAsmaAllahCard extends StatefulWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  final bool showActions;

  const UnifiedAsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
    this.showActions = false,
  });

  @override
  State<UnifiedAsmaAllahCard> createState() => _UnifiedAsmaAllahCardState();
}

class _UnifiedAsmaAllahCardState extends State<UnifiedAsmaAllahCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.getColor();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: _isPressed 
                      ? color.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: _isPressed ? 12 : 8,
                  offset: Offset(0, _isPressed ? 4 : 6),
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                  HapticFeedback.lightImpact();
                },
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
                onTapCancel: () {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space4),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: _buildCardContent(color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(Color color) {
    return Column(
      children: [
        // الرأس مع الترقيم والأيقونة
        Row(
          children: [
            // رقم الاسم
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.item.id}',
                  style: context.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
              ),
            ),
            
            ThemeConstants.space3.w,
            
            // اسم الله
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: context.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: ThemeConstants.bold,
                      fontFamily: ThemeConstants.fontFamilyArabic,
                      height: 1.2,
                    ),
                  ),
                  
                  ThemeConstants.space1.h,
                  
                  // مؤشر المعنى
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: context.textSecondaryColor.withValues(alpha: 0.7),
                      ),
                      ThemeConstants.space1.w,
                      Text(
                        'اضغط لمعرفة المعنى',
                        style: context.labelSmall?.copyWith(
                          color: context.textSecondaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // أيقونة التفاعل
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: color,
                size: ThemeConstants.iconMd,
              ),
            ),
          ],
        ),
        
        ThemeConstants.space4.h,
        
        // معاينة المعنى
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان المعنى
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    ),
                    child: Text(
                      'المعنى',
                      style: context.labelSmall?.copyWith(
                        color: color,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
              
              ThemeConstants.space2.h,
              
              // نص المعنى مختصر
              Text(
                _getTruncatedMeaning(widget.item.meaning),
                style: context.bodyMedium?.copyWith(
                  color: context.textPrimaryColor,
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // المرجع القرآني إذا وُجد
        if (widget.item.reference != null) ...[
          ThemeConstants.space3.h,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: ThemeConstants.tertiary.withValues(alpha: 0.05), // استخدام tertiary بدلاً من success
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: ThemeConstants.tertiary.withValues(alpha: 0.15), // استخدام tertiary بدلاً من success
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 16,
                  color: ThemeConstants.tertiary, // استخدام tertiary بدلاً من success
                ),
                ThemeConstants.space2.w,
                Expanded(
                  child: Text(
                    '﴿${widget.item.reference}﴾',
                    style: context.bodySmall?.copyWith(
                      color: ThemeConstants.tertiary, // استخدام tertiary بدلاً من success
                      fontFamily: ThemeConstants.fontFamilyQuran,
                      height: 1.8,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // أزرار الإجراءات السريعة إذا كانت مطلوبة
        if (widget.showActions) ...[
          ThemeConstants.space3.h,
          _buildQuickActions(color),
        ],
      ],
    );
  }

  Widget _buildQuickActions(Color color) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.copy_rounded,
            label: 'نسخ',
            color: context.textSecondaryColor,
            onTap: () => _copyName(),
          ),
        ),
        ThemeConstants.space2.w,
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            color: color,
            onTap: () => _shareName(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space3,
            vertical: ThemeConstants.space2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              ThemeConstants.space1.w,
              Text(
                label,
                style: context.labelMedium?.copyWith(
                  color: color,
                  fontWeight: ThemeConstants.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTruncatedMeaning(String meaning) {
    if (meaning.length <= 100) return meaning;
    
    final words = meaning.split(' ');
    final truncatedWords = <String>[];
    var currentLength = 0;
    
    for (final word in words) {
      if (currentLength + word.length + 1 <= 100) {
        truncatedWords.add(word);
        currentLength += word.length + 1;
      } else {
        break;
      }
    }
    
    return '${truncatedWords.join(' ')}...';
  }

  void _copyName() {
    final text = '''${widget.item.name}

المعنى: ${widget.item.meaning}

${widget.item.reference != null ? 'من القرآن الكريم: ﴿${widget.item.reference}﴾\n\n' : ''}من تطبيق أذكاري - أسماء الله الحسنى''';

    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الاسم بنجاح'),
        backgroundColor: ThemeConstants.primary, // استخدام primary بدلاً من success
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: const EdgeInsets.all(ThemeConstants.space4),
      ),
    );
    
    HapticFeedback.mediumImpact();
  }

  void _shareName() {
    // يمكن إضافة وظيفة المشاركة هنا
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ميزة المشاركة ستكون متوفرة قريباً'),
        backgroundColor: ThemeConstants.accent, // استخدام accent بدلاً من info
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: const EdgeInsets.all(ThemeConstants.space4),
      ),
    );
  }
}

// ============================================================================
// SearchBar موحد لأسماء الله الحسنى
// ============================================================================
class UnifiedAsmaAllahSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  
  const UnifiedAsmaAllahSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: context.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث في الأسماء أو المعاني...',
          hintStyle: TextStyle(
            color: context.textSecondaryColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.textSecondaryColor,
            size: ThemeConstants.iconMd,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: context.textSecondaryColor,
                    size: ThemeConstants.iconMd,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space3,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Header موحد لأسماء الله الحسنى
// ============================================================================
class UnifiedAsmaAllahHeader extends StatelessWidget {
  const UnifiedAsmaAllahHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight], // تغيير من primary إلى tertiary
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // الأيقونة والعنوان
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.star_outline, // تغيير الأيقونة من star_purple500_outlined
                      color: Colors.white,
                      size: ThemeConstants.iconLg,
                    ),
                  ),
                  
                  ThemeConstants.space3.w,
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أسماء الله الحسنى',
                          style: context.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: ThemeConstants.bold,
                          ),
                        ),
                        Text(
                          'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                          style: context.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              ThemeConstants.space3.h,
              
              // الآية القرآنية
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                  style: context.titleMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: ThemeConstants.fontFamilyQuran,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// للتوافق مع الكود الموجود - Wrappers للعناصر القديمة
// ============================================================================

/// البطاقة المحسنة - للتوافق مع الكود الموجود
class EnhancedAsmaAllahCard extends StatelessWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;

  const EnhancedAsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedAsmaAllahCard(
      item: item,
      onTap: onTap,
    );
  }
}

/// الهيدر المحسن - للتوافق مع الكود الموجود
class EnhancedAsmaAllahHeader extends StatelessWidget {
  const EnhancedAsmaAllahHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedAsmaAllahHeader();
  }
}

/// البطاقة الأساسية - للتوافق مع الكود الموجود
class AsmaAllahCard extends StatelessWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  
  const AsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return UnifiedAsmaAllahCard(
      item: item,
      onTap: onTap,
    );
  }
}

/// شريط البحث - للتوافق مع الكود الموجود
class AsmaAllahSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  
  const AsmaAllahSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    return UnifiedAsmaAllahSearchBar(
      controller: controller,
      onChanged: onChanged,
      onClear: onClear,
    );
  }
}

/// الهيدر الأساسي - للتوافق مع الكود الموجود
class AsmaAllahHeader extends StatelessWidget {
  const AsmaAllahHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const UnifiedAsmaAllahHeader();
  }
}