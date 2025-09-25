// lib/core/services/service_extensions.dart

import 'package:flutter/material.dart';
import '../dependency_injection.dart';

// Core services
import '../infrastructure/services/storage/storage_service.dart';
import '../infrastructure/services/notifications/notification_service.dart';
import '../infrastructure/services/permissions/permission_service.dart';
import '../infrastructure/services/permissions/permission_manager.dart';
import '../infrastructure/services/device/battery/battery_service.dart';
import '../error/error_handler.dart';

// Theme services
import '../../app/themes/core/theme_notifier.dart';

// Feature services
import '../../features/prayer_times/services/prayer_times_service.dart';
import '../../features/qibla/services/qibla_service.dart';
import '../../features/athkar/services/athkar_service.dart';
import '../../features/dua/services/dua_service.dart';
import '../../features/tasbih/services/tasbih_service.dart';
import '../../features/settings/services/settings_services_manager.dart';

// Firebase services
import '../infrastructure/firebase/firebase_messaging_service.dart';
import '../infrastructure/firebase/remote_config_service.dart';
import '../infrastructure/firebase/remote_config_manager.dart';

// Permission types
import '../infrastructure/services/permissions/models/permission_models.dart';

/// Extension methods for easy service access from BuildContext
extension ServiceExtensions on BuildContext {
  /// Get service with type safety
  T getService<T extends Object>() => getIt<T>();
  
  /// Check if service is registered
  bool hasService<T extends Object>() => getIt.isRegistered<T>();
  
  // ==================== Core Services ====================
  
  /// Get storage service
  StorageService get storageService => getIt<StorageService>();
  
  /// Get notification service  
  NotificationService get notificationService => getIt<NotificationService>();
  
  /// Get permission service
  PermissionService get permissionService => getIt<PermissionService>();
  
  /// Get unified permission manager
  UnifiedPermissionManager get permissionManager => getIt<UnifiedPermissionManager>();
  
  /// Get error handler
  AppErrorHandler get errorHandler => getIt<AppErrorHandler>();
  
  /// Get battery service
  BatteryService get batteryService => getIt<BatteryService>();
  
  // ==================== Theme Services ====================
  
  /// Get theme notifier
  ThemeNotifier get themeNotifier => getIt<ThemeNotifier>();
  
  // ==================== Feature Services ====================
  
  /// Get prayer times service (lazy loaded)
  PrayerTimesService get prayerTimesService => getIt<PrayerTimesService>();
  
  /// Get athkar service (lazy loaded)
  AthkarService get athkarService => getIt<AthkarService>();
  
  /// Get dua service (lazy loaded)
  DuaService get duaService => getIt<DuaService>();
  
  /// Get tasbih service (factory - new instance each time)
  TasbihService get tasbihService => getIt<TasbihService>();
  
  /// Get qibla service (factory - new instance each time)
  QiblaService get qiblaService => getIt<QiblaService>();
  
  /// Get settings manager (lazy loaded)
  SettingsServicesManager get settingsManager => getIt<SettingsServicesManager>();
  
  // ==================== Firebase Services (Safe Access) ====================
  
  /// Get Firebase Remote Config Service (returns null if not available)
  FirebaseRemoteConfigService? get firebaseRemoteConfig {
    try {
      return DependencyInjection.isFirebaseAvailable && getIt.isRegistered<FirebaseRemoteConfigService>() 
          ? getIt<FirebaseRemoteConfigService>() 
          : null;
    } catch (e) {
      debugPrint('Error accessing Firebase Remote Config: $e');
      return null;
    }
  }
  
  /// Get Remote Config Manager (returns null if not available)
  RemoteConfigManager? get remoteConfigManager {
    try {
      return DependencyInjection.isFirebaseAvailable && getIt.isRegistered<RemoteConfigManager>() 
          ? getIt<RemoteConfigManager>() 
          : null;
    } catch (e) {
      debugPrint('Error accessing Remote Config Manager: $e');
      return null;
    }
  }
  
  /// Get Firebase Messaging Service (returns null if not available)
  FirebaseMessagingService? get firebaseMessaging {
    try {
      return DependencyInjection.isFirebaseAvailable && getIt.isRegistered<FirebaseMessagingService>() 
          ? getIt<FirebaseMessagingService>() 
          : null;
    } catch (e) {
      debugPrint('Error accessing Firebase Messaging: $e');
      return null;
    }
  }
  
  // ==================== Helper Methods ====================
  
  /// Check if feature is enabled via Remote Config
  bool isFeatureEnabled(String featureName) {
    final manager = remoteConfigManager;
    if (manager == null) return true; // Default enabled if no remote config
    
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
  
  /// Request permission with explanation (using unified manager)
  Future<bool> requestPermission(
    AppPermissionType permission, {
    String? customMessage,
    bool forceRequest = false,
  }) async {
    try {
      return await permissionManager.requestPermissionWithExplanation(
        this,
        permission,
        customMessage: customMessage,
        forceRequest: forceRequest,
      );
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }
  
  /// Quick permission check
  Future<bool> hasPermission(AppPermissionType permission) async {
    try {
      final status = await permissionService.checkPermissionStatus(permission);
      return status == AppPermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }
}

/// Additional helper methods for service access
class ServiceHelper {
  /// Get service safely with error handling
  static T? getServiceSafe<T extends Object>() {
    try {
      return getIt.isRegistered<T>() ? getIt<T>() : null;
    } catch (e) {
      debugPrint('Error getting service $T: $e');
      return null;
    }
  }
  
  /// Check if Firebase services are available
  static bool get isFirebaseAvailable => DependencyInjection.isFirebaseAvailable;
  
  /// Check if all services are initialized
  static bool get areServicesReady => DependencyInjection.areServicesReady();
}