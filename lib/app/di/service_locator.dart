// lib/app/di/service_locator.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:battery_plus/battery_plus.dart';

// خدمات التخزين
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:athkar_app/core/infrastructure/services/storage/storage_service_impl.dart';

// خدمات السجلات
import 'package:athkar_app/core/infrastructure/services/logging/logger_service.dart';
import 'package:athkar_app/core/infrastructure/services/logging/logger_service_impl.dart';

// خدمات الإشعارات
import 'package:athkar_app/core/infrastructure/services/notifications/notification_manager.dart';
import 'package:athkar_app/core/infrastructure/services/notifications/notification_service.dart';
import 'package:athkar_app/core/infrastructure/services/notifications/notification_service_impl.dart';

// خدمات الأذونات (النظام الموحد الجديد)
import 'package:athkar_app/core/infrastructure/services/permissions/permission_service.dart';
import 'package:athkar_app/core/infrastructure/services/permissions/permission_service_impl.dart';
import 'package:athkar_app/core/infrastructure/services/permissions/permission_manager.dart';

// خدمات البطارية
import 'package:athkar_app/core/infrastructure/services/device/battery/battery_service.dart';
import 'package:athkar_app/core/infrastructure/services/device/battery/battery_service_impl.dart';

// إدارة الثيم
import 'package:athkar_app/app/themes/core/theme_notifier.dart';

// معالج الأخطاء
import '../../core/error/error_handler.dart';

// خدمات الميزات
import '../../features/prayer_times/services/prayer_times_service.dart';
import 'package:athkar_app/features/qibla/services/qibla_service.dart';
import 'package:athkar_app/features/athkar/services/athkar_service.dart';
import '../../features/dua/services/dua_service.dart';
import '../../features/tasbih/services/tasbih_service.dart';

// خدمات الإعدادات الموحدة
import '../../features/settings/services/settings_services_manager.dart';

final getIt = GetIt.instance;

