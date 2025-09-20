// lib/core/infrastructure/services/permissions/handlers/permission_handler_factory.dart (مصحح)

import '../permission_service.dart';
import 'permission_handler_base.dart';
import 'location_handler.dart';
import 'notification_handler.dart';
import 'battery_handler.dart';

/// Factory للحصول على handler المناسب لكل إذن (مبسط)
class PermissionHandlerFactory {
  // فقط Handlers المستخدمة فعلياً
  static final Map<AppPermissionType, PermissionHandlerBase> _handlers = {
    AppPermissionType.location: LocationPermissionHandler(),
    AppPermissionType.notification: NotificationPermissionHandler(),
    AppPermissionType.batteryOptimization: BatteryOptimizationHandler(),
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