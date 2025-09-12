// lib/core/infrastructure/services/permissions/handlers/permission_handler_factory.dart

import '../permission_service.dart';
import 'permission_handler_base.dart';
import 'location_handler.dart';
import 'notification_handler.dart';
import 'battery_handler.dart';
import 'storage_handler.dart';
import 'do_not_disturb_handler.dart';

/// Factory للحصول على handler المناسب لكل إذن
class PermissionHandlerFactory {
  // جميع Handlers (بما في ذلك القديمة للتوافق)
  static final Map<AppPermissionType, PermissionHandlerBase> _handlers = {
    AppPermissionType.location: LocationPermissionHandler(),
    AppPermissionType.notification: NotificationPermissionHandler(),
    AppPermissionType.batteryOptimization: BatteryOptimizationHandler(),
    // للتوافق مع الكود القديم
    AppPermissionType.storage: StoragePermissionHandler(),
    AppPermissionType.doNotDisturb: DoNotDisturbHandler(),
  };
  
  /// الحصول على handler لإذن محدد
  static PermissionHandlerBase? getHandler(AppPermissionType type) {
    return _handlers[type];
  }
  
  /// الحصول على جميع handlers
  static List<PermissionHandlerBase> getAllHandlers() {
    return _handlers.values.toList();
  }
}