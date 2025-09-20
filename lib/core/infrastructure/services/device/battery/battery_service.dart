// lib/core/infrastructure/services/device/battery/battery_service.dart (منظف)

/// Battery state information (مبسط)
class BatteryState {
  final int level;
  final bool isCharging;
  final bool isPowerSaveMode;
  
  BatteryState({
    required this.level,
    required this.isCharging,
    required this.isPowerSaveMode,
  });
  
  Map<String, dynamic> toJson() => {
    'level': level,
    'isCharging': isCharging,
    'isPowerSaveMode': isPowerSaveMode,
  };
}

/// Battery service interface (مبسط - فقط الأساسيات المستخدمة)
abstract class BatteryService {
  /// Get current battery level (0-100)
  Future<int> getBatteryLevel();
  
  /// Check if device is charging
  Future<bool> isCharging();
  
  /// Check if power save mode is enabled
  Future<bool> isPowerSaveMode();
  
  /// Check if notifications can be sent based on battery state
  /// (الوظيفة الوحيدة المستخدمة فعلياً)
  Future<bool> canSendNotification();
  
  /// Get current battery state
  Future<BatteryState> getCurrentBatteryState();
  
  /// Dispose resources
  Future<void> dispose();
}