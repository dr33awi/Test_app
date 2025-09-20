// lib/core/infrastructure/services/permissions/permission_service.dart (منظف)

import 'dart:async';

/// أنواع الأذونات المستخدمة فعلياً في التطبيق
enum AppPermissionType {
  location,           // لحساب أوقات الصلاة
  notification,       // للتذكيرات
  batteryOptimization, // لضمان عمل التطبيق في الخلفية
}

/// حالة الإذن
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  provisional,
  unknown,
}

/// نتيجة طلب أذونات متعددة (مبسطة)
class PermissionBatchResult {
  final Map<AppPermissionType, AppPermissionStatus> results;
  final bool allGranted;
  final List<AppPermissionType> deniedPermissions;
  final bool wasCancelled;

  PermissionBatchResult({
    required this.results,
    required this.allGranted,
    required this.deniedPermissions,
    this.wasCancelled = false,
  });

  factory PermissionBatchResult.cancelled() => PermissionBatchResult(
    results: {},
    allGranted: false,
    deniedPermissions: [],
    wasCancelled: true,
  );
}

/// معلومات تقدم طلب الأذونات
class PermissionProgress {
  final int current;
  final int total;
  final AppPermissionType currentPermission;

  PermissionProgress({
    required this.current,
    required this.total,
    required this.currentPermission,
  });

  double get percentage => (current / total) * 100;
}

/// واجهة خدمة الأذونات المبسطة
abstract class PermissionService {
  // الطلبات الأساسية
  Future<AppPermissionStatus> requestPermission(AppPermissionType permission);
  Future<PermissionBatchResult> requestMultiplePermissions({
    required List<AppPermissionType> permissions,
    Function(PermissionProgress)? onProgress,
    bool showExplanationDialog = true,
  });
  
  // فحص الحالة
  Future<AppPermissionStatus> checkPermissionStatus(AppPermissionType permission);
  Future<Map<AppPermissionType, AppPermissionStatus>> checkAllPermissions();
  
  // الإعدادات
  Future<bool> openAppSettings();
  
  // المساعدات
  String getPermissionDescription(AppPermissionType permission);
  String getPermissionName(AppPermissionType permission);
  
  // دوال مساعدة للإشعارات (مبسطة)
  Future<bool> checkNotificationPermission() async {
    final status = await checkPermissionStatus(AppPermissionType.notification);
    return status == AppPermissionStatus.granted;
  }
  
  Future<bool> requestNotificationPermission() async {
    final status = await requestPermission(AppPermissionType.notification);
    return status == AppPermissionStatus.granted;
  }
  
  // Stream للاستماع لتغييرات الأذونات
  Stream<PermissionChange> get permissionChanges;
  
  // Cache
  void clearPermissionCache();
  
  // تنظيف الموارد
  Future<void> dispose();
}

/// تغيير في حالة الإذن
class PermissionChange {
  final AppPermissionType permission;
  final AppPermissionStatus oldStatus;
  final AppPermissionStatus newStatus;
  final DateTime timestamp;

  PermissionChange({
    required this.permission,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
  });
}