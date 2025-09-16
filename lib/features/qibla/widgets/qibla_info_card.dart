// lib/features/qibla/widgets/qibla_info_card.dart - نسخة مبسطة
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../models/qibla_model.dart';

/// بطاقة معلومات القبلة المبسطة
class QiblaInfoCard extends StatelessWidget {
  final QiblaModel qiblaData;

  const QiblaInfoCard({
    super.key,
    required this.qiblaData,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // رأس البطاقة
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: context.primaryColor,
              ),
              ThemeConstants.space3.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocationName(),
                      style: context.titleMedium?.semiBold,
                    ),
                    Text(
                      qiblaData.ageDescription,
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          ThemeConstants.space4.h,
          const Divider(),
          ThemeConstants.space4.h,

          // المعلومات الأساسية
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.navigation_outlined,
                  title: 'اتجاه القبلة',
                  value: '${qiblaData.qiblaDirection.toStringAsFixed(1)}°',
                  subtitle: qiblaData.directionDescription,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: context.dividerColor,
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.straighten,
                  title: 'المسافة',
                  value: qiblaData.distanceDescription,
                  subtitle: 'خط مستقيم',
                ),
              ),
            ],
          ),

          ThemeConstants.space4.h,

          // معلومات إضافية
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'دقة الموقع',
                  '± ${qiblaData.accuracy.toStringAsFixed(0)} م',
                  Icons.gps_fixed,
                ),
                _buildStatItem(
                  context,
                  'الإحداثيات',
                  '${qiblaData.latitude.toStringAsFixed(2)}, ${qiblaData.longitude.toStringAsFixed(2)}',
                  Icons.map,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationName() {
    if (qiblaData.cityName != null && qiblaData.countryName != null) {
      return '${qiblaData.cityName}، ${qiblaData.countryName}';
    }
    return 'موقعك الحالي';
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: ThemeConstants.iconSm, color: context.textSecondaryColor),
        ThemeConstants.space1.h,
        Text(label, style: context.labelSmall),
        Text(value, style: context.bodySmall?.semiBold),
      ],
    );
  }
}

/// بلاطة المعلومات
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.primaryColor),
        ThemeConstants.space2.h,
        Text(title, style: context.labelSmall),
        Text(value, style: context.titleMedium?.bold),
        Text(subtitle, style: context.labelSmall),
      ],
    );
  }
}
