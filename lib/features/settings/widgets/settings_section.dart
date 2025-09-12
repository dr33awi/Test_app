// lib/features/settings/widgets/settings_section.dart
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// قسم في شاشة الإعدادات
class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool showDividers;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin = margin ?? const EdgeInsets.symmetric(
      horizontal: ThemeConstants.space4,
      vertical: ThemeConstants.space3,
    );

    final effectiveBorderRadius = BorderRadius.circular(ThemeConstants.radiusXl);

    return Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.cardColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final effectiveTitleColor = titleColor ?? context.primaryColor;
    final effectiveIconColor = iconColor ?? context.primaryColor;
    final effectivePadding = padding ?? const EdgeInsets.all(ThemeConstants.space4);

    return Container(
      padding: effectivePadding,
      child: Row(
        children: [
          // أيقونة القسم
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space2),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: Icon(
                icon,
                size: ThemeConstants.iconSm,
                color: effectiveIconColor,
              ),
            ),
            ThemeConstants.space3.w,
          ],
          
          // العنوان والعنوان الفرعي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleMedium?.copyWith(
                    color: effectiveTitleColor,
                    fontWeight: ThemeConstants.bold,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  ThemeConstants.space1.h,
                  Text(
                    subtitle!,
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        // خط فاصل بين الهيدر والمحتوى
        if (showDividers)
          Divider(
            height: 1,
            thickness: 1,
            color: context.dividerColor.withValues(alpha: 0.3),
            indent: 0,
            endIndent: 0,
          ),
        
        // محتوى القسم مع الفواصل
        ...List.generate(
          children.length,
          (index) {
            final child = children[index];
            final isLast = index == children.length - 1;
            
            return Column(
              children: [
                child,
                // خط فاصل بين العناصر
                if (!isLast && showDividers)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: ThemeConstants.space6,
                    endIndent: ThemeConstants.space6,
                    color: context.dividerColor.withValues(alpha: 0.3),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}