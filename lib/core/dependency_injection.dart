// lib/core/dependency_injection.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:battery_plus/battery_plus.dart';

// Core services
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:athkar_app/core/infrastructure/services/storage/storage_service_impl.dart';

// Notification services
import 'package:athkar_app/core/infrastructure/services/notifications/notification_manager.dart';
import 'package:athkar_app/core/infrastructure/services/notifications/notification_service.dart';
import 'package:athkar_app/core/infrastructure/services/notifications/notification_service_impl.dart';

// Permission services
import 'package:athkar_app/core/infrastructure/services/permissions/permission_service.dart';
import 'package:athkar_app/core/infrastructure/services/permissions/permission_service_impl.dart';
import 'package:athkar_app/core/infrastructure/services/permissions/permission_manager.dart';

// Device services
import 'package:athkar_app/core/infrastructure/services/device/battery/battery_service.dart';
import 'package:athkar_app/core/infrastructure/services/device/battery/battery_service_impl.dart';

// Theme services
import 'package:athkar_app/app/themes/core/theme_notifier.dart';

// Error handling
import '../error/error_handler.dart';

// Feature services
import '../../features/prayer_times/services/prayer_times_service.dart';
import 'package:athkar_app/features/qibla/services/qibla_service.dart';
import 'package:athkar_app/features/athkar/services/athkar_service.dart';
import '../../features/dua/services/dua_service.dart';
import '../../features/tasbih/services/tasbih_service.dart';

// Settings services
import '../../features/settings/services/settings_services_manager.dart';

// Firebase services (optional)
import 'package:athkar_app/core/infrastructure/firebase/firebase_messaging_service.dart';
import 'package:athkar_app/core/infrastructure/firebase/remote_config_service.dart';
import 'package:athkar_app/core/infrastructure/firebase/remote_config_manager.dart';

final getIt = GetIt.instance;

