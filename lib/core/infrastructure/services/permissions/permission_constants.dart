// lib/core/infrastructure/services/permissions/permission_constants.dart
// مصدر واحد لجميع معلومات الأذونات

import 'package:flutter/material.dart';
import 'permission_service.dart';

/// معلومات الإذن
class PermissionInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCritical;

  const PermissionInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isCritical,
  });
}

/// ثوابت الأذونات - مصدر واحد للحقيقة
class PermissionConstants {
  // منع إنشاء instance
  PermissionConstants._();
  
  /// معلومات جميع الأذونات
  static const Map<AppPermissionType, PermissionInfo> permissions = {
    AppPermissionType.notification: PermissionInfo(
      name: 'الإشعارات',
      description: 'لإرسال تنبيهات الصلاة والأذكار في أوقاتها',
      icon: Icons.notifications_active,
      color: Colors.blue,
      isCritical: true,
    ),
    AppPermissionType.location: PermissionInfo(
      name: 'الموقع',
      description: 'لحساب أوقات الصلاة بدقة واتجاه القبلة',
      icon: Icons.location_on,
      color: Colors.green,
      isCritical: true,
    ),
    AppPermissionType.batteryOptimization: PermissionInfo(
      name: 'تحسين البطارية',
      description: 'لضمان عمل التذكيرات في الخلفية',
      icon: Icons.battery_charging_full,
      color: Colors.orange,
      isCritical: true, // تم تغييرها إلى أساسية
    ),
    // للتوافق مع الكود القديم
    AppPermissionType.storage: PermissionInfo(
      name: 'التخزين',
      description: 'لحفظ الأذكار المفضلة',
      icon: Icons.storage,
      color: Colors.purple,
      isCritical: false,
    ),
    AppPermissionType.doNotDisturb: PermissionInfo(
      name: 'عدم الإزعاج',
      description: 'لتخصيص أوقات التذكير',
      icon: Icons.do_not_disturb,
      color: Colors.red,
      isCritical: false,
    ),
  };
  
  /// قائمة الأذونات الحرجة (فقط الأذونات المستخدمة فعلاً)
  static List<AppPermissionType> get criticalPermissions => [
    AppPermissionType.notification,
    AppPermissionType.location,
    AppPermissionType.batteryOptimization, // أصبحت أساسية
  ];
  
  /// قائمة الأذونات الاختيارية (فقط الأذونات المستخدمة فعلاً)
  static List<AppPermissionType> get optionalPermissions => [
    // لا توجد أذونات اختيارية حالياً
  ];
  
  /// الحصول على معلومات إذن محدد
  static PermissionInfo getInfo(AppPermissionType permission) {
    return permissions[permission] ?? 
        const PermissionInfo(
          name: 'إذن غير معروف',
          description: '',
          icon: Icons.security,
          color: Colors.grey,
          isCritical: false,
        );
  }
  
  /// الحصول على اسم الإذن
  static String getName(AppPermissionType permission) => 
      getInfo(permission).name;
  
  /// الحصول على وصف الإذن
  static String getDescription(AppPermissionType permission) => 
      getInfo(permission).description;
  
  /// الحصول على أيقونة الإذن
  static IconData getIcon(AppPermissionType permission) => 
      getInfo(permission).icon;
  
  /// الحصول على لون الإذن
  static Color getColor(AppPermissionType permission) => 
      getInfo(permission).color;
  
  /// هل الإذن حرج؟
  static bool isCritical(AppPermissionType permission) => 
      getInfo(permission).isCritical;
}