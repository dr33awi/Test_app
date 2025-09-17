// lib/core/infrastructure/services/permissions/permission_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'permission_service.dart';
import 'models/permission_state.dart';
import 'widgets/permission_dialogs.dart';
import '../storage/storage_service.dart';
import '../logging/logger_service.dart';

/// مدير الأذونات الموحد المحسن - بدون فحص دوري
class UnifiedPermissionManager {
  final PermissionService _permissionService;
  final StorageService _storage;
  final LoggerService _logger;
  
  // Singleton instance
  static UnifiedPermissionManager? _instance;
  
  // حالة Onboarding
  late OnboardingState _onboardingState;
  
  // آخر نتيجة فحص
  PermissionCheckResult? _lastCheckResult;
  
  // Streams للمراقبة
  final _stateController = StreamController<PermissionCheckResult>.broadcast();
  final _changeController = StreamController<PermissionChangeEvent>.broadcast();
  
  Stream<PermissionCheckResult> get stateStream => _stateController.stream;
  Stream<PermissionChangeEvent> get changeStream => _changeController.stream;
  
  // منع التكرار
  bool _hasCheckedThisSession = false;
  DateTime? _lastCheckTime;
  static const Duration _minCheckInterval = Duration(seconds: 2);
  
  // قائمة الأذونات الحرجة
  static const List<AppPermissionType> criticalPermissions = [
    AppPermissionType.notification,
    AppPermissionType.location,
    AppPermissionType.batteryOptimization,
  ];
  
  // Constructor خاص للـ Singleton
  UnifiedPermissionManager._({
    required PermissionService permissionService,
    required StorageService storage,
    required LoggerService logger,
  }) : _permissionService = permissionService,
       _storage = storage,
       _logger = logger {
    _initialize();
  }
  
  /// Factory method للحصول على instance واحد
  factory UnifiedPermissionManager.getInstance({
    required PermissionService permissionService,
    required StorageService storage,
    required LoggerService logger,
  }) {
    _instance ??= UnifiedPermissionManager._(
      permissionService: permissionService,
      storage: storage,
      logger: logger,
    );
    return _instance!;
  }
  
  /// التهيئة
  void _initialize() {
    _loadOnboardingState();
    _setupPermissionChangeListener();
    _logger.info(message: '[PermissionManager] Initialized (Optimized Mode)');
  }
  
  /// تحميل حالة Onboarding
  void _loadOnboardingState() {
    _onboardingState = OnboardingState.fromStorage(_storage);
    _logger.debug(message: '[PermissionManager] Onboarding state loaded', data: {
      'isNewUser': _onboardingState.isNewUser,
      'isCompleted': _onboardingState.isCompleted,
      'wasSkipped': _onboardingState.wasSkipped,
    });
  }
  
  /// الاستماع لتغييرات الأذونات من PermissionService
  void _setupPermissionChangeListener() {
    _permissionService.permissionChanges.listen((change) {
      final event = PermissionChangeEvent(
        permission: change.permission,
        oldStatus: change.oldStatus,
        newStatus: change.newStatus,
      );
      
      _changeController.add(event);
      
      _logger.info(message: '[PermissionManager] Permission change detected', data: {
        'permission': change.permission.toString(),
        'oldStatus': change.oldStatus.toString(),
        'newStatus': change.newStatus.toString(),
      });
    });
  }
  
  // ==================== Getters ====================
  
  bool get isNewUser => _onboardingState.isNewUser;
  bool get hasCheckedThisSession => _hasCheckedThisSession;
  PermissionCheckResult? get lastCheckResult => _lastCheckResult;
  OnboardingState get onboardingState => _onboardingState;
  
  // ==================== الدوال الرئيسية ====================
  
  /// الفحص الأولي - يُستدعى مرة واحدة عند بدء التطبيق
  Future<PermissionCheckResult> performInitialCheck() async {
    // منع التكرار
    if (_hasCheckedThisSession) {
      _logger.debug(message: '[PermissionManager] Already checked this session');
      return _lastCheckResult ?? PermissionCheckResult.success();
    }
    
    _hasCheckedThisSession = true;
    _lastCheckTime = DateTime.now();
    
    _logger.info(message: '[PermissionManager] Performing initial check');
    
    try {
      // إذا كان مستخدم جديد، لا نفحص
      if (isNewUser) {
        _logger.info(message: '[PermissionManager] New user - skipping permission check');
        return PermissionCheckResult.success();
      }
      
      // فحص الأذونات الحرجة فقط
      final result = await _checkCriticalPermissions();
      
      _lastCheckResult = result;
      _stateController.add(result);
      
      _logCheckResult(result);
      
      return result;
      
    } catch (e, s) {
      _logger.error(
        message: '[PermissionManager] Initial check failed',
        error: e,
        stackTrace: s,
      );
      
      final errorResult = PermissionCheckResult.error(e.toString());
      _lastCheckResult = errorResult;
      _stateController.add(errorResult);
      
      return errorResult;
    }
  }
  
