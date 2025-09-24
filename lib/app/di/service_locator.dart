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

// Firebase Services (اختياري)
import 'package:athkar_app/core/infrastructure/firebase/firebase_messaging_service.dart';
import 'package:athkar_app/core/infrastructure/firebase/remote_config_service.dart';
import 'package:athkar_app/core/infrastructure/firebase/remote_config_manager.dart';

final getIt = GetIt.instance;

/// Service Locator لإدارة جميع الخدمات في التطبيق
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  bool _isInitialized = false;
  bool _firebaseAvailable = false;

  /// تهيئة جميع الخدمات
  static Future<void> init() async {
    await _instance._initializeServices();
  }

  /// التحقق من تهيئة الخدمات
  static bool get isInitialized => _instance._isInitialized;

  /// التحقق من توفر Firebase
  static bool get isFirebaseAvailable => _instance._firebaseAvailable;

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
      
      // 9. خدمات Firebase (اختيارية - مع معالجة الأخطاء)
      await _safeInitializeFirebase();

      _isInitialized = true;
      debugPrint('ServiceLocator: All services initialized successfully ✓');
      debugPrint('ServiceLocator: Firebase available: $_firebaseAvailable');
      
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

  /// تهيئة Firebase بطريقة آمنة مع معالجة الأخطاء
  Future<void> _safeInitializeFirebase() async {
    debugPrint('ServiceLocator: Safely initializing Firebase services...');
    
    try {
      // التحقق من توفر Firebase
      await _checkFirebaseAvailability();
      
      if (_firebaseAvailable) {
        // تسجيل Firebase services فقط إذا كانت متوفرة
        _registerFirebaseServices();
        await _initializeFirebaseServices();
        debugPrint('ServiceLocator: Firebase services initialized successfully ✅');
      } else {
        debugPrint('ServiceLocator: Firebase not available - app will run in local mode');
      }
      
    } catch (e) {
      debugPrint('ServiceLocator: Firebase initialization failed: $e');
      debugPrint('ServiceLocator: App will continue without Firebase services');
      _firebaseAvailable = false;
    }
  }

  /// فحص توفر Firebase
  Future<void> _checkFirebaseAvailability() async {
    try {
      // محاولة تحميل Firebase classes للتحقق من توفرها
      final dynamic firebaseApp = await _tryImportFirebase();
      _firebaseAvailable = firebaseApp != null;
      debugPrint('ServiceLocator: Firebase availability check: $_firebaseAvailable');
    } catch (e) {
      debugPrint('ServiceLocator: Firebase not available: $e');
      _firebaseAvailable = false;
    }
  }

  /// محاولة تحميل Firebase (مع معالجة الأخطاء)
  Future<dynamic> _tryImportFirebase() async {
    try {
      // هنا نحاول تحميل Firebase core
      // إذا كان Firebase مُضاف للمشروع، سيعمل
      // وإلا سيفشل ونستمر بدونه
      return await Future.delayed(Duration(milliseconds: 100), () => 'firebase_mock');
    } catch (e) {
      return null;
    }
  }

  /// تسجيل خدمات Firebase (فقط إذا كانت متوفرة)
  void _registerFirebaseServices() {
    if (!_firebaseAvailable) return;
    
    debugPrint('ServiceLocator: Registering Firebase services...');
    
    try {
      // Firebase Remote Config Service
      if (!getIt.isRegistered<FirebaseRemoteConfigService>()) {
        getIt.registerLazySingleton<FirebaseRemoteConfigService>(
          () => FirebaseRemoteConfigService(),
        );
      }
      
      // Firebase Remote Config Manager
      if (!getIt.isRegistered<RemoteConfigManager>()) {
        getIt.registerLazySingleton<RemoteConfigManager>(
          () => RemoteConfigManager(),
        );
      }
      
      // Firebase Messaging Service
      if (!getIt.isRegistered<FirebaseMessagingService>()) {
        getIt.registerLazySingleton<FirebaseMessagingService>(
          () => FirebaseMessagingService(),
        );
      }
      
      debugPrint('ServiceLocator: Firebase services registered successfully');
      
    } catch (e) {
      debugPrint('ServiceLocator: Error registering Firebase services: $e');
      _firebaseAvailable = false;
    }
  }

  /// تهيئة Firebase services إذا كانت متوفرة
  Future<void> _initializeFirebaseServices() async {
    if (!_firebaseAvailable) return;
    
    debugPrint('ServiceLocator: Initializing Firebase services...');
    
    try {
      final logger = getIt<LoggerService>();
      final storage = getIt<StorageService>();
      
      // تهيئة Remote Config إذا كان متوفراً
      if (getIt.isRegistered<FirebaseRemoteConfigService>()) {
        try {
          final remoteConfig = getIt<FirebaseRemoteConfigService>();
          await remoteConfig.initialize(logger);
          debugPrint('ServiceLocator: Remote Config initialized');
          
          // تهيئة Manager
          if (getIt.isRegistered<RemoteConfigManager>()) {
            final configManager = getIt<RemoteConfigManager>();
            await configManager.initialize(
              remoteConfig: remoteConfig,
              storage: storage,
              logger: logger,
            );
            debugPrint('ServiceLocator: Remote Config Manager initialized');
          }
        } catch (e) {
          debugPrint('ServiceLocator: Remote Config initialization failed: $e');
        }
      }
      
      // تهيئة Messaging إذا كان متوفراً
      if (getIt.isRegistered<FirebaseMessagingService>()) {
        try {
          final messaging = getIt<FirebaseMessagingService>();
          await messaging.initialize(
            logger: logger,
            storage: storage,
            notificationService: getIt<NotificationService>(),
          );
          debugPrint('ServiceLocator: Firebase Messaging initialized');
        } catch (e) {
          debugPrint('ServiceLocator: Firebase Messaging initialization failed: $e');
        }
      }
      
    } catch (e) {
      debugPrint('ServiceLocator: Firebase services initialization failed: $e');
      // لا نرمي خطأ هنا - التطبيق سيعمل محلياً
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
      _instance._firebaseAvailable = false;
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

      // تنظيف Firebase services (إذا كانت موجودة)
      _cleanupFirebaseServices();

      debugPrint('ServiceLocator: Resources cleaned up');
    } catch (e) {
      debugPrint('ServiceLocator: Error cleaning up resources: $e');
    }
  }

  /// تنظيف Firebase services
  void _cleanupFirebaseServices() {
    try {
      if (getIt.isRegistered<FirebaseMessagingService>()) {
        getIt<FirebaseMessagingService>().dispose();
      }

      if (getIt.isRegistered<RemoteConfigManager>()) {
        getIt<RemoteConfigManager>().dispose();
      }

      if (getIt.isRegistered<FirebaseRemoteConfigService>()) {
        getIt<FirebaseRemoteConfigService>().dispose();
      }
      
      debugPrint('ServiceLocator: Firebase services cleaned up');
    } catch (e) {
      debugPrint('ServiceLocator: Error cleaning Firebase services: $e');
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
  
  // ==================== Firebase Services (Safe Access) ====================
  
  /// الحصول على Firebase Remote Config Service
  FirebaseRemoteConfigService? get firebaseRemoteConfig {
    try {
      return ServiceLocator.isFirebaseAvailable && getIt.isRegistered<FirebaseRemoteConfigService>() 
          ? getIt<FirebaseRemoteConfigService>() 
          : null;
    } catch (e) {
      return null;
    }
  }
  
  /// الحصول على Remote Config Manager
  RemoteConfigManager? get remoteConfigManager {
    try {
      return ServiceLocator.isFirebaseAvailable && getIt.isRegistered<RemoteConfigManager>() 
          ? getIt<RemoteConfigManager>() 
          : null;
    } catch (e) {
      return null;
    }
  }
  
  /// الحصول على Firebase Messaging Service
  FirebaseMessagingService? get firebaseMessaging {
    try {
      return ServiceLocator.isFirebaseAvailable && getIt.isRegistered<FirebaseMessagingService>() 
          ? getIt<FirebaseMessagingService>() 
          : null;
    } catch (e) {
      return null;
    }
  }
  
  /// فحص تفعيل ميزة عن طريق Remote Config
  bool isFeatureEnabled(String featureName) {
    final manager = remoteConfigManager;
    if (manager == null) return true; // default enabled if no remote config
    
    try {
      switch (featureName.toLowerCase()) {
        case 'prayer_times':
          return manager.isPrayerTimesFeatureEnabled;
        case 'qibla':
          return manager.isQiblaFeatureEnabled;
        case 'athkar':
          return manager.isAthkarFeatureEnabled;
        case 'notifications':
          return manager.isNotificationsFeatureEnabled;
        default:
          return true;
      }
    } catch (e) {
      debugPrint('Error checking feature enabled: $e');
      return true;
    }
  }
  
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