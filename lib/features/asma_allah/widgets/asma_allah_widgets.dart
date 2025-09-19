// lib/features/asma_allah/widgets/asma_allah_widgets.dart - مبسط ومحسن
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import '../extensions/asma_allah_extensions.dart';

// ============================================================================
// CompactAsmaAllahCard - البطاقة المضغوطة الموحدة
// ============================================================================
class CompactAsmaAllahCard extends StatefulWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  final bool showQuickActions;

  const CompactAsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
    this.showQuickActions = false,
  });

  @override
  State<CompactAsmaAllahCard> createState() => _CompactAsmaAllahCardState();
}

class _CompactAsmaAllahCardState extends State<CompactAsmaAllahCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
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
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.space3),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                  border: Border.all(
                    color: _isPressed 
                        ? color.withOpacity(0.4)
                        : color.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isPressed 
                          ? color.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: _isPressed ? 12 : 8,
                      offset: Offset(0, _isPressed ? 4 : 2),
                    ),
                  ],
                ),
                child: _buildCardContent(color),
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
        // الصف الرئيسي
        Row(
          children: [
            // الرقم مع الخلفية الملونة
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: Center(
                child: Text(
                  '${widget.item.id}',
                  style: context.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
              ),
            ),
            
            ThemeConstants.space3.w,
            
            // محتوى الاسم والمعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الله
                  Text(
                    widget.item.name,
                    style: context.titleMedium?.copyWith(
                      color: color,
                      fontWeight: ThemeConstants.bold,
                      fontFamily: ThemeConstants.fontFamilyArabic,
                    ),
                  ),
                  
                  ThemeConstants.space1.h,
                  
                  // معاينة المعنى
                  Text(
                    _getTruncatedText(widget.item.meaning, 50),
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
        
        // المرجع القرآني إذا وُجد
        if (widget.item.reference != null) ...[
          ThemeConstants.space2.h,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              color: ThemeConstants.tertiary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
              border: Border.all(
                color: ThemeConstants.tertiary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: ThemeConstants.tertiary,
                ),
                ThemeConstants.space1.w,
                Expanded(
                  child: Text(
                    '﴿${widget.item.reference}﴾',
                    style: context.labelSmall?.copyWith(
                      color: ThemeConstants.tertiary,
                      fontFamily: ThemeConstants.fontFamilyQuran,
                      height: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // أزرار الإجراءات السريعة
        if (widget.showQuickActions) ...[
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
            color: ThemeConstants.primary,
            onTap: _copyName,
          ),
        ),
        ThemeConstants.space2.w,
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            color: color,
            onTap: _shareName,
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
      borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space2,
            vertical: ThemeConstants.space1,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
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
                size: 14,
                color: color,
              ),
              ThemeConstants.space1.w,
              Text(
                label,
                style: context.labelSmall?.copyWith(
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

  String _getTruncatedText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    
    final words = text.split(' ');
    final truncatedWords = <String>[];
    var currentLength = 0;
    
    for (final word in words) {
      if (currentLength + word.length + 1 <= maxLength) {
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
    
    context.showSuccessSnackBar('تم نسخ الاسم بنجاح');
    HapticFeedback.mediumImpact();
  }

  void _shareName() {
    final content = '''${widget.item.name}

المعنى: ${widget.item.meaning}

${widget.item.reference != null ? 'من القرآن الكريم: ﴿${widget.item.reference}﴾\n\n' : ''}من تطبيق أذكاري - أسماء الله الحسنى''';

    Share.share(
      content,
      subject: 'أسماء الله الحسنى - ${widget.item.name}',
    );
    
    HapticFeedback.lightImpact();
  }
}

// ============================================================================
// LoadingCard - بطاقة التحميل
// ============================================================================
class AsmaAllahLoadingCard extends StatefulWidget {
  const AsmaAllahLoadingCard({super.key});

  @override
  State<AsmaAllahLoadingCard> createState() => _AsmaAllahLoadingCardState();
}

class _AsmaAllahLoadingCardState extends State<AsmaAllahLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: ThemeConstants.space2),
          padding: const EdgeInsets.all(ThemeConstants.space3),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // شكل الرقم
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.textSecondaryColor.withValues(
                    alpha: 0.1 + (_shimmerAnimation.value * 0.1),
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
              ),
              
              ThemeConstants.space3.w,
              
              // شكل النص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity * 0.4,
                      decoration: BoxDecoration(
                        color: context.textSecondaryColor.withValues(
                          alpha: 0.1 + (_shimmerAnimation.value * 0.1),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    ThemeConstants.space1.h,
                    Container(
                      height: 14,
                      width: double.infinity * 0.8,
                      decoration: BoxDecoration(
                        color: context.textSecondaryColor.withValues(
                          alpha: 0.05 + (_shimmerAnimation.value * 0.05),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    ThemeConstants.space1.h,
                    Container(
                      height: 14,
                      width: double.infinity * 0.6,
                      decoration: BoxDecoration(
                        color: context.textSecondaryColor.withValues(
                          alpha: 0.05 + (_shimmerAnimation.value * 0.05),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// للتوافق مع الكود الموجود - Wrappers
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
    return CompactAsmaAllahCard(
      item: item,
      onTap: onTap,
    );
  }
}

/// البطاقة الموحدة - للتوافق مع الكود الموجود
class UnifiedAsmaAllahCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CompactAsmaAllahCard(
      item: item,
      onTap: onTap,
      showQuickActions: showActions,
    );
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
    return CompactAsmaAllahCard(
      item: item,
      onTap: onTap,
    );
  }
}

// ============================================================================
// Search Bar المحسن
// ============================================================================
class EnhancedAsmaAllahSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  
  const EnhancedAsmaAllahSearchBar({
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: context.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث في أسماء الله الحسنى أو معانيها...',
          hintStyle: TextStyle(
            color: context.textSecondaryColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: context.textSecondaryColor,
              size: ThemeConstants.iconMd,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.clear_rounded,
                      color: context.textSecondaryColor,
                      size: 16,
                    ),
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space4,
          ),
        ),
      ),
    );
  }
}