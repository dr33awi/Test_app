// lib/core/infrastructure/services/permissions/models/permission_state.dart

import '../permission_service.dart';
import '../../storage/storage_service.dart';

/// حالة Onboarding المبسطة
class OnboardingState {
  final bool isCompleted;
  final bool wasSkipped;
  final DateTime? completedAt;
  final List<String>? grantedPermissions;
  
  const OnboardingState({
    this.isCompleted = false,
    this.wasSkipped = false,
    this.completedAt,
    this.grantedPermissions,
  });
  
  /// هل المستخدم جديد
  bool get isNewUser => !isCompleted && !wasSkipped;
  
  /// هل يحتاج فحص الأذونات
  bool get needsPermissionCheck => isCompleted || wasSkipped;
  
  /// هل مر وقت كافي منذ آخر فحص (24 ساعة)
  bool get shouldRecheckPermissions {
    if (completedAt == null) return true;
    final daysSinceCompletion = DateTime.now().difference(completedAt!).inDays;
    return daysSinceCompletion > 0;
  }
  
  /// تحميل من التخزين
  factory OnboardingState.fromStorage(StorageService storage) {
    final completedAtString = storage.getString('onboarding_completed_at');
    final grantedList = storage.getStringList('granted_permissions');
    
    return OnboardingState(
      isCompleted: storage.getBool('permission_onboarding_completed') ?? false,
      wasSkipped: storage.getBool('user_skipped_onboarding') ?? false,
      completedAt: completedAtString != null 
          ? DateTime.tryParse(completedAtString)
          : null,
      grantedPermissions: grantedList,
    );
  }
  
  /// حفظ في التخزين
  Future<void> saveToStorage(StorageService storage) async {
    await storage.setBool('permission_onboarding_completed', isCompleted);
    await storage.setBool('user_skipped_onboarding', wasSkipped);
    
    if (completedAt != null) {
      await storage.setString('onboarding_completed_at', completedAt!.toIso8601String());
    }
    
    if (grantedPermissions != null && grantedPermissions!.isNotEmpty) {
      await storage.setStringList('granted_permissions', grantedPermissions!);
    }
  }
  
  /// نسخة محدثة
  OnboardingState copyWith({
    bool? isCompleted,
    bool? wasSkipped,
    DateTime? completedAt,
    List<String>? grantedPermissions,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      wasSkipped: wasSkipped ?? this.wasSkipped,
      completedAt: completedAt ?? this.completedAt,
      grantedPermissions: grantedPermissions ?? this.grantedPermissions,
    );
  }
}

/// نتيجة فحص الأذونات المبسطة
class PermissionCheckResult {
  final bool allGranted;
  final List<AppPermissionType> grantedPermissions;
  final List<AppPermissionType> missingPermissions;
  final Map<AppPermissionType, AppPermissionStatus> statuses;
  final bool hasErrors;
  final String? errorMessage;
  final DateTime timestamp;
  
  PermissionCheckResult({
    required this.allGranted,
    this.grantedPermissions = const [],
    this.missingPermissions = const [],
    this.statuses = const {},
    this.hasErrors = false,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// نتيجة نجاح كامل
  factory PermissionCheckResult.success({
    List<AppPermissionType> granted = const [],
    Map<AppPermissionType, AppPermissionStatus> statuses = const {},
  }) {
    return PermissionCheckResult(
      allGranted: true,
      grantedPermissions: granted,
      missingPermissions: [],
      statuses: statuses,
    );
  }
  
  /// نتيجة جزئية
  factory PermissionCheckResult.partial({
    required List<AppPermissionType> granted,
    required List<AppPermissionType> missing,
    Map<AppPermissionType, AppPermissionStatus> statuses = const {},
  }) {
    return PermissionCheckResult(
      allGranted: false,
      grantedPermissions: granted,
      missingPermissions: missing,
      statuses: statuses,
    );
  }
  
  /// نتيجة خطأ
  factory PermissionCheckResult.error(String message) {
    return PermissionCheckResult(
      allGranted: false,
      hasErrors: true,
      errorMessage: message,
    );
  }
  
  /// عدد الأذونات المفعلة
  int get grantedCount => grantedPermissions.length;
  
  /// عدد الأذونات المعطلة
  int get missingCount => missingPermissions.length;
  
  /// النسبة المئوية للأذونات المفعلة
  double get grantedPercentage {
    final total = grantedCount + missingCount;
    if (total == 0) return 0.0;
    return grantedCount / total;
  }
  
  /// هل هناك أذونات حرجة مفقودة
  bool get hasCriticalMissing {
    const critical = [
      AppPermissionType.notification,
      AppPermissionType.location,
    ];
    return missingPermissions.any((p) => critical.contains(p));
  }
}

/// حدث تغيير الأذونات
class PermissionChangeEvent {
  final AppPermissionType permission;
  final AppPermissionStatus oldStatus;
  final AppPermissionStatus newStatus;
  final DateTime timestamp;
  final bool wasUserInitiated;
  
  PermissionChangeEvent({
    required this.permission,
    required this.oldStatus,
    required this.newStatus,
    this.wasUserInitiated = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get wasGranted => 
      oldStatus != AppPermissionStatus.granted && 
      newStatus == AppPermissionStatus.granted;
  
  bool get wasRevoked => 
      oldStatus == AppPermissionStatus.granted && 
      newStatus != AppPermissionStatus.granted;
}