  /// فحص سريع عند الحاجة (عند العودة من الخلفية أو الإعدادات)
  Future<PermissionCheckResult> performQuickCheck() async {
    // التحقق من الفترة الزمنية
    if (_lastCheckTime != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
      if (timeSinceLastCheck < _minCheckInterval) {
        _logger.debug(message: '[PermissionManager] Check throttled');
        return _lastCheckResult ?? PermissionCheckResult.success();
      }
    }
    
    _lastCheckTime = DateTime.now();
    _logger.debug(message: '[PermissionManager] Performing quick check');
    
    try {
      final result = await _checkCriticalPermissions();
      
      // تحديث فقط إذا تغيرت النتيجة
      if (_hasResultChanged(result)) {
        _lastCheckResult = result;
        _stateController.add(result);
        _logCheckResult(result);
      }
      
      return result;
    } catch (e) {
      _logger.error(message: '[PermissionManager] Quick check failed', error: e);
      return _lastCheckResult ?? PermissionCheckResult.error(e.toString());
    }
  }
  
  /// فحص الأذونات الحرجة فقط
  Future<PermissionCheckResult> _checkCriticalPermissions() async {
    final granted = <AppPermissionType>[];
    final missing = <AppPermissionType>[];
    final statuses = <AppPermissionType, AppPermissionStatus>{};
    
    // فحص الأذونات الحرجة بشكل متوازي
    final futures = <Future<void>>[];
    
    for (final permission in criticalPermissions) {
      futures.add(
        _checkSinglePermission(permission).then((status) {
          statuses[permission] = status;
          if (status == AppPermissionStatus.granted) {
            granted.add(permission);
          } else {
            missing.add(permission);
          }
        }),
      );
    }
    
    // انتظار جميع الفحوصات
    await Future.wait(futures);
    
    if (missing.isEmpty) {
      return PermissionCheckResult.success(
        granted: granted,
        statuses: statuses,
      );
    } else {
      return PermissionCheckResult.partial(
        granted: granted,
        missing: missing,
        statuses: statuses,
      );
    }
  }
  
  /// فحص إذن واحد
  Future<AppPermissionStatus> _checkSinglePermission(AppPermissionType permission) async {
    try {
      return await _permissionService.checkPermissionStatus(permission);
    } catch (e) {
      _logger.warning(
        message: '[PermissionManager] Failed to check permission',
        data: {'permission': permission.toString(), 'error': e.toString()},
      );
      return AppPermissionStatus.unknown;
    }
  }
  
