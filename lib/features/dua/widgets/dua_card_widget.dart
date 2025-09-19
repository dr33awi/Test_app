// lib/features/dua/widgets/dua_card_widget.dart - محسن ومبسط
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/dua_model.dart';

class DuaCardWidget extends StatefulWidget {
  final Dua dua;
  final int index;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const DuaCardWidget({
    super.key,
    required this.dua,
    required this.index,
    required this.fontSize,
    required this.onTap,
    required this.onShare,
    required this.onCopy,
  });

  @override
  State<DuaCardWidget> createState() => _DuaCardWidgetState();
}

class _DuaCardWidgetState extends State<DuaCardWidget>
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
    final isRead = widget.dua.readCount > 0;
    final cardColor = isRead ? ThemeConstants.accent : ThemeConstants.primary;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
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
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
                  border: Border.all(
                    color: _isPressed 
                        ? cardColor.withOpacity(0.4)
                        : cardColor.withOpacity(0.2),
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isPressed 
                          ? cardColor.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: _isPressed ? 12 : 8,
                      offset: Offset(0, _isPressed ? 4 : 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(ThemeConstants.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(cardColor),
                    ThemeConstants.space4.h,
                    _buildArabicText(),
                    ThemeConstants.space4.h,
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color cardColor) {
    return Row(
      children: [
        // رقم الدعاء
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor, cardColor.withOpacity(0.8)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: context.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
        ),
        
        ThemeConstants.space3.w,
        
        // عنوان الدعاء
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.dua.title,
                style: context.titleMedium?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: cardColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              
              // التاجز إن وُجدت
              if (widget.dua.tags.isNotEmpty) ...[
                ThemeConstants.space1.h,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.dua.tags.take(2).map((tag) => 
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          border: Border.all(
                            color: cardColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: context.labelSmall?.copyWith(
                            color: cardColor,
                            fontWeight: ThemeConstants.medium,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // مؤشر الحالة
        if (widget.dua.readCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ThemeConstants.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              border: Border.all(
                color: ThemeConstants.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: ThemeConstants.accent,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.dua.readCount}',
                  style: context.labelSmall?.copyWith(
                    color: ThemeConstants.accent,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildArabicText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // أيقونة زخرفية
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ThemeConstants.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: ThemeConstants.primary,
              size: 16,
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // النص العربي
          Text(
            widget.dua.arabicText,
            style: context.bodyLarge?.copyWith(
              fontSize: widget.fontSize,
              fontFamily: ThemeConstants.fontFamilyArabic,
              height: 2.0,
              fontWeight: ThemeConstants.medium,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          
          ThemeConstants.space2.h,
          
          // خط زخرفي
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ThemeConstants.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // المصدر
        if (widget.dua.source != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space3,
                vertical: ThemeConstants.space2,
              ),
              decoration: BoxDecoration(
                color: ThemeConstants.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                border: Border.all(
                  color: ThemeConstants.tertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.library_books_rounded,
                    color: ThemeConstants.tertiary,
                    size: 14,
                  ),
                  ThemeConstants.space1.w,
                  Flexible(
                    child: Text(
                      widget.dua.source!,
                      style: context.labelMedium?.copyWith(
                        color: ThemeConstants.tertiary,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        if (widget.dua.source != null) ThemeConstants.space3.w,
        
        // أزرار الإجراءات
        Row(
          children: [
            _buildActionButton(
              icon: Icons.share_rounded,
              onPressed: widget.onShare,
              tooltip: 'مشاركة',
            ),
            ThemeConstants.space2.w,
            _buildActionButton(
              icon: Icons.content_copy_rounded,
              onPressed: widget.onCopy,
              tooltip: 'نسخ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: context.textSecondaryColor,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}