// lib/features/dua/widgets/dua_card_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
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

class _DuaCardWidgetState extends State<DuaCardWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildCard();
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
            border: Border.all(
              color: widget.dua.readCount > 0
                  ? ThemeConstants.success.withValues(alpha: 0.3)
                  : context.dividerColor.withValues(alpha: 0.2),
              width: widget.dua.readCount > 0 ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    ThemeConstants.space4.h,
                    _buildArabicText(),
                    ThemeConstants.space4.h,
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // رقم الدعاء
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.dua.readCount > 0
                  ? [ThemeConstants.success, ThemeConstants.success.darken(0.2)]
                  : [ThemeConstants.primary, ThemeConstants.primaryLight],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: context.titleMedium?.copyWith(
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
                  color: widget.dua.readCount > 0
                      ? ThemeConstants.success
                      : context.textPrimaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (widget.dua.tags.isNotEmpty) ...[
                ThemeConstants.space1.h,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.dua.tags.take(3).map((tag) => 
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeConstants.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: context.labelSmall?.copyWith(
                            color: ThemeConstants.accent,
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
              color: ThemeConstants.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConstants.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: ThemeConstants.success,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.dua.readCount}',
                  style: context.labelSmall?.copyWith(
                    color: ThemeConstants.success,
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
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ThemeConstants.primary.withValues(alpha: 0.08),
            ThemeConstants.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: ThemeConstants.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // أيقونة زخرفية في الأعلى
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConstants.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: ThemeConstants.primary,
              size: 20,
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // النص العربي
          Text(
            widget.dua.arabicText,
            style: context.bodyLarge?.copyWith(
              fontSize: widget.fontSize,
              fontFamily: ThemeConstants.fontFamilyArabic,
              height: 2.2,
              fontWeight: ThemeConstants.medium,
              color: context.textPrimaryColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          
          ThemeConstants.space2.h,
          
          // خط زخرفي في الأسفل
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ThemeConstants.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
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
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.library_books_rounded,
                    color: context.primaryColor,
                    size: 14,
                  ),
                  ThemeConstants.space1.w,
                  Flexible(
                    child: Text(
                      widget.dua.source!,
                      style: context.labelMedium?.copyWith(
                        color: context.primaryColor,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        ThemeConstants.space3.w,
        
        // أزرار الإجراءات
        Row(
          children: [
            _buildActionButton(
              icon: Icons.share_rounded,
              onPressed: widget.onShare,
              tooltip: 'مشاركة',
            ),
            ThemeConstants.space1.w,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: context.textSecondaryColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}