/// Service Locator لإدارة جميع الخدمات في التطبيق
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  bool _isInitialized = false;

  /// تهيئة جميع الخدمات
  static Future<void> init() async {
    await _instance._initializeServices();
  }

  /// التحقق من تهيئة الخدمات
  static bool get isInitialized => _instance._isInitialized;

  /// تهيئة الخدمات الداخلية
  Future<void> _initializeServices() async {
    if (_isInitialized) {
      debugPrint('ServiceLocator: Services already initialized');
      return;
    }

    try {
      debugPrint('ServiceLocator: Starting services initialization...');

      // 1. الخدمات الأساسية
      await _registerCoreServices();

      // 2. خدمات التخزين والسجلات
      _registerLoggingServices();
      await _registerStorageServices();

      // 3. إدارة الثيم
      _registerThemeServices();

      // 4. خدمات الأذونات (النظام الموحد الجديد)
      _registerPermissionServices();

      // 5. خدمات الإشعارات
      await _registerNotificationServices();

      // 6. خدمات الجهاز
      _registerDeviceServices();

      // 7. معالج الأخطاء
      _registerErrorHandler();

      // 8. خدمات الميزات
      _registerFeatureServices();

      _isInitialized = true;
      debugPrint('ServiceLocator: All services initialized successfully ✓');
      
    } catch (e, stackTrace) {
      debugPrint('ServiceLocator: Error initializing services: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// تسجيل الخدمات الأساسية
  Future<void> _registerCoreServices() async {
    debugPrint('ServiceLocator: Registering core services...');

    // SharedPreferences
    if (!getIt.isRegistered<SharedPreferences>()) {
      final sharedPreferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    }

    // Battery
    if (!getIt.isRegistered<Battery>()) {
      getIt.registerLazySingleton<Battery>(() => Battery());
    }

    // Flutter Local Notifications Plugin
    if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
      getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
        () => FlutterLocalNotificationsPlugin(),
      );
    }
  }

  /// تسجيل خدمات السجلات
  void _registerLoggingServices() {
    debugPrint('ServiceLocator: Registering logging services...');

    if (!getIt.isRegistered<LoggerService>()) {
      getIt.registerLazySingleton<LoggerService>(
        () => LoggerServiceImpl(),
      );
    }
  }

  /// تسجيل خدمات التخزين
  Future<void> _registerStorageServices() async {
    debugPrint('ServiceLocator: Registering storage services...');

    if (!getIt.isRegistered<StorageService>()) {
      getIt.registerLazySingleton<StorageService>(
        () => StorageServiceImpl(
          getIt<SharedPreferences>(),
          logger: getIt<LoggerService>(),
        ),
      );
    }
  }

  /// تسجيل إدارة الثيم
  void _registerThemeServices() {
    debugPrint('ServiceLocator: Registering theme services...');
    
    if (!getIt.isRegistered<ThemeNotifier>()) {
      getIt.registerLazySingleton<ThemeNotifier>(
        () => ThemeNotifier(getIt<StorageService>()),
      );
    }
  }

  /// تسجيل خدمات الأذونات (النظام الموحد الجديد)
  void _registerPermissionServices() {
    debugPrint('ServiceLocator: Registering unified permission services...');

    // خدمة الأذونات الأساسية
    if (!getIt.isRegistered<PermissionService>()) {
      getIt.registerLazySingleton<PermissionService>(
        () => PermissionServiceImpl(
          logger: getIt<LoggerService>(),
          storage: getIt<StorageService>(),
        ),
      );
      debugPrint('ServiceLocator: PermissionService registered');
    }

    // مدير الأذونات الموحد
    if (!getIt.isRegistered<UnifiedPermissionManager>()) {
      getIt.registerLazySingleton<UnifiedPermissionManager>(
        () => UnifiedPermissionManager.getInstance(
          permissionService: getIt<PermissionService>(),
          storage: getIt<StorageService>(),
          logger: getIt<LoggerService>(),
        ),
      );
      debugPrint('ServiceLocator: UnifiedPermissionManager registered successfully');
    }
  }

  /// تسجيل خدمات الإشعارات
  Future<void> _registerNotificationServices() async {
    debugPrint('ServiceLocator: Registering notification services...');

    // خدمة الإشعارات الأساسية
    if (!getIt.isRegistered<NotificationService>()) {
      getIt.registerLazySingleton<NotificationService>(
        () => NotificationServiceImpl(
          prefs: getIt<SharedPreferences>(),
          plugin: getIt<FlutterLocalNotificationsPlugin>(),
          battery: getIt<Battery>(),
        ),
      );
    }

    // تهيئة مدير الإشعارات
    try {
      await NotificationManager.initialize(getIt<NotificationService>());
      debugPrint('ServiceLocator: Notification manager initialized');
    } catch (e) {
      debugPrint('ServiceLocator: Error initializing notification manager: $e');
      // يمكن المتابعة حتى لو فشلت الإشعارات
    }
  }

  /// تسجيل خدمات الجهاز
  void _registerDeviceServices() {
    debugPrint('ServiceLocator: Registering device services...');

    // خدمة البطارية
    if (!getIt.isRegistered<BatteryService>()) {
      getIt.registerLazySingleton<BatteryService>(
        () => BatteryServiceImpl(
          battery: getIt<Battery>(),
          logger: getIt<LoggerService>(),
          
        ),
      );
    }
  }

  /// تسجيل معالج الأخطاء
  void _registerErrorHandler() {
    debugPrint('ServiceLocator: Registering error handler...');

    if (!getIt.isRegistered<AppErrorHandler>()) {
      getIt.registerLazySingleton<AppErrorHandler>(
        () => AppErrorHandler(getIt<LoggerService>()),
      );
    }
  }

  /// تسجيل خدمات الميزات
  void _registerFeatureServices() {
    debugPrint('ServiceLocator: Registering feature services...');
    
    // خدمة مواقيت الصلاة
    if (!getIt.isRegistered<PrayerTimesService>()) {
      getIt.registerLazySingleton<PrayerTimesService>(
        () => PrayerTimesService(
          logger: getIt<LoggerService>(),
          storage: getIt<StorageService>(),
          permissionService: getIt<PermissionService>(),
        ),
      );
    }

    // خدمة الأذكار
    if (!getIt.isRegistered<AthkarService>()) {
      getIt.registerLazySingleton<AthkarService>(
        () => AthkarService(
          logger: getIt<LoggerService>(),
          storage: getIt<StorageService>(),
        ),
      );
      debugPrint('ServiceLocator: AthkarService registered successfully');
    }

    // خدمة الأدعية
    if (!getIt.isRegistered<DuaService>()) {
      getIt.registerLazySingleton<DuaService>(
        () => DuaService(
          storage: getIt<StorageService>(),
          logger: getIt<LoggerService>(),
        ),
      );
      debugPrint('ServiceLocator: DuaService registered successfully');
    }
    
    // خدمة التسبيح - يجب تسجيلها كـ Factory وليس Singleton
    // لأنها تحتاج لإنشاء instance جديد في كل مرة
    if (!getIt.isRegistered<TasbihService>()) {
      getIt.registerFactory<TasbihService>(
        () => TasbihService(
          storage: getIt<StorageService>(),
          logger: getIt<LoggerService>(),
        ),
      );
      debugPrint('ServiceLocator: TasbihService registered successfully');
    }
    
    // تسجيل خدمة القبلة
    _registerQiblaServices();
    
    // تسجيل خدمات الإعدادات الموحدة
    _registerSettingsServices();
  }
  
  /// تسجيل خدمات القبلة
  void _registerQiblaServices() {
    debugPrint('ServiceLocator: Registering qibla services...');
    
    if (!getIt.isRegistered<QiblaService>()) {
      getIt.registerFactory<QiblaService>(
        () => QiblaService(
          logger: getIt<LoggerService>(),
          storage: getIt<StorageService>(),
          permissionService: getIt<PermissionService>(),
        ),
      );
    }
  }

  /// تسجيل خدمات الإعدادات الموحدة
  void _registerSettingsServices() {
    debugPrint('ServiceLocator: Registering settings services...');
    
    if (!getIt.isRegistered<SettingsServicesManager>()) {
      final settingsManager = SettingsServicesManager(
        storage: getIt<StorageService>(),
        permissionService: getIt<PermissionService>(),
        logger: getIt<LoggerService>(),
        themeNotifier: getIt<ThemeNotifier>(),
      );
      
      getIt.registerSingleton<SettingsServicesManager>(settingsManager);
      debugPrint('ServiceLocator: SettingsServicesManager registered successfully');
    }
  }

  /// التحقق من تهيئة جميع الخدمات المطلوبة
  static bool areServicesReady() {
    final requiredServices = [
      // الخدمات الأساسية
      getIt.isRegistered<StorageService>(),
      getIt.isRegistered<LoggerService>(),
      getIt.isRegistered<ThemeNotifier>(),
      
      // خدمات الأذونات
      getIt.isRegistered<PermissionService>(),
      getIt.isRegistered<UnifiedPermissionManager>(),
      
      // خدمات الجهاز
      getIt.isRegistered<BatteryService>(),
      
      // خدمات الميزات
      getIt.isRegistered<PrayerTimesService>(),
      getIt.isRegistered<AthkarService>(),
      getIt.isRegistered<DuaService>(),
      getIt.isRegistered<TasbihService>(),
      getIt.isRegistered<SettingsServicesManager>(),
    ];
    
    final allReady = requiredServices.every((service) => service);
    
    if (!allReady) {
      debugPrint('ServiceLocator: Some services are not ready');
      for (int i = 0; i < requiredServices.length; i++) {
        if (!requiredServices[i]) {
          debugPrint('ServiceLocator: Service at index $i is not registered');
        }
      }
    }
    
    return allReady;
  }

  /// إعادة تعيين جميع الخدمات
  static Future<void> reset() async {
    debugPrint('ServiceLocator: Resetting all services...');
    
    try {
      await _instance._cleanup();
      await getIt.reset();
      _instance._isInitialized = false;
      debugPrint('ServiceLocator: All services reset');
    } catch (e) {
      debugPrint('ServiceLocator: Error resetting: $e');
    }
  }

  /// تنظيف الموارد
  Future<void> _cleanup() async {
    debugPrint('ServiceLocator: Cleaning up resources...');

    try {
      // تنظيف مدير الإعدادات
      if (getIt.isRegistered<SettingsServicesManager>()) {
        getIt<SettingsServicesManager>().dispose();
      }

      // تنظيف إدارة الثيم
      if (getIt.isRegistered<ThemeNotifier>()) {
        getIt<ThemeNotifier>().dispose();
      }

      // تنظيف خدمات الميزات
      if (getIt.isRegistered<PrayerTimesService>()) {
        getIt<PrayerTimesService>().dispose();
      }
      
      if (getIt.isRegistered<AthkarService>()) {
        getIt<AthkarService>().dispose();
      }

      // تنظيف خدمة البطارية
      if (getIt.isRegistered<BatteryService>()) {
        await getIt<BatteryService>().dispose();
      }

      // تنظيف الإشعارات
      if (getIt.isRegistered<NotificationService>()) {
        await getIt<NotificationService>().dispose();
      }

      // تنظيف مدير الأذونات الموحد
      if (getIt.isRegistered<UnifiedPermissionManager>()) {
        getIt<UnifiedPermissionManager>().dispose();
        debugPrint('ServiceLocator: UnifiedPermissionManager cleaned up');
      }

      // تنظيف خدمة الأذونات
      if (getIt.isRegistered<PermissionService>()) {
        await getIt<PermissionService>().dispose();
      }

      debugPrint('ServiceLocator: Resources cleaned up');
    } catch (e) {
      debugPrint('ServiceLocator: Error cleaning up resources: $e');
    }
  }

  /// التنظيف عند إغلاق التطبيق
  static Future<void> dispose() async {
    if (!_instance._isInitialized) return;

    debugPrint('ServiceLocator: Final cleanup...');
    
    try {
      await _instance._cleanup();
      await reset();
      debugPrint('ServiceLocator: Final cleanup completed');
    } catch (e) {
      debugPrint('ServiceLocator: Error in final cleanup: $e');
    }
  }
}

