// lib/core/infrastructure/services/storage/storage_service_impl.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/logger_service.dart';
import 'storage_service.dart';

class StorageServiceImpl implements StorageService {
  final SharedPreferences _prefs;
  final LoggerService? logger;

  StorageServiceImpl(this._prefs, {this.logger});

  // ==================== String Operations ====================
  
  @override
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      logger?.debug(message: '[Storage] Set string', data: {'key': key});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set string', error: e);
      return false;
    }
  }

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get string', error: e);
      return null;
    }
  }

  // ==================== Int Operations ====================
  
  @override
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      logger?.debug(message: '[Storage] Set int', data: {'key': key, 'value': value});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set int', error: e);
      return false;
    }
  }

  @override
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get int', error: e);
      return null;
    }
  }

  // ==================== Double Operations ====================
  
  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _prefs.setDouble(key, value);
      logger?.debug(message: '[Storage] Set double', data: {'key': key, 'value': value});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set double', error: e);
      return false;
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get double', error: e);
      return null;
    }
  }

  // ==================== Bool Operations ====================
  
  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      logger?.debug(message: '[Storage] Set bool', data: {'key': key, 'value': value});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set bool', error: e);
      return false;
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get bool', error: e);
      return null;
    }
  }

  // ==================== List Operations ====================
  
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      logger?.debug(message: '[Storage] Set string list', data: {'key': key, 'count': value.length});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set string list', error: e);
      return false;
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get string list', error: e);
      return null;
    }
  }

  // ==================== NEW: Generic List Operations ====================
  
  @override
  Future<bool> setList(String key, List<dynamic> value) async {
    try {
      // Convert list to JSON string for storage
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      logger?.debug(message: '[Storage] Set list', data: {'key': key, 'count': value.length});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set list', error: e);
      return false;
    }
  }

  @override
  List<dynamic>? getList(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded;
      }
      return null;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get list', error: e);
      return null;
    }
  }

  // ==================== Map Operations ====================
  
  @override
  Future<bool> setMap(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      logger?.debug(message: '[Storage] Set map', data: {'key': key});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to set map', error: e);
      return false;
    }
  }

  @override
  Map<String, dynamic>? getMap(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get map', error: e);
      return null;
    }
  }

  // ==================== Utility Operations ====================
  
  @override
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      logger?.debug(message: '[Storage] Removed key', data: {'key': key});
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to remove key', error: e);
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      logger?.warning(message: '[Storage] Cleared all data');
      return result;
    } catch (e) {
      logger?.error(message: '[Storage] Failed to clear', error: e);
      return false;
    }
  }

  @override
  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      logger?.error(message: '[Storage] Failed to check key', error: e);
      return false;
    }
  }

  @override
  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      logger?.error(message: '[Storage] Failed to get keys', error: e);
      return {};
    }
  }
}