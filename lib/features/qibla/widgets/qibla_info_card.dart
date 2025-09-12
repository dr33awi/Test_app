// lib/features/qibla/widgets/qibla_info_card.dart - نسخة محسنة
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/qibla_model.dart';

/// بطاقة معلومات القبلة المحسنة مع عرض شامل ومنظم
class QiblaInfoCard extends StatefulWidget {
  final QiblaModel qiblaData;
  final bool showDetailedInfo;
  final bool enableInteraction;

  const QiblaInfoCard({
    super.key,
    required this.qiblaData,
    this.showDetailedInfo = true,
    this.enableInteraction = true,
  });

  @override
  State<QiblaInfoCard> createState() => _QiblaInfoCardState();
}

class _QiblaInfoCardState extends State<QiblaInfoCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: ThemeConstants.durationNormal,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: ThemeConstants.curveSmooth,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: ThemeConstants.radius2xl,
      child: Column(
        children: [
          // رأس البطاقة
          _buildHeader(context),
          
          // المعلومات الأساسية
          _buildBasicInfo(context),
          
          // المعلومات المفصلة (قابلة للطي)
          if (widget.showDetailedInfo)
            _buildExpandableDetails(context),
          
          // تحذيرات أو نصائح إذا لزم الأمر
          _buildWarningsAndTips(context),
        ],
      ),
    );
  }

  /// بناء رأس البطاقة
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor.withOpacity(0.1),
            context.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeConstants.radius2xl),
        ),
      ),
      child: Row(
        children: [
          // أيقونة الموقع مع حالة الدقة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              color: _getAccuracyColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: _getAccuracyColor(),
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // معلومات الموقع
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقعك الحالي',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                ThemeConstants.space1.h,
                Text(
                  _getLocationName(),
                  style: context.bodyLarge?.bold,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  _getDataStatusText(),
                  style: context.bodySmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: ThemeConstants.medium,
                  ),
                ),
              ],
            ),
          ),
          
          // معلومات سريعة عن جودة البيانات
          _buildQualityIndicator(context),
        ],
      ),
    );
  }

  /// بناء مؤشر جودة البيانات
  Widget _buildQualityIndicator(BuildContext context) {
    final hasGoodQuality = widget.qiblaData.hasGoodQuality;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.space2,
        vertical: ThemeConstants.space1,
      ),
      decoration: BoxDecoration(
        color: hasGoodQuality 
            ? ThemeConstants.success.withOpacity(0.1)
            : ThemeConstants.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: hasGoodQuality 
              ? ThemeConstants.success.withOpacity(0.3)
              : ThemeConstants.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasGoodQuality ? Icons.verified : Icons.warning_amber,
            size: ThemeConstants.iconSm,
            color: hasGoodQuality ? ThemeConstants.success : ThemeConstants.warning,
          ),
          ThemeConstants.space1.w,
          Text(
            hasGoodQuality ? 'موثوق' : 'محدود',
            style: context.bodySmall?.copyWith(
              color: hasGoodQuality ? ThemeConstants.success : ThemeConstants.warning,
              fontWeight: ThemeConstants.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء المعلومات الأساسية
  Widget _buildBasicInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        children: [
          // المعلومات الرئيسية (الاتجاه والمسافة)
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  context: context,
                  icon: Icons.navigation_outlined,
                  title: 'اتجاه القبلة',
                  value: '${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}°',
                  subtitle: widget.qiblaData.directionDescription,
                  color: context.primaryColor,
                  onTap: widget.enableInteraction ? () => _showDirectionDetails(context) : null,
                ),
              ),
              
              Container(
                width: 1,
                height: 60,
                color: context.dividerColor.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.space3),
              ),
              
              Expanded(
                child: _buildInfoTile(
                  context: context,
                  icon: Icons.straighten,
                  title: 'المسافة للكعبة',
                  value: widget.qiblaData.distanceDescription,
                  subtitle: 'خط مستقيم',
                  color: ThemeConstants.info,
                  onTap: widget.enableInteraction ? () => _showDistanceDetails(context) : null,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // معلومات إضافية مبسطة
          _buildQuickStats(context),
        ],
      ),
    );
  }

  /// بناء الإحصائيات السريعة
  Widget _buildQuickStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: context.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildStatRow(
            context: context,
            label: 'دقة الموقع',
            value: _getAccuracyText(),
            valueColor: _getAccuracyColor(),
            icon: _getAccuracyIcon(),
          ),
          
          const Divider(height: ThemeConstants.space4),
          
          _buildStatRow(
            context: context,
            label: 'عمر البيانات',
            value: widget.qiblaData.ageDescription,
            valueColor: _getAgeColor(),
            icon: _getAgeIcon(),
          ),
          
          if (widget.qiblaData.magneticDeclination != 0) ...[
            const Divider(height: ThemeConstants.space4),
            _buildStatRow(
              context: context,
              label: 'الانحراف المغناطيسي',
              value: '${widget.qiblaData.magneticDeclination.toStringAsFixed(1)}°',
              valueColor: context.textSecondaryColor,
              icon: Icons.explore,
            ),
          ],
        ],
      ),
    );
  }

  /// بناء التفاصيل القابلة للطي
  Widget _buildExpandableDetails(BuildContext context) {
    return Column(
      children: [
        // زر التوسيع
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _expandController.forward();
              } else {
                _expandController.reverse();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space4,
                vertical: ThemeConstants.space2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'إخفاء التفاصيل' : 'عرض المزيد',
                    style: context.bodyMedium?.copyWith(
                      color: context.primaryColor,
                      fontWeight: ThemeConstants.medium,
                    ),
                  ),
                  ThemeConstants.space1.w,
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: ThemeConstants.durationNormal,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: context.primaryColor,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // المحتوى القابل للطي
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: _buildDetailedContent(context),
        ),
      ],
    );
  }

  /// بناء المحتوى المفصل
  Widget _buildDetailedContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الإحداثيات
          _buildCoordinatesSection(context),
          
          ThemeConstants.space4.h,
          
          // معلومات السفر
          _buildTravelSection(context),
          
          ThemeConstants.space4.h,
          
          // معلومات تقنية
          _buildTechnicalSection(context),
        ],
      ),
    );
  }

  /// بناء قسم الإحداثيات
  Widget _buildCoordinatesSection(BuildContext context) {
    return _buildDetailSection(
      context: context,
      title: 'الإحداثيات',
      icon: Icons.gps_fixed,
      children: [
        _buildDetailRow(
          context: context,
          label: 'خط العرض',
          value: '${widget.qiblaData.latitude.toStringAsFixed(6)}°',
          onTap: () => _copyToClipboard(context, widget.qiblaData.latitude.toString(), 'خط العرض'),
        ),
        _buildDetailRow(
          context: context,
          label: 'خط الطول',
          value: '${widget.qiblaData.longitude.toStringAsFixed(6)}°',
          onTap: () => _copyToClipboard(context, widget.qiblaData.longitude.toString(), 'خط الطول'),
        ),
        _buildDetailRow(
          context: context,
          label: 'الإحداثيات مجتمعة',
          value: '${widget.qiblaData.latitude.toStringAsFixed(4)}, ${widget.qiblaData.longitude.toStringAsFixed(4)}',
          onTap: () => _copyToClipboard(
            context, 
            '${widget.qiblaData.latitude}, ${widget.qiblaData.longitude}',
            'الإحداثيات'
          ),
        ),
      ],
    );
  }

  /// بناء قسم السفر
  Widget _buildTravelSection(BuildContext context) {
    return _buildDetailSection(
      context: context,
      title: 'معلومات السفر',
      icon: Icons.flight,
      children: [
        _buildDetailRow(
          context: context,
          label: 'وقت السفر المقدر',
          value: widget.qiblaData.estimatedTravelInfo,
        ),
        _buildDetailRow(
          context: context,
          label: 'وصف المسافة',
          value: widget.qiblaData.distanceContext,
        ),
        _buildDetailRow(
          context: context,
          label: 'المسافة بالكيلومتر',
          value: '${widget.qiblaData.distance.toStringAsFixed(2)} كم',
        ),
      ],
    );
  }

  /// بناء قسم المعلومات التقنية
  Widget _buildTechnicalSection(BuildContext context) {
    return _buildDetailSection(
      context: context,
      title: 'معلومات تقنية',
      icon: Icons.settings,
      children: [
        _buildDetailRow(
          context: context,
          label: 'وقت الحساب',
          value: _formatDateTime(widget.qiblaData.calculatedAt),
        ),
        _buildDetailRow(
          context: context,
          label: 'مستوى الدقة',
          value: widget.qiblaData.accuracyLevel.description,
          valueColor: _getAccuracyColor(),
        ),
        _buildDetailRow(
          context: context,
          label: 'حداثة البيانات',
          value: '${widget.qiblaData.freshnessFactor.toStringAsFixed(1)}%',
          valueColor: _getFreshnessColor(),
        ),
        if (widget.qiblaData.magneticDeclination != 0)
          _buildDetailRow(
            context: context,
            label: 'الاتجاه المغناطيسي',
            value: '${widget.qiblaData.magneticQiblaDirection.toStringAsFixed(1)}°',
          ),
      ],
    );
  }

  /// بناء التحذيرات والنصائح
  Widget _buildWarningsAndTips(BuildContext context) {
    final warnings = <Widget>[];
    
    // تحذير البيانات القديمة
    if (widget.qiblaData.isStale) {
      warnings.add(_buildWarningCard(
        context: context,
        icon: Icons.warning_amber_rounded,
        title: 'بيانات قديمة',
        message: widget.qiblaData.dataStatusDescription,
        color: widget.qiblaData.isVeryStale ? ThemeConstants.error : ThemeConstants.warning,
        action: 'تحديث الآن',
        onAction: () => _requestUpdate(context),
      ));
    }
    
    // تحذير دقة منخفضة
    if (widget.qiblaData.hasLowAccuracy) {
      warnings.add(_buildWarningCard(
        context: context,
        icon: Icons.gps_off,
        title: 'دقة منخفضة',
        message: 'دقة تحديد الموقع منخفضة. ${widget.qiblaData.detailedAccuracyDescription.split('\n').last}',
        color: ThemeConstants.warning,
        action: 'نصائح التحسين',
        onAction: () => _showAccuracyTips(context),
      ));
    }
    
    // نصيحة للمناطق البعيدة
    if (widget.qiblaData.distance > 10000) {
      warnings.add(_buildTipCard(
        context: context,
        icon: Icons.info_outline,
        title: 'منطقة بعيدة',
        message: 'أنت في منطقة بعيدة عن مكة. تأكد من دقة البوصلة والموقع.',
        color: ThemeConstants.info,
      ));
    }
    
    if (warnings.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeConstants.space4,
        right: ThemeConstants.space4,
        bottom: ThemeConstants.space4,
      ),
      child: Column(children: warnings),
    );
  }

  // ==================== Helper Methods ====================

  /// بناء بلاطة المعلومات
  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.space2),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: ThemeConstants.iconLg,
              ),
              ThemeConstants.space2.h,
              Text(
                title,
                style: context.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              ThemeConstants.space1.h,
              Text(
                value,
                style: context.titleMedium?.bold.textColor(color),
                textAlign: TextAlign.center,
              ),
              ThemeConstants.space1.h,
              Text(
                subtitle,
                style: context.bodySmall?.copyWith(
                  color: context.textSecondaryColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء صف الإحصائية
  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: ThemeConstants.iconSm,
            color: valueColor ?? context.textSecondaryColor,
          ),
          ThemeConstants.space2.w,
        ],
        Expanded(
          child: Text(
            label,
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
        Text(
          value,
          style: context.bodySmall?.copyWith(
            fontWeight: ThemeConstants.semiBold,
            color: valueColor ?? context.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// بناء قسم مفصل
  Widget _buildDetailSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: context.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ThemeConstants.iconMd,
                color: context.primaryColor,
              ),
              ThemeConstants.space2.w,
              Text(
                title,
                style: context.titleSmall?.semiBold.textColor(context.primaryColor),
              ),
            ],
          ),
          ThemeConstants.space3.h,
          ...children,
        ],
      ),
    );
  }

  /// بناء صف التفاصيل
  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space1,
              vertical: ThemeConstants.space1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: context.bodySmall?.copyWith(
                        fontWeight: ThemeConstants.medium,
                        color: valueColor ?? context.textPrimaryColor,
                      ),
                    ),
                    if (onTap != null) ...[
                      ThemeConstants.space1.w,
                      Icon(
                        Icons.copy,
                        size: ThemeConstants.iconSm,
                        color: context.textSecondaryColor.withOpacity(0.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة تحذير
  Widget _buildWarningCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: ThemeConstants.space3),
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: ThemeConstants.iconMd,
          ),
          ThemeConstants.space3.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
                ThemeConstants.space1.h,
                Text(
                  message,
                  style: context.bodySmall?.copyWith(
                    color: color.darken(0.1),
                  ),
                ),
                if (action != null && onAction != null) ...[
                  ThemeConstants.space2.h,
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space2,
                        vertical: ThemeConstants.space1,
                      ),
                    ),
                    child: Text(action),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة نصيحة
  Widget _buildTipCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: ThemeConstants.space3),
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: ThemeConstants.iconMd,
          ),
          ThemeConstants.space3.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
                ThemeConstants.space1.h,
                Text(
                  message,
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

  // ==================== Helper Functions ====================

  /// الحصول على اسم الموقع
  String _getLocationName() {
    if (widget.qiblaData.cityName != null && widget.qiblaData.countryName != null) {
      return '${widget.qiblaData.cityName}، ${widget.qiblaData.countryName}';
    } else if (widget.qiblaData.cityName != null) {
      return widget.qiblaData.cityName!;
    } else if (widget.qiblaData.countryName != null) {
      return widget.qiblaData.countryName!;
    } else {
      return 'موقع غير محدد';
    }
  }

  /// الحصول على نص حالة البيانات
  String _getDataStatusText() {
    if (widget.qiblaData.isFresh) {
      return 'بيانات حديثة • ${widget.qiblaData.ageDescription}';
    } else if (widget.qiblaData.isStale) {
      return 'بيانات قديمة • ${widget.qiblaData.ageDescription}';
    } else {
      return 'محدث ${widget.qiblaData.ageDescription}';
    }
  }

  /// الحصول على لون الحالة
  Color _getStatusColor() {
    if (widget.qiblaData.isFresh) {
      return ThemeConstants.success;
    } else if (widget.qiblaData.isStale) {
      return widget.qiblaData.isVeryStale ? ThemeConstants.error : ThemeConstants.warning;
    } else {
      return context.textSecondaryColor;
    }
  }

  /// الحصول على نص الدقة
  String _getAccuracyText() {
    if (widget.qiblaData.hasHighAccuracy) {
      return '± ${widget.qiblaData.accuracy.toStringAsFixed(0)} م (عالية)';
    } else if (widget.qiblaData.hasMediumAccuracy) {
      return '± ${widget.qiblaData.accuracy.toStringAsFixed(0)} م (متوسطة)';
    } else {
      return '± ${widget.qiblaData.accuracy.toStringAsFixed(0)} م (منخفضة)';
    }
  }

  /// الحصول على لون الدقة
  Color _getAccuracyColor() {
    if (widget.qiblaData.hasHighAccuracy) return ThemeConstants.success;
    if (widget.qiblaData.hasMediumAccuracy) return ThemeConstants.warning;
    return ThemeConstants.error;
  }

  /// الحصول على أيقونة الدقة
  IconData _getAccuracyIcon() {
    if (widget.qiblaData.hasHighAccuracy) return Icons.gps_fixed;
    if (widget.qiblaData.hasMediumAccuracy) return Icons.gps_not_fixed;
    return Icons.gps_off;
  }

  /// الحصول على لون عمر البيانات
  Color _getAgeColor() {
    if (widget.qiblaData.isFresh) return ThemeConstants.success;
    if (widget.qiblaData.isStale) return ThemeConstants.warning;
    if (widget.qiblaData.isVeryStale) return ThemeConstants.error;
    return context.textSecondaryColor;
  }

  /// الحصول على أيقونة عمر البيانات
  IconData _getAgeIcon() {
    if (widget.qiblaData.isFresh) return Icons.schedule;
    if (widget.qiblaData.isStale) return Icons.access_time;
    if (widget.qiblaData.isVeryStale) return Icons.schedule_send;
    return Icons.update;
  }

  /// الحصول على لون الحداثة
  Color _getFreshnessColor() {
    final freshness = widget.qiblaData.freshnessFactor;
    if (freshness > 0.8) return ThemeConstants.success;
    if (freshness > 0.5) return ThemeConstants.warning;
    return ThemeConstants.error;
  }

  /// تنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return 'اليوم ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return 'منذ ${difference.inMinutes} دقيقة';
    }
  }

  // ==================== Action Methods ====================

  /// نسخ إلى الحافظة
  void _copyToClipboard(BuildContext context, String text, String label) {
    if (!widget.enableInteraction) return;

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
      ),
    );
  }

  /// عرض تفاصيل الاتجاه
  void _showDirectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.navigation,
              color: context.primaryColor,
            ),
            ThemeConstants.space2.w,
            const Text('تفاصيل الاتجاه'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('الاتجاه الحقيقي', '${widget.qiblaData.trueQiblaDirection.toStringAsFixed(2)}°'),
            _buildDetailItem('الاتجاه المغناطيسي', '${widget.qiblaData.magneticQiblaDirection.toStringAsFixed(2)}°'),
            _buildDetailItem('الوصف', widget.qiblaData.detailedDirectionDescription),
            _buildDetailItem('الانحراف المغناطيسي', '${widget.qiblaData.magneticDeclination.toStringAsFixed(2)}°'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              _copyToClipboard(context, widget.qiblaData.qiblaDirection.toString(), 'اتجاه القبلة');
              Navigator.of(context).pop();
            },
            child: const Text('نسخ'),
          ),
        ],
      ),
    );
  }

  /// عرض تفاصيل المسافة
  void _showDistanceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.straighten,
              color: ThemeConstants.info,
            ),
            ThemeConstants.space2.w,
            const Text('تفاصيل المسافة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('المسافة الدقيقة', '${widget.qiblaData.distance.toStringAsFixed(3)} كم'),
            _buildDetailItem('وصف المسافة', widget.qiblaData.distanceDescription),
            _buildDetailItem('السياق', widget.qiblaData.distanceContext),
            _buildDetailItem('وقت السفر المقدر', widget.qiblaData.estimatedTravelInfo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              _copyToClipboard(context, widget.qiblaData.distance.toString(), 'المسافة');
              Navigator.of(context).pop();
            },
            child: const Text('نسخ'),
          ),
        ],
      ),
    );
  }

  /// عرض نصائح تحسين الدقة
  void _showAccuracyTips(BuildContext context) {
    final suggestions = widget.qiblaData.getAccuracyImprovementSuggestions();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: ThemeConstants.warning,
            ),
            ThemeConstants.space2.w,
            const Text('نصائح تحسين الدقة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لتحسين دقة تحديد الموقع، جرب النصائح التالية:',
              style: context.bodyMedium,
            ),
            ThemeConstants.space3.h,
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: ThemeConstants.iconSm,
                    color: ThemeConstants.success,
                  ),
                  ThemeConstants.space2.w,
                  Expanded(
                    child: Text(
                      suggestion,
                      style: context.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
            if (suggestions.isEmpty)
              Text(
                'دقة الموقع جيدة حالياً.',
                style: context.bodyMedium?.copyWith(
                  color: ThemeConstants.success,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  /// طلب تحديث البيانات
  void _requestUpdate(BuildContext context) {
    // يمكن إرسال إشارة للـ parent widget لطلب التحديث
    // أو استخدام callback function
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('استخدم زر التحديث في أعلى الشاشة'),
        action: SnackBarAction(
          label: 'فهمت',
          onPressed: () {},
        ),
      ),
    );
  }

  /// بناء عنصر التفاصيل
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.medium,
            ),
          ),
          ThemeConstants.space1.h,
          Text(
            value,
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}