// ==================== Helper Functions ====================

/// دالة مساعدة للوصول السريع للخدمات
T getService<T extends Object>() {
  if (!getIt.isRegistered<T>()) {
    throw Exception('Service $T is not registered. Make sure to call ServiceLocator.init() first.');
  }
  return getIt<T>();
}

/// دالة للحصول على خدمة مع التحقق من التهيئة
T? getServiceSafe<T extends Object>() {
  try {
    return getIt.isRegistered<T>() ? getIt<T>() : null;
  } catch (e) {
    debugPrint('Error getting service $T: $e');
    return null;
  }
}

/// Extension methods لسهولة الوصول للخدمات
extension ServiceLocatorExtensions on BuildContext {
  /// الحصول على خدمة بسهولة
  T getService<T extends Object>() => getIt<T>();
  
  /// التحقق من وجود خدمة
  bool hasService<T extends Object>() => getIt.isRegistered<T>();
  
  // ==================== الخدمات الأساسية ====================
  
  /// الحصول على خدمة التخزين
  StorageService get storageService => getIt<StorageService>();
  
  /// الحصول على خدمة الإشعارات
  NotificationService get notificationService => getIt<NotificationService>();
  
  /// الحصول على خدمة الأذونات
  PermissionService get permissionService => getIt<PermissionService>();
  
