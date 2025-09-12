// lib/features/settings/widgets/settings_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';

/// عنصر في قسم الإعدادات
class SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.enabled = true,
    this.padding,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    HapticFeedback.mediumImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? context.primaryColor;
    final effectivePadding = widget.padding ?? const EdgeInsets.symmetric(
      horizontal: ThemeConstants.space4,
      vertical: ThemeConstants.space4,
    );

    return Opacity(
      opacity: widget.enabled ? (_isPressed ? 0.8 : 1.0) : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          splashColor: effectiveIconColor.withValues(alpha: 0.1),
          highlightColor: effectiveIconColor.withValues(alpha: 0.05),
          child: Padding(
            padding: effectivePadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(context, effectiveIconColor),
                ThemeConstants.space4.w,
                Expanded(child: _buildContent(context)),
                if (widget.trailing != null) ...[
                  ThemeConstants.space3.w,
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, Color iconColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.enabled 
            ? iconColor.withValues(alpha: _isPressed ? 0.2 : 0.1)
            : context.textSecondaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
      ),
      child: Icon(
        widget.icon,
        color: widget.enabled 
            ? iconColor
            : context.textSecondaryColor.withValues(alpha: 0.5),
        size: ThemeConstants.iconMd,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: context.titleMedium?.copyWith(
            color: widget.enabled 
                ? context.textPrimaryColor
                : context.textSecondaryColor.withValues(alpha: 0.7),
            fontWeight: ThemeConstants.medium,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null) ...[
          ThemeConstants.space1.h,
          Text(
            widget.subtitle!,
            style: context.bodySmall?.copyWith(
              color: widget.enabled 
                  ? context.textSecondaryColor
                  : context.textSecondaryColor.withValues(alpha: 0.5),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Switch مخصص للإعدادات
class SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final bool enabled;

  const SettingsSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: activeColor ?? context.primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}