/// Centralized Dependency Injection Manager
/// Implements lazy initialization pattern for all services to optimize memory usage and startup performance
class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  bool _isInitialized = false;
  bool _firebaseAvailable = false;

  /// Initialize all services with lazy loading pattern
  static Future<void> initialize() async {
    await _instance._initializeServices();
  }

  /// Check if services are initialized
  static bool get isInitialized => _instance._isInitialized;

  /// Check if Firebase services are available
  static bool get isFirebaseAvailable => _instance._firebaseAvailable;

  /// Main service initialization method
  Future<void> _initializeServices() async {
    if (_isInitialized) {
      debugPrint('DependencyInjection: Services already initialized');
      return;
    }

    try {
      debugPrint('DependencyInjection: Starting lazy service initialization...');

      // 1. Core system services (essential for app startup)
      await _registerCoreServices();

      // 2. Storage services (needed by many other services)
      _registerStorageServices();

      // 3. Theme services (UI related)
      _registerThemeServices();

      // 4. Permission services (needed for device access)
      _registerPermissionServices();

      // 5. Device services (hardware access)
      _registerDeviceServices();

      // 6. Notification services (user engagement)
      _registerNotificationServices();

      // 7. Error handling (monitoring and debugging)
      _registerErrorHandler();

      // 8. Feature services (app functionality - all lazy)
      _registerFeatureServices();

      // 9. Settings services (configuration management)
      _registerSettingsServices();

      // 10. Firebase services (optional - completely lazy)
      await _registerFirebaseServices();

      _isInitialized = true;
      debugPrint('DependencyInjection: All services registered for lazy initialization ✅');
      debugPrint('DependencyInjection: Firebase available: $_firebaseAvailable');

    } catch (e, stackTrace) {
      debugPrint('DependencyInjection: Error initializing services: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Register core system services with lazy loading
  Future<void> _registerCoreServices() async {
    debugPrint('DependencyInjection: Registering core services...');

    // SharedPreferences - Lazy async initialization
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerLazySingletonAsync<SharedPreferences>(
        () async {
          try {
            final prefs = await SharedPreferences.getInstance();
            debugPrint('DependencyInjection: SharedPreferences initialized lazily');
            return prefs;
          } catch (e) {
            debugPrint('DependencyInjection: Error initializing SharedPreferences: $e');
            rethrow;
          }
        },
      );
      // Ensure SharedPreferences is ready for dependent services
      await getIt.isReady<SharedPreferences>();
    }

    // Battery - Lazy initialization
    if (!getIt.isRegistered<Battery>()) {
      getIt.registerLazySingleton<Battery>(
        () {
          try {
            final battery = Battery();
            debugPrint('DependencyInjection: Battery service created lazily');
            return battery;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating Battery service: $e');
            rethrow;
          }
        },
      );
    }

    // Flutter Local Notifications Plugin - Lazy initialization
    if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
      getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
        () {
          try {
            final plugin = FlutterLocalNotificationsPlugin();
            debugPrint('DependencyInjection: NotificationsPlugin created lazily');
            return plugin;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating NotificationsPlugin: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register storage services with lazy loading
  void _registerStorageServices() {
    debugPrint('DependencyInjection: Registering storage services...');

    if (!getIt.isRegistered<StorageService>()) {
      getIt.registerLazySingleton<StorageService>(
        () {
          try {
            final service = StorageServiceImpl(getIt<SharedPreferences>());
            debugPrint('DependencyInjection: StorageService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating StorageService: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register theme services with lazy loading
  void _registerThemeServices() {
    debugPrint('DependencyInjection: Registering theme services...');

    if (!getIt.isRegistered<ThemeNotifier>()) {
      getIt.registerLazySingleton<ThemeNotifier>(
        () {
          try {
            final notifier = ThemeNotifier(getIt<StorageService>());
            debugPrint('DependencyInjection: ThemeNotifier created lazily');
            return notifier;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating ThemeNotifier: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register permission services with lazy loading
  void _registerPermissionServices() {
    debugPrint('DependencyInjection: Registering permission services...');

    // Base permission service - Lazy initialization
    if (!getIt.isRegistered<PermissionService>()) {
      getIt.registerLazySingleton<PermissionService>(
        () {
          try {
            final service = PermissionServiceImpl(storage: getIt<StorageService>());
            debugPrint('DependencyInjection: PermissionService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating PermissionService: $e');
            rethrow;
          }
        },
      );
    }

    // Unified permission manager - Lazy initialization
    if (!getIt.isRegistered<UnifiedPermissionManager>()) {
      getIt.registerLazySingleton<UnifiedPermissionManager>(
        () {
          try {
            final manager = UnifiedPermissionManager.getInstance(
              permissionService: getIt<PermissionService>(),
              storage: getIt<StorageService>(),
            );
            debugPrint('DependencyInjection: UnifiedPermissionManager created lazily');
            return manager;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating UnifiedPermissionManager: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register device services with lazy loading
  void _registerDeviceServices() {
    debugPrint('DependencyInjection: Registering device services...');

    // Battery service - Lazy initialization
    if (!getIt.isRegistered<BatteryService>()) {
      getIt.registerLazySingleton<BatteryService>(
        () {
          try {
            final service = BatteryServiceImpl(battery: getIt<Battery>());
            debugPrint('DependencyInjection: BatteryService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating BatteryService: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register notification services with lazy loading
  void _registerNotificationServices() {
    debugPrint('DependencyInjection: Registering notification services...');

    // Notification service - Lazy initialization with async manager setup
    if (!getIt.isRegistered<NotificationService>()) {
      getIt.registerLazySingleton<NotificationService>(
        () {
          try {
            final service = NotificationServiceImpl(
              prefs: getIt<SharedPreferences>(),
              plugin: getIt<FlutterLocalNotificationsPlugin>(),
              battery: getIt<Battery>(),
            );

            // Initialize notification manager asynchronously when service is first accessed
            _initializeNotificationManagerAsync(service);
            
            debugPrint('DependencyInjection: NotificationService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating NotificationService: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register error handling services with lazy loading
  void _registerErrorHandler() {
    debugPrint('DependencyInjection: Registering error handler...');

    if (!getIt.isRegistered<AppErrorHandler>()) {
      getIt.registerLazySingleton<AppErrorHandler>(
        () {
          try {
            final handler = AppErrorHandler();
            debugPrint('DependencyInjection: AppErrorHandler created lazily');
            return handler;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating AppErrorHandler: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register feature services with lazy loading
  void _registerFeatureServices() {
    debugPrint('DependencyInjection: Registering feature services...');

    // Prayer Times Service - Lazy initialization (only when needed)
    if (!getIt.isRegistered<PrayerTimesService>()) {
      getIt.registerLazySingleton<PrayerTimesService>(
        () {
          try {
            final service = PrayerTimesService(
              storage: getIt<StorageService>(),
              permissionService: getIt<PermissionService>(),
            );
            debugPrint('DependencyInjection: PrayerTimesService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating PrayerTimesService: $e');
            rethrow;
          }
        },
      );
    }

    // Qibla Service - Factory pattern (new instance each time for compass)
    if (!getIt.isRegistered<QiblaService>()) {
      getIt.registerFactory<QiblaService>(
        () {
          try {
            final service = QiblaService(
              storage: getIt<StorageService>(),
              permissionService: getIt<PermissionService>(),
            );
            debugPrint('DependencyInjection: QiblaService created (factory)');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating QiblaService: $e');
            rethrow;
          }
        },
      );
    }

    // Athkar Service - Lazy initialization
    if (!getIt.isRegistered<AthkarService>()) {
      getIt.registerLazySingleton<AthkarService>(
        () {
          try {
            final service = AthkarService(storage: getIt<StorageService>());
            debugPrint('DependencyInjection: AthkarService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating AthkarService: $e');
            rethrow;
          }
        },
      );
    }

    // Dua Service - Lazy initialization
    if (!getIt.isRegistered<DuaService>()) {
      getIt.registerLazySingleton<DuaService>(
        () {
          try {
            final service = DuaService(storage: getIt<StorageService>());
            debugPrint('DependencyInjection: DuaService created lazily');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating DuaService: $e');
            rethrow;
          }
        },
      );
    }

    // Tasbih Service - Factory pattern (multiple counters)
    if (!getIt.isRegistered<TasbihService>()) {
      getIt.registerFactory<TasbihService>(
        () {
          try {
            final service = TasbihService(storage: getIt<StorageService>());
            debugPrint('DependencyInjection: TasbihService created (factory)');
            return service;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating TasbihService: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register settings services with lazy loading
  void _registerSettingsServices() {
    debugPrint('DependencyInjection: Registering settings services...');

    if (!getIt.isRegistered<SettingsServicesManager>()) {
      getIt.registerLazySingleton<SettingsServicesManager>(
        () {
          try {
            final manager = SettingsServicesManager(
              storage: getIt<StorageService>(),
              permissionService: getIt<PermissionService>(),
              themeNotifier: getIt<ThemeNotifier>(),
            );
            debugPrint('DependencyInjection: SettingsServicesManager created lazily');
            return manager;
          } catch (e) {
            debugPrint('DependencyInjection: Error creating SettingsServicesManager: $e');
            rethrow;
          }
        },
      );
    }
  }

  /// Register Firebase services with lazy loading (completely optional)
  Future<void> _registerFirebaseServices() async {
    debugPrint('DependencyInjection: Checking Firebase availability...');

    try {
      // Check Firebase availability
      await _checkFirebaseAvailability();

      if (_firebaseAvailable) {
        debugPrint('DependencyInjection: Firebase available - registering services...');

        // Firebase Remote Config Service - Lazy initialization
        if (!getIt.isRegistered<FirebaseRemoteConfigService>()) {
          getIt.registerLazySingleton<FirebaseRemoteConfigService>(
            () {
              try {
                final service = FirebaseRemoteConfigService();
                // Initialize asynchronously when first accessed
                _initializeFirebaseServiceAsync(service);
                debugPrint('DependencyInjection: FirebaseRemoteConfigService registered lazily');
                return service;
              } catch (e) {
                debugPrint('DependencyInjection: Error creating FirebaseRemoteConfigService: $e');
                rethrow;
              }
            },
          );
        }

        // Remote Config Manager - Lazy initialization
        if (!getIt.isRegistered<RemoteConfigManager>()) {
          getIt.registerLazySingleton<RemoteConfigManager>(
            () {
              try {
                final manager = RemoteConfigManager();
                // Initialize with dependencies when first accessed
                _initializeRemoteConfigManagerAsync(manager);
                debugPrint('DependencyInjection: RemoteConfigManager registered lazily');
                return manager;
              } catch (e) {
                debugPrint('DependencyInjection: Error creating RemoteConfigManager: $e');
                rethrow;
              }
            },
          );
        }

        // Firebase Messaging Service - Lazy initialization
        if (!getIt.isRegistered<FirebaseMessagingService>()) {
          getIt.registerLazySingleton<FirebaseMessagingService>(
            () {
              try {
                final service = FirebaseMessagingService();
                // Initialize with dependencies when first accessed
                _initializeFirebaseMessagingAsync(service);
                debugPrint('DependencyInjection: FirebaseMessagingService registered lazily');
                return service;
              } catch (e) {
                debugPrint('DependencyInjection: Error creating FirebaseMessagingService: $e');
                rethrow;
              }
            },
          );
        }

        debugPrint('DependencyInjection: Firebase services registered for lazy initialization ✅');
      } else {
        debugPrint('DependencyInjection: Firebase not available - app will run in local mode');
      }
    } catch (e) {
      debugPrint('DependencyInjection: Firebase registration failed: $e');
      _firebaseAvailable = false;
    }
  }

  /// Check Firebase availability
  Future<void> _checkFirebaseAvailability() async {
    try {
      // Simple Firebase availability check
      final dynamic firebaseApp = await _tryImportFirebase();
      _firebaseAvailable = firebaseApp != null;
      debugPrint('DependencyInjection: Firebase availability: $_firebaseAvailable');
    } catch (e) {
      debugPrint('DependencyInjection: Firebase not available: $e');
      _firebaseAvailable = false;
    }
  }

  /// Try to import Firebase (mock implementation)
  Future<dynamic> _tryImportFirebase() async {
    try {
      // Mock Firebase availability check
      return await Future.delayed(Duration(milliseconds: 50), () => 'firebase_mock');
    } catch (e) {
      return null;
    }
  }

  // ==================== Async Initialization Helpers ====================

  /// Initialize notification manager asynchronously
  void _initializeNotificationManagerAsync(NotificationService service) {
    Future.microtask(() async {
      try {
        await NotificationManager.initialize(service);
        debugPrint('DependencyInjection: NotificationManager initialized lazily');
      } catch (e) {
        debugPrint('DependencyInjection: Failed to initialize NotificationManager: $e');
      }
    });
  }

  /// Initialize Firebase Remote Config Service asynchronously
  void _initializeFirebaseServiceAsync(FirebaseRemoteConfigService service) {
    Future.microtask(() async {
      try {
        await service.initialize();
        debugPrint('DependencyInjection: FirebaseRemoteConfigService initialized lazily');
      } catch (e) {
        debugPrint('DependencyInjection: Failed to initialize FirebaseRemoteConfigService: $e');
      }
    });
  }

  /// Initialize Remote Config Manager asynchronously
  void _initializeRemoteConfigManagerAsync(RemoteConfigManager manager) {
    Future.microtask(() async {
      try {
        if (getIt.isRegistered<FirebaseRemoteConfigService>() && 
            getIt.isRegistered<StorageService>()) {
          await manager.initialize(
            remoteConfig: getIt<FirebaseRemoteConfigService>(),
            storage: getIt<StorageService>(),
          );
          debugPrint('DependencyInjection: RemoteConfigManager initialized lazily');
        }
      } catch (e) {
        debugPrint('DependencyInjection: Failed to initialize RemoteConfigManager: $e');
      }
    });
  }

  /// Initialize Firebase Messaging Service asynchronously
  void _initializeFirebaseMessagingAsync(FirebaseMessagingService service) {
    Future.microtask(() async {
      try {
        if (getIt.isRegistered<StorageService>() && 
            getIt.isRegistered<NotificationService>()) {
          await service.initialize(
            storage: getIt<StorageService>(),
            notificationService: getIt<NotificationService>(),
          );
          debugPrint('DependencyInjection: FirebaseMessagingService initialized lazily');
        }
      } catch (e) {
        debugPrint('DependencyInjection: Failed to initialize FirebaseMessagingService: $e');
      }
    });
  }

  /// Check if all required services are ready
  static bool areServicesReady() {
    final requiredServices = [
      // Core services
      getIt.isRegistered<StorageService>(),
      getIt.isRegistered<ThemeNotifier>(),
      
      // Permission services
      getIt.isRegistered<PermissionService>(),
      getIt.isRegistered<UnifiedPermissionManager>(),
      
      // Device services
      getIt.isRegistered<BatteryService>(),
      
      // Feature services
      getIt.isRegistered<PrayerTimesService>(),
      getIt.isRegistered<AthkarService>(),
      getIt.isRegistered<DuaService>(),
      getIt.isRegistered<TasbihService>(),
      getIt.isRegistered<SettingsServicesManager>(),
    ];
    
    final allReady = requiredServices.every((service) => service);
    
    if (!allReady) {
      debugPrint('DependencyInjection: Some services are not ready');
    }
    
    return allReady;
  }

  /// Reset all services
  static Future<void> reset() async {
    debugPrint('DependencyInjection: Resetting all services...');
    
    try {
      await getIt.reset();
      _instance._isInitialized = false;
      _instance._firebaseAvailable = false;
      debugPrint('DependencyInjection: All services reset');
    } catch (e) {
      debugPrint('DependencyInjection: Error resetting: $e');
    }
  }
}

// ==================== Helper Functions ====================

/// Get service with type safety and error handling
T getService<T extends Object>() {
  if (!getIt.isRegistered<T>()) {
    throw Exception('Service $T is not registered. Make sure to call DependencyInjection.initialize() first.');
  }
  return getIt<T>();
}

/// Safe service access (returns null if not available)
T? getServiceSafe<T extends Object>() {
  try {
    return getIt.isRegistered<T>() ? getIt<T>() : null;
  } catch (e) {
    debugPrint('Error getting service $T: $e');
    return null;
  }
}