  /// طلب إذن محدد مع عرض الشرح
  Future<bool> requestPermissionWithExplanation(
    BuildContext context,
    AppPermissionType permission, {
    String? customMessage,
    bool forceRequest = false,
  }) async {
    _logger.info(message: '[PermissionManager] Requesting permission', data: {
      'permission': permission.toString(),
      'forceRequest': forceRequest,
    });
    
    // فحص الحالة الحالية
    final currentStatus = await _permissionService.checkPermissionStatus(permission);
    
    if (currentStatus == AppPermissionStatus.granted) {
      _logger.debug(message: '[PermissionManager] Permission already granted');
      return true;
    }
    
    // إذا كان مرفوض نهائياً، فتح الإعدادات
    if (currentStatus == AppPermissionStatus.permanentlyDenied) {
      if (context.mounted) {
        await PermissionDialogs.showSettingsDialog(
          context: context,
          permissions: [permission],
          onOpenSettings: () => _permissionService.openAppSettings(),
        );
      }
      return false;
    }
    
    // عرض شرح الإذن
    if (context.mounted && !forceRequest) {
      final shouldRequest = await PermissionDialogs.showSinglePermission(
        context: context,
        permission: permission,
        customMessage: customMessage,
      );
      
      if (!shouldRequest) {
        _logger.info(message: '[PermissionManager] User cancelled permission request');
        return false;
      }
    }
    
    // طلب الإذن
    HapticFeedback.lightImpact();
    final newStatus = await _permissionService.requestPermission(permission);
    
    final granted = newStatus == AppPermissionStatus.granted;
    
    _logger.info(message: '[PermissionManager] Permission request result', data: {
      'permission': permission.toString(),
      'granted': granted,
      'status': newStatus.toString(),
    });
    
    // إرسال حدث التغيير
    _changeController.add(PermissionChangeEvent(
      permission: permission,
      oldStatus: currentStatus,
      newStatus: newStatus,
      wasUserInitiated: true,
    ));
    
    // فحص سريع بعد الطلب
    if (granted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        performQuickCheck();
      });
    }
    
    return granted;
  }
  
  /// طلب أذونات متعددة
  Future<PermissionCheckResult> requestMultiplePermissions(
    BuildContext context,
    List<AppPermissionType> permissions, {
    bool showExplanation = true,
  }) async {
    _logger.info(message: '[PermissionManager] Requesting multiple permissions', data: {
      'count': permissions.length,
    });
    
    // عرض شرح الأذونات
    if (showExplanation && context.mounted) {
      final shouldContinue = await PermissionDialogs.showExplanation(
        context: context,
        permissions: permissions,
      );
      
      if (!shouldContinue) {
        _logger.info(message: '[PermissionManager] User cancelled batch request');
        return PermissionCheckResult.error('User cancelled');
      }
    }
    
    // طلب الأذونات
    final granted = <AppPermissionType>[];
    final missing = <AppPermissionType>[];
    final statuses = <AppPermissionType, AppPermissionStatus>{};
    
    for (final permission in permissions) {
      try {
        final status = await _permissionService.requestPermission(permission);
        statuses[permission] = status;
        
        if (status == AppPermissionStatus.granted) {
          granted.add(permission);
        } else {
          missing.add(permission);
        }
        
        // تأخير بسيط بين الطلبات
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _logger.error(
          message: '[PermissionManager] Failed to request permission',
          error: e,
        );
        missing.add(permission);
      }
    }
    
    final result = missing.isEmpty
        ? PermissionCheckResult.success(granted: granted, statuses: statuses)
        : PermissionCheckResult.partial(
            granted: granted,
            missing: missing,
            statuses: statuses,
          );
    
    // عرض النتيجة
    if (context.mounted) {
      await PermissionDialogs.showResultDialog(
        context: context,
        granted: granted,
        denied: missing,
      );
    }
    
    // تحديث الحالة
    _lastCheckResult = result;
    _stateController.add(result);
    
    return result;
  }
  
  /// إكمال Onboarding
  Future<void> completeOnboarding({
    bool skipped = false,
    List<AppPermissionType>? grantedPermissions,
  }) async {
    _logger.info(message: '[PermissionManager] Completing onboarding', data: {
      'skipped': skipped,
      'grantedCount': grantedPermissions?.length ?? 0,
    });
    
    _onboardingState = OnboardingState(
      isCompleted: !skipped,
      wasSkipped: skipped,
      completedAt: DateTime.now(),
      grantedPermissions: grantedPermissions?.map((p) => p.toString()).toList(),
    );
    
    await _onboardingState.saveToStorage(_storage);
    
    // فحص الأذونات بعد Onboarding
    if (!skipped) {
      await performInitialCheck();
    }
  }
  
  /// فتح إعدادات التطبيق
  Future<bool> openAppSettings() async {
    _logger.info(message: '[PermissionManager] Opening app settings');
    return await _permissionService.openAppSettings();
  }
  
  /// إعادة تعيين (للتطوير والاختبار)
  Future<void> reset() async {
    _logger.warning(message: '[PermissionManager] Resetting all data');
    
    _hasCheckedThisSession = false;
    _lastCheckTime = null;
    _lastCheckResult = null;
    _onboardingState = const OnboardingState();
    
    // حذف من التخزين
    await _storage.remove('permission_onboarding_completed');
    await _storage.remove('user_skipped_onboarding');
    await _storage.remove('onboarding_completed_at');
    await _storage.remove('granted_permissions');
    
    _logger.info(message: '[PermissionManager] Reset completed');
  }
  
  /// التنظيف
  void dispose() {
    _logger.debug(message: '[PermissionManager] Disposing');
    _stateController.close();
    _changeController.close();
    _instance = null;
  }
  
  // ==================== دوال مساعدة ====================
  
  /// التحقق من تغيير النتيجة
  bool _hasResultChanged(PermissionCheckResult newResult) {
    if (_lastCheckResult == null) return true;
    
    // التحقق من تغيير في عدد الأذونات المعطلة
    return _lastCheckResult!.missingCount != newResult.missingCount ||
           _lastCheckResult!.grantedCount != newResult.grantedCount;
  }
  
  /// تسجيل نتيجة الفحص
  void _logCheckResult(PermissionCheckResult result) {
    _logger.info(message: '[PermissionManager] Check result', data: {
      'allGranted': result.allGranted,
      'grantedCount': result.grantedCount,
      'missingCount': result.missingCount,
      'hasCriticalMissing': result.hasCriticalMissing,
    });
    
    if (result.missingPermissions.isNotEmpty) {
      _logger.warning(
        message: '[PermissionManager] Missing permissions',
        data: {
          'missing': result.missingPermissions.map((p) => p.toString()).toList(),
        },
      );
    }
  }
  
  // ==================== دوال إضافية للتوافق ====================
  
  /// performBackgroundCheck محذوف - استخدم performQuickCheck بدلاً منه
  Future<PermissionCheckResult> performBackgroundCheck() async {
    return performQuickCheck();
  }
}