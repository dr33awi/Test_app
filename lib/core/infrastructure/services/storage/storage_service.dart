// lib/core/infrastructure/services/storage/storage_service.dart

abstract class StorageService {
  // String operations
  Future<bool> setString(String key, String value);
  String? getString(String key);
  
  // Int operations  
  Future<bool> setInt(String key, int value);
  int? getInt(String key);
  
  // Double operations
  Future<bool> setDouble(String key, double value);
  double? getDouble(String key);
  
  // Bool operations
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);
  
  // List operations
  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key);
  
  // NEW: Generic List operations for complex data
  Future<bool> setList(String key, List<dynamic> value);
  List<dynamic>? getList(String key);
  
  // Map operations
  Future<bool> setMap(String key, Map<String, dynamic> value);
  Map<String, dynamic>? getMap(String key);
  
  // Remove operation
  Future<bool> remove(String key);
  
  // Clear all
  Future<bool> clear();
  
  // Check if key exists
  bool containsKey(String key);
  
  // Get all keys
  Set<String> getKeys();
}

