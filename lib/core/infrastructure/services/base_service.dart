// lib/core/infrastructure/services/base_service.dart
import 'package:flutter/foundation.dart';
import 'logging/logger_service.dart';
import 'storage/storage_service.dart';

/// فئة أساسية لجميع الخدمات في التطبيق
/// تحتوي على الوظائف المشتركة وتقلل من التكرار
abstract class BaseService {
  final LoggerService logger;
  final StorageService storage;
  
  /// اسم الخدمة لأغراض السجلات
  String get serviceName;
  
  /// مفتاح فريد للخدمة للتخزين
  String get serviceKey => '${serviceName.toLowerCase()}_service';
  
  BaseService({
    required this.logger,
    required this.storage,
  }) {
    _initialize();
  }
  
  /// تهيئة الخدمة (يُستدعى تلقائياً)
  void _initialize() {
    logger.debug(message: '[$serviceName] Service initializing...');
    onInitialize();
    logger.debug(message: '[$serviceName] Service initialized successfully');
  }
  
  /// دالة تهيئة مخصصة للخدمة (اختيارية)
  @protected
  void onInitialize() {}
  
  /// دالة تنظيف الموارد (اختيارية)
  @protected
  void onDispose() {}
  
  /// تنظيف الموارد
  void dispose() {
    logger.debug(message: '[$serviceName] Service disposing...');
    onDispose();
    logger.debug(message: '[$serviceName] Service disposed');
  }
  
  // ==================== دوال مساعدة للتخزين ====================
  
  /// حفظ قيمة نصية
  Future<bool> saveString(String key, String value) async {
    try {
      final result = await storage.setString('${serviceKey}_$key', value);
      if (result) {
        logger.debug(message: '[$serviceName] String saved: $key');
      } else {
        logger.warning(message: '[$serviceName] Failed to save string: $key');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error saving string: $key', error: e);
      return false;
    }
  }
  
  /// استرجاع قيمة نصية
  String? getString(String key, [String? defaultValue]) {
    try {
      return storage.getString('${serviceKey}_$key') ?? defaultValue;
    } catch (e) {
      logger.error(message: '[$serviceName] Error getting string: $key', error: e);
      return defaultValue;
    }
  }
  
  /// حفظ قيمة رقمية صحيحة
  Future<bool> saveInt(String key, int value) async {
    try {
      final result = await storage.setInt('${serviceKey}_$key', value);
      if (result) {
        logger.debug(message: '[$serviceName] Int saved: $key = $value');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error saving int: $key', error: e);
      return false;
    }
  }
  
  /// استرجاع قيمة رقمية صحيحة
  int? getInt(String key, [int? defaultValue]) {
    try {
      return storage.getInt('${serviceKey}_$key') ?? defaultValue;
    } catch (e) {
      logger.error(message: '[$serviceName] Error getting int: $key', error: e);
      return defaultValue;
    }
  }
  
  /// حفظ قيمة منطقية
  Future<bool> saveBool(String key, bool value) async {
    try {
      final result = await storage.setBool('${serviceKey}_$key', value);
      if (result) {
        logger.debug(message: '[$serviceName] Bool saved: $key = $value');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error saving bool: $key', error: e);
      return false;
    }
  }
  
  /// استرجاع قيمة منطقية
  bool? getBool(String key, [bool? defaultValue]) {
    try {
      return storage.getBool('${serviceKey}_$key') ?? defaultValue;
    } catch (e) {
      logger.error(message: '[$serviceName] Error getting bool: $key', error: e);
      return defaultValue;
    }
  }
  
  /// حفظ قائمة نصية
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final result = await storage.setStringList('${serviceKey}_$key', value);
      if (result) {
        logger.debug(message: '[$serviceName] StringList saved: $key (${value.length} items)');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error saving string list: $key', error: e);
      return false;
    }
  }
  
  /// استرجاع قائمة نصية
  List<String>? getStringList(String key, [List<String>? defaultValue]) {
    try {
      return storage.getStringList('${serviceKey}_$key') ?? defaultValue;
    } catch (e) {
      logger.error(message: '[$serviceName] Error getting string list: $key', error: e);
      return defaultValue;
    }
  }
  
  /// حفظ خريطة البيانات
  Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    try {
      final result = await storage.setMap('${serviceKey}_$key', value);
      if (result) {
        logger.debug(message: '[$serviceName] Map saved: $key');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error saving map: $key', error: e);
      return false;
    }
  }
  
  /// استرجاع خريطة البيانات
  Map<String, dynamic>? getMap(String key, [Map<String, dynamic>? defaultValue]) {
    try {
      return storage.getMap('${serviceKey}_$key') ?? defaultValue;
    } catch (e) {
      logger.error(message: '[$serviceName] Error getting map: $key', error: e);
      return defaultValue;
    }
  }
  
  /// حذف مفتاح
  Future<bool> removeKey(String key) async {
    try {
      final result = await storage.remove('${serviceKey}_$key');
      if (result) {
        logger.debug(message: '[$serviceName] Key removed: $key');
      }
      return result;
    } catch (e) {
      logger.error(message: '[$serviceName] Error removing key: $key', error: e);
      return false;
    }
  }
  
  /// تنظيف جميع بيانات الخدمة
  Future<bool> clearAllData() async {
    try {
      // الحصول على جميع المفاتيح المتعلقة بهذه الخدمة
      final allKeys = storage.getKeys();
      final serviceKeys = allKeys.where((key) => key.startsWith('${serviceKey}_')).toList();
      
      bool allSuccess = true;
      for (final key in serviceKeys) {
        final result = await storage.remove(key);
        if (!result) allSuccess = false;
      }
      
      if (allSuccess) {
        logger.info(message: '[$serviceName] All service data cleared (${serviceKeys.length} keys)');
      } else {
        logger.warning(message: '[$serviceName] Some data could not be cleared');
      }
      
      return allSuccess;
    } catch (e) {
      logger.error(message: '[$serviceName] Error clearing all data', error: e);
      return false;
    }
  }
  
  // ==================== دوال مساعدة للسجلات ====================
  
  /// سجل معلومات
  void logInfo(String message, [dynamic data]) {
    logger.info(message: '[$serviceName] $message', data: data);
  }
  
  /// سجل تحذير
  void logWarning(String message, [dynamic data]) {
    logger.warning(message: '[$serviceName] $message', data: data);
  }
  
  /// سجل خطأ
  void logError(String message, [dynamic error]) {
    logger.error(message: '[$serviceName] $message', error: error);
  }
  
  /// سجل تصحيح
  void logDebug(String message, [dynamic data]) {
    logger.debug(message: '[$serviceName] $message', data: data);
  }
}

/// فئة أساسية للخدمات التي تحتاج إلى إشعارات التغيير
abstract class BaseNotifierService extends BaseService with ChangeNotifier {
  BaseNotifierService({
    required super.logger,
    required super.storage,
  });
  
  @override
  void onDispose() {
    super.onDispose();
    super.dispose(); // ChangeNotifier dispose
  }
}