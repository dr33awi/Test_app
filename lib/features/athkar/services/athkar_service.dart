// lib/features/athkar/services/athkar_service.dart - مُنظف
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../../app/themes/constants/app_constants.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/notifications/notification_manager.dart';
import '../../../core/infrastructure/services/notifications/models/notification_models.dart';
import '../models/athkar_model.dart';
import '../models/athkar_progress.dart';
import '../constants/athkar_constants.dart';

/// خدمة إدارة الأذكار
class AthkarService {
  final LoggerService _logger;
  final StorageService _storage;

  // كاش البيانات
  List<AthkarCategory>? _categoriesCache;
  final Map<String, AthkarProgress> _progressCache = {};
  final Map<String, TimeOfDay> _customTimesCache = {};
  DateTime? _lastSyncTime;

  AthkarService({
    required LoggerService logger,
    required StorageService storage,
  })  : _logger = logger,
        _storage = storage {
    _initialize();
  }

  /// تهيئة الخدمة
  void _initialize() {
    _logger.debug(message: '[AthkarService] Initializing service');
    _loadCachedData();
  }

  /// تحميل البيانات المخزنة مؤقتاً
  void _loadCachedData() {
    try {
      final syncTimeStr = _storage.getString(AthkarConstants.lastSyncKey);
      if (syncTimeStr != null) {
        _lastSyncTime = DateTime.tryParse(syncTimeStr);
      }

      final customTimes = _storage.getMap(AthkarConstants.customTimesKey);
      if (customTimes != null) {
        customTimes.forEach((categoryId, timeString) {
          final time = AthkarConstants.parseTimeOfDay(timeString);
          if (time != null) {
            _customTimesCache[categoryId] = time;
          }
        });
      }
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] Error loading cached data',
        data: {'error': e.toString()},
      );
    }
  }

  // ==================== إدارة الفئات ====================

  /// تحميل جميع فئات الأذكار
  Future<List<AthkarCategory>> loadCategories() async {
    try {
      if (_categoriesCache != null) {
        _logger.debug(message: '[AthkarService] Returning categories from cache');
        return _categoriesCache!;
      }

      final cachedData = _storage.getMap(AthkarConstants.categoriesKey);
      if (cachedData != null && _isCacheValid(cachedData)) {
        _logger.debug(message: '[AthkarService] Loading categories from storage');
        _categoriesCache = _parseCategoriesFromJson(cachedData);
        return _categoriesCache!;
      }

      _logger.info(message: '[AthkarService] Loading categories from assets');
      final jsonStr = await rootBundle.loadString(AppConstants.athkarDataFile);
      final Map<String, dynamic> data = json.decode(jsonStr);
      
      data['cached_at'] = DateTime.now().toIso8601String();
      data['version'] = AthkarConstants.currentSettingsVersion;
      await _storage.setMap(AthkarConstants.categoriesKey, data);
      
      _categoriesCache = _parseCategoriesFromJson(data);
      
      _logger.info(
        message: '[AthkarService] Categories loaded successfully',
        data: {'count': _categoriesCache!.length},
      );
      
      return _categoriesCache!;
    } catch (e, stackTrace) {
      _logger.error(
        message: '[AthkarService] Failed to load categories',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load athkar data: $e');
    }
  }

  /// تحليل الفئات من JSON
  List<AthkarCategory> _parseCategoriesFromJson(Map<String, dynamic> data) {
    final List<dynamic> list = data['categories'] ?? [];
    return list
        .map((e) => AthkarCategory.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => AthkarCategoryPriority.compare(a.id, b.id));
  }

  /// التحقق من صلاحية الكاش
  bool _isCacheValid(Map<String, dynamic> cachedData) {
    try {
      final cachedAtStr = cachedData['cached_at'] as String?;
      final version = cachedData['version'] as int?;
      
      if (cachedAtStr == null || version == null) return false;
      if (version < AthkarConstants.minimumSupportedVersion) return false;
      
      final cachedAt = DateTime.parse(cachedAtStr);
      return AthkarConstants.isCacheValid(cachedAt);
    } catch (e) {
      _logger.warning(message: '[AthkarService] Invalid cache data');
      return false;
    }
  }

  /// الحصول على فئة بمعرفها
  Future<AthkarCategory?> getCategoryById(String id) async {
    try {
      final categories = await loadCategories();
      return categories.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Category not found: $id'),
      );
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] Category not found',
        data: {'categoryId': id, 'error': e.toString()},
      );
      return null;
    }
  }

  /// مسح الكاش وإعادة التحميل
  Future<void> refreshCategories() async {
    _logger.info(message: '[AthkarService] Refreshing categories');
    _categoriesCache = null;
    await _storage.remove(AthkarConstants.categoriesKey);
    await loadCategories();
  }

  // ==================== إدارة حجم الخط ====================

  /// حفظ حجم الخط المفضل
  Future<void> saveFontSize(double fontSize) async {
    try {
      final clampedSize = fontSize.clamp(
        AthkarConstants.minFontSize,
        AthkarConstants.maxFontSize,
      );
      
      await _storage.setDouble(AthkarConstants.fontSizeKey, clampedSize);
      
      _logger.info(
        message: '[AthkarService] Font size saved',
        data: {'fontSize': clampedSize},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Error saving font size',
        error: e,
      );
    }
  }

  /// الحصول على حجم الخط المحفوظ
  Future<double> getSavedFontSize() async {
    try {
      return _storage.getDouble(AthkarConstants.fontSizeKey) ?? 
             AthkarConstants.defaultFontSize;
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Error getting saved font size',
        error: e,
      );
      return AthkarConstants.defaultFontSize;
    }
  }

  // ==================== إدارة التذكيرات ====================

  /// الحصول على الفئات المفعلة للتذكير
  List<String> getEnabledReminderCategories() {
    return _storage.getStringList(AthkarConstants.reminderKey) ?? [];
  }

  /// تعيين الفئات المفعلة للتذكير
  Future<void> setEnabledReminderCategories(List<String> enabledIds) async {
    try {
      await _storage.setStringList(AthkarConstants.reminderKey, enabledIds);
      await _updateLastSyncTime();
      
      _logger.info(
        message: '[AthkarService] Enabled categories updated',
        data: {'enabledIds': enabledIds, 'count': enabledIds.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to update enabled categories',
        error: e,
      );
      rethrow;
    }
  }

  /// حفظ الأوقات المخصصة
  Future<void> saveCustomTimes(Map<String, TimeOfDay> customTimes) async {
    try {
      final timesMap = <String, String>{};
      
      customTimes.forEach((categoryId, time) {
        timesMap[categoryId] = AthkarConstants.timeOfDayToString(time);
      });
      
      await _storage.setMap(AthkarConstants.customTimesKey, timesMap);
      
      _customTimesCache.clear();
      _customTimesCache.addAll(customTimes);
      
      _logger.debug(
        message: '[AthkarService] Custom times saved',
        data: {'count': customTimes.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to save custom times',
        error: e,
      );
      rethrow;
    }
  }

  /// الحصول على الأوقات المخصصة
  Map<String, TimeOfDay> getCustomTimes() {
    return Map.from(_customTimesCache);
  }

  /// الحصول على الوقت المخصص لفئة معينة
  TimeOfDay? getCustomTimeForCategory(String categoryId) {
    return _customTimesCache[categoryId];
  }

  /// جدولة تذكيرات الأذكار
  Future<void> scheduleCategoryReminders() async {
    try {
      final categories = await loadCategories();
      final enabledIds = getEnabledReminderCategories();
      
      if (enabledIds.isEmpty) {
        _logger.info(message: '[AthkarService] No categories enabled for reminders');
        return;
      }

      final notificationManager = NotificationManager.instance;
      int scheduledCount = 0;

      await notificationManager.cancelAllAthkarReminders();

      for (final category in categories) {
        if (!enabledIds.contains(category.id)) continue;
        
        final time = _customTimesCache[category.id] ?? 
                    category.notifyTime ?? 
                    AthkarConstants.getDefaultTimeForCategory(category.id);
        
        await notificationManager.scheduleAthkarReminder(
          categoryId: category.id,
          categoryName: category.title,
          time: time,
          repeat: NotificationRepeat.daily,
        );
        
        scheduledCount++;
        
        _logger.debug(
          message: '[AthkarService] Reminder scheduled',
          data: {
            'categoryId': category.id,
            'time': AthkarConstants.timeOfDayToString(time),
          },
        );
      }
      
      _logger.info(
        message: '[AthkarService] All reminders scheduled',
        data: {
          'scheduledCount': scheduledCount,
          'totalEnabled': enabledIds.length,
        },
      );
      
      await _updateLastSyncTime();
      
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to schedule reminders',
        error: e,
      );
      rethrow;
    }
  }

  /// تحديث إعدادات التذكير
  Future<void> updateReminderSettings({
    required Map<String, bool> enabledMap,
    Map<String, TimeOfDay>? customTimes,
  }) async {
    try {
      final enabledIds = enabledMap.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      
      await setEnabledReminderCategories(enabledIds);
      
      if (customTimes != null) {
        await saveCustomTimes(customTimes);
      }

      await scheduleCategoryReminders();

      _logger.info(
        message: '[AthkarService] Reminder settings updated successfully',
        data: {'enabledCount': enabledIds.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to update reminder settings',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== دوال مساعدة خاصة ====================

  /// تحديث آخر وقت مزامنة
  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    await _storage.setString(
      AthkarConstants.lastSyncKey,
      _lastSyncTime!.toIso8601String(),
    );
  }

  /// الحصول على آخر وقت مزامنة
  DateTime? getLastSyncTime() {
    return _lastSyncTime;
  }

  // ==================== التنظيف ====================

  /// تنظيف الموارد
  void dispose() {
    _logger.debug(message: '[AthkarService] Disposing service');
    _progressCache.clear();
    _customTimesCache.clear();
    _categoriesCache = null;
    _lastSyncTime = null;
  }

  /// مسح جميع البيانات
  Future<void> clearAllData() async {
    try {
      _logger.warning(message: '[AthkarService] Clearing all data');
      
      await _storage.remove(AthkarConstants.categoriesKey);
      await _storage.remove(AthkarConstants.reminderKey);
      await _storage.remove(AthkarConstants.customTimesKey);
      await _storage.remove(AthkarConstants.fontSizeKey);
      await _storage.remove(AthkarConstants.lastSyncKey);
      
      final categories = await loadCategories();
      for (final category in categories) {
        final key = AthkarConstants.getProgressKey(category.id);
        await _storage.remove(key);
      }
      
      _progressCache.clear();
      _customTimesCache.clear();
      _categoriesCache = null;
      _lastSyncTime = null;
      
      await NotificationManager.instance.cancelAllAthkarReminders();
      
      _logger.info(message: '[AthkarService] All data cleared successfully');
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to clear data',
        error: e,
      );
      rethrow;
    }
  }
}