  /// الحصول على مدير الأذونات الموحد
  UnifiedPermissionManager get permissionManager => getIt<UnifiedPermissionManager>();
  
  /// الحصول على خدمة السجلات
  LoggerService get loggerService => getIt<LoggerService>();
  
  /// الحصول على معالج الأخطاء
  AppErrorHandler get errorHandler => getIt<AppErrorHandler>();
  
  /// الحصول على خدمة البطارية
  BatteryService get batteryService => getIt<BatteryService>();
  
  // ==================== خدمات الميزات ====================
  
  /// الحصول على خدمة مواقيت الصلاة
  PrayerTimesService get prayerTimesService => getIt<PrayerTimesService>();
  
  /// الحصول على خدمة الأذكار
  AthkarService get athkarService => getIt<AthkarService>();
  
  /// الحصول على خدمة الأدعية
  DuaService get duaService => getIt<DuaService>();
  
  /// الحصول على خدمة التسبيح
  TasbihService get tasbihService => getIt<TasbihService>();
  
  /// الحصول على خدمة القبلة
  QiblaService get qiblaService => getIt<QiblaService>();
  
  // ==================== خدمات الإدارة ====================
  
  /// الحصول على إدارة الثيم
  ThemeNotifier get themeNotifier => getIt<ThemeNotifier>();
  
  /// الحصول على مدير الخدمات الموحد للإعدادات
  SettingsServicesManager get settingsManager => getIt<SettingsServicesManager>();
  
  // ==================== وظائف مساعدة ====================
  
  /// طلب إذن بسهولة (باستخدام المدير الموحد)
  Future<bool> requestPermission(
    AppPermissionType permission, {
    String? customMessage,
    bool forceRequest = false,
  }) async {
    return await permissionManager.requestPermissionWithExplanation(
      this,
      permission,
      customMessage: customMessage,
      forceRequest: forceRequest,
    );
  }
  
  /// فحص إذن سريع
  Future<bool> hasPermission(AppPermissionType permission) async {
    final status = await permissionService.checkPermissionStatus(permission);
    return status == AppPermissionStatus.granted;
  }
}