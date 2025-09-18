// lib/features/asma_allah/widgets/unified_asma_allah_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import '../extensions/asma_allah_extensions.dart';

/// بطاقة موحدة لأسماء الله الحسنى مع تصميم متناسق مع باقي التطبيق
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
              color: ThemeConstants.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: ThemeConstants.accent.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 16,
                  color: ThemeConstants.accent,
                ),
                ThemeConstants.space2.w,
                Expanded(
                  child: Text(
                    '﴿${widget.item.reference}﴾',
                    style: context.bodySmall?.copyWith(
                      color: ThemeConstants.accent,
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
        backgroundColor: ThemeConstants.success,
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
        backgroundColor: ThemeConstants.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: const EdgeInsets.all(ThemeConstants.space4),
      ),
    );
  }
}