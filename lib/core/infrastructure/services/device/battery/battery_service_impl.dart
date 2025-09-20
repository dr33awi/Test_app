// lib/core/infrastructure/services/device/battery/battery_service_impl.dart (مبسط)

import 'dart:async';
import 'package:battery_plus/battery_plus.dart' as battery_plus;
import '../../logging/logger_service.dart';
import 'battery_service.dart';

/// Implementation of battery service (مبسط)
class BatteryServiceImpl implements BatteryService {
  final battery_plus.Battery _battery;
  final LoggerService? _logger;
  
  // حد أدنى افتراضي للبطارية
  static const int _defaultMinBatteryLevel = 15;
  
  BatteryServiceImpl({
    battery_plus.Battery? battery,
    LoggerService? logger,
  })  : _battery = battery ?? battery_plus.Battery(),
        _logger = logger {
    _logger?.debug(message: '[BatteryService] Initializing (simplified)...');
  }
  
  @override
  Future<int> getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      _logger?.debug(
        message: '[BatteryService] Battery level retrieved',
        data: {'level': level},
      );
      return level;
    } catch (e) {
      _logger?.error(
        message: '[BatteryService] Error getting battery level',
        error: e,
      );
      return 100; // Assume full battery on error
    }
  }
  
  @override
  Future<bool> isCharging() async {
    try {
      final state = await _battery.batteryState;
      final isCharging = state == battery_plus.BatteryState.charging || 
                        state == battery_plus.BatteryState.full;
      
      _logger?.debug(
        message: '[BatteryService] Charging status retrieved',
        data: {'isCharging': isCharging, 'state': state.toString()},
      );
      
      return isCharging;
    } catch (e) {
      _logger?.error(
        message: '[BatteryService] Error checking charging status',
        error: e,
      );
      return false;
    }
  }
  
  @override
  Future<bool> isPowerSaveMode() async {
    try {
      final isInSaveMode = await _battery.isInBatterySaveMode;
      _logger?.debug(
        message: '[BatteryService] Power save mode status retrieved',
        data: {'isPowerSaveMode': isInSaveMode},
      );
      return isInSaveMode;
    } catch (e) {
      _logger?.error(
        message: '[BatteryService] Error checking power save mode',
        error: e,
      );
      return false;
    }
  }
  
  @override
  Future<bool> canSendNotification() async {
    try {
      final batteryLevel = await getBatteryLevel();
      final charging = await isCharging();
      final powerSaveMode = await isPowerSaveMode();
      
      // يمكن الإرسال إذا:
      // 1. الجهاز يشحن، أو
      // 2. البطارية أعلى من الحد الأدنى وليس في وضع توفير الطاقة، أو
      // 3. البطارية أعلى من المستوى الحرج (5%)
      final canSend = charging || 
                     (batteryLevel >= _defaultMinBatteryLevel && !powerSaveMode) ||
                     batteryLevel >= 5;
      
      _logger?.debug(
        message: '[BatteryService] Notification permission check',
        data: {
          'canSend': canSend,
          'batteryLevel': batteryLevel,
          'isCharging': charging,
          'isPowerSaveMode': powerSaveMode,
        },
      );
      
      if (!canSend) {
        _logger?.logEvent('notification_blocked_battery', parameters: {
          'battery_level': batteryLevel,
          'power_save_mode': powerSaveMode,
        });
      }
      
      return canSend;
    } catch (e) {
      _logger?.error(
        message: '[BatteryService] Error checking notification permission',
        error: e,
      );
      return true; // Allow notifications on error
    }
  }
  
  @override
  Future<BatteryState> getCurrentBatteryState() async {
    final level = await getBatteryLevel();
    final charging = await isCharging();
    final powerSaveMode = await isPowerSaveMode();
    
    return BatteryState(
      level: level,
      isCharging: charging,
      isPowerSaveMode: powerSaveMode,
    );
  }
  
  @override
  Future<void> dispose() async {
    _logger?.debug(message: '[BatteryService] Disposed (simplified)');
  }
}