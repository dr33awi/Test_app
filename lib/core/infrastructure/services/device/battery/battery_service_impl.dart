// lib/core/infrastructure/services/device/battery/battery_service_impl.dart 

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart' as battery_plus;
import 'battery_service.dart';

/// Implementation of battery service 
class BatteryServiceImpl implements BatteryService {
  final battery_plus.Battery _battery;
  
  // حد أدنى افتراضي للبطارية
  static const int _defaultMinBatteryLevel = 15;
  
  BatteryServiceImpl({
    battery_plus.Battery? battery,
  }) : _battery = battery ?? battery_plus.Battery() {
    _log('Initializing (simplified)...');
  }
  
  @override
  Future<int> getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      _log('Battery level retrieved', {'level': level});
      return level;
    } catch (e) {
      _logError('Error getting battery level', e);
      return 100; // Assume full battery on error
    }
  }
  
  @override
  Future<bool> isCharging() async {
    try {
      final state = await _battery.batteryState;
      final isCharging = state == battery_plus.BatteryState.charging || 
                        state == battery_plus.BatteryState.full;
      
      _log('Charging status retrieved', {'isCharging': isCharging, 'state': state.toString()});
      
      return isCharging;
    } catch (e) {
      _logError('Error checking charging status', e);
      return false;
    }
  }
  
  @override
  Future<bool> isPowerSaveMode() async {
    try {
      final isInSaveMode = await _battery.isInBatterySaveMode;
      _log('Power save mode status retrieved', {'isPowerSaveMode': isInSaveMode});
      return isInSaveMode;
    } catch (e) {
      _logError('Error checking power save mode', e);
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
      
      _log('Notification permission check', {
        'canSend': canSend,
        'batteryLevel': batteryLevel,
        'isCharging': charging,
        'isPowerSaveMode': powerSaveMode,
      });
      
      if (!canSend) {
        _log('Notification blocked - battery', {'battery_level': batteryLevel, 'power_save_mode': powerSaveMode});
      }
      
      return canSend;
    } catch (e) {
      _logError('Error checking notification permission', e);
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
    _log('Disposed (simplified)');
  }

  // ==================== Simple Logging Methods ====================

  void _log(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      debugPrint('🔋 [BatteryService] $message${data != null ? " - $data" : ""}');
    }
  }

  void _logError(String message, dynamic error) {
    if (kDebugMode) {
      debugPrint('🔴 [BatteryService] ERROR: $message - $error');
    }
  }
}