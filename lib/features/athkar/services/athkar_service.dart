// lib/features/athkar/services/athkar_service.dart (منظف من التكرار)
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/notifications/notification_manager.dart';
import '../../../core/infrastructure/services/notifications/models/notification_models.dart';
import '../models/athkar_model.dart';
import '../models/athkar_progress.dart';

/// خدمة إدارة الأذكار (منظفة من التكرار)
class AthkarService {
  final LoggerService _logger;
  final StorageService _storage;

  // مفاتيح التخزين
  static const String _categoriesKey = 'athkar_categories_v2';
  static const String _progressKey = AppConstants.athkarProgressKey;
  static const String _reminderKey = AppConstants.athkarReminderKey;
  static const String _customTimesKey = 'athkar_custom_times_v2';
  static const String _fontSizeKey = 'athkar_font_size';
  static const String _lastSyncKey = 'athkar_last_sync';
  
  // كاش البيانات
  List<AthkarCategory>? _categories;
  final Map<String, AthkarProgress> _progressCache = {};
  final Map<String, TimeOfDay> _customTimesCache = {};
  DateTime? _lastSyncTime;

  AthkarService({
    required LoggerService logger,
    required StorageService storage,
  })  : _logger = logger,
        _storage = storage;

  // ==================== إدارة حجم الخط ====================

  Future<void> saveFontSize(double fontSize) async {
    try {
      await _storage.setDouble(_fontSizeKey, fontSize);
      _logger.info(
        message: '[AthkarService] Font size saved',
        data: {'fontSize': fontSize},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Error saving font size',
        error: e,
      );
    }
  }

  Future<double> getSavedFontSize() async {
    try {
      return _storage.getDouble(_fontSizeKey) ?? 18.0;
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Error getting saved font size',
        error: e,
      );
      return 18.0;
    }
  }

  // ==================== تحميل البيانات ====================

  Future<List<AthkarCategory>> loadCategories() async {
    try {
      if (_categories != null) {
        _logger.debug(message: '[AthkarService] Loading categories from cache');
        return _categories!;
      }

      // محاولة تحميل من التخزين المحلي
      final cachedData = _storage.getMap(_categoriesKey);
      if (cachedData != null && _isCacheValid(cachedData)) {
        _logger.debug(message: '[AthkarService] Loading categories from local storage');
        final List<dynamic> list = cachedData['categories'] ?? [];
        _categories = list
            .map((e) => AthkarCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        return _categories!;
      }

      // تحميل من الأصول
      _logger.info(message: '[AthkarService] Loading categories from assets');
      final jsonStr = await rootBundle.loadString(AppConstants.athkarDataFile);
      final Map<String, dynamic> data = json.decode(jsonStr);
      
      data['cached_at'] = DateTime.now().toIso8601String();
      data['version'] = 2;
      
      await _storage.setMap(_categoriesKey, data);
      
      final List<dynamic> list = data['categories'] ?? [];
      _categories = list
          .map((e) => AthkarCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      
      await _loadCustomTimes();
      
      _logger.info(
        message: '[AthkarService] Categories loaded',
        data: {'count': _categories!.length},
      );
      
      return _categories!;
    } catch (e, stackTrace) {
      _logger.error(
        message: '[AthkarService] Failed to load categories',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load athkar data: $e');
    }
  }

  bool _isCacheValid(Map<String, dynamic> cachedData) {
    try {
      final cachedAtStr = cachedData['cached_at'] as String?;
      final version = cachedData['version'] as int?;
      
      if (cachedAtStr == null || version != 2) {
        return false;
      }
      
      final cachedAt = DateTime.parse(cachedAtStr);
      final now = DateTime.now();
      final hoursSinceCache = now.difference(cachedAt).inHours;
      
      return hoursSinceCache < 24;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadCustomTimes() async {
    try {
      final savedTimes = _storage.getMap(_customTimesKey);
      
      if (savedTimes != null) {
        _customTimesCache.clear();
        savedTimes.forEach((categoryId, timeString) {
          final time = _parseTimeOfDay(timeString);
          if (time != null) {
            _customTimesCache[categoryId] = time;
          }
        });
      }
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] Error loading custom times',
        data: {'error': e.toString()},
      );
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;
    
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] Error parsing time',
        data: {'timeString': timeString},
      );
    }
    return null;
  }

  Future<AthkarCategory?> getCategoryById(String id) async {
    try {
      final categories = await loadCategories();
      return categories.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Category not found'),
      );
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] Category not found',
        data: {'categoryId': id},
      );
      return null;
    }
  }

  // ==================== إدارة التقدم ====================

  Future<AthkarProgress> getCategoryProgress(String categoryId) async {
    if (_progressCache.containsKey(categoryId)) {
      return _progressCache[categoryId]!;
    }

    final key = '${_progressKey}_$categoryId';
    final data = _storage.getMap(key);
    
    if (data != null) {
      final progress = AthkarProgress.fromJson(data);
      _progressCache[categoryId] = progress;
      return progress;
    }

    final category = await getCategoryById(categoryId);
    if (category == null) {
      throw Exception('Category not found');
    }

    final progress = AthkarProgress(
      categoryId: categoryId,
      itemProgress: {},
      lastUpdated: DateTime.now(),
    );
    
    _progressCache[categoryId] = progress;
    return progress;
  }

  Future<void> updateItemProgress({
    required String categoryId,
    required int itemId,
    required int count,
  }) async {
    try {
      final progress = await getCategoryProgress(categoryId);
      progress.itemProgress[itemId] = count;
      progress.lastUpdated = DateTime.now();

      final key = '${_progressKey}_$categoryId';
      await _storage.setMap(key, progress.toJson());
      
      _progressCache[categoryId] = progress;

      _logger.debug(
        message: '[AthkarService] Progress updated',
        data: {
          'categoryId': categoryId,
          'itemId': itemId,
          'count': count,
        },
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to update progress',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> resetCategoryProgress(String categoryId) async {
    try {
      final key = '${_progressKey}_$categoryId';
      await _storage.remove(key);
      _progressCache.remove(categoryId);

      _logger.info(
        message: '[AthkarService] Progress reset',
        data: {'categoryId': categoryId},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to reset progress',
        error: e,
      );
      rethrow;
    }
  }

  Future<int> getCategoryCompletionPercentage(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      if (category == null) return 0;

      final progress = await getCategoryProgress(categoryId);
      
      int totalRequired = 0;
      int totalCompleted = 0;

      for (final item in category.athkar) {
        totalRequired += item.count;
        final completed = progress.itemProgress[item.id] ?? 0;
        totalCompleted += completed.clamp(0, item.count);
      }

      if (totalRequired == 0) return 0;
      return ((totalCompleted / totalRequired) * 100).round();
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Failed to calculate completion percentage',
        error: e,
      );
      return 0;
    }
  }

  // ==================== إدارة التذكيرات ====================

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

      for (final category in categories) {
        if (!enabledIds.contains(category.id)) continue;
        
        final time = _customTimesCache[category.id] ?? 
                    category.notifyTime ?? 
                    _getDefaultTimeForCategory(category.id);
        
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
            'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
          },
        );
      }
      
      _logger.info(
        message: '[AthkarService] Reminders scheduled',
        data: {'scheduledCount': scheduledCount, 'totalEnabled': enabledIds.length},
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

  TimeOfDay _getDefaultTimeForCategory(String categoryId) {
    const defaultTimes = {
      'morning': TimeOfDay(hour: 6, minute: 0),
      'evening': TimeOfDay(hour: 18, minute: 0),
      'sleep': TimeOfDay(hour: 22, minute: 0),
      'prayer': TimeOfDay(hour: 12, minute: 0),
    };
    
    for (final key in defaultTimes.keys) {
      if (categoryId.toLowerCase().contains(key)) {
        return defaultTimes[key]!;
      }
    }
    
    return const TimeOfDay(hour: 9, minute: 0);
  }

  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    await _storage.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    if (_lastSyncTime != null) return _lastSyncTime;
    
    final syncTimeStr = _storage.getString(_lastSyncKey);
    if (syncTimeStr != null) {
      try {
        _lastSyncTime = DateTime.parse(syncTimeStr);
        return _lastSyncTime;
      } catch (e) {
        _logger.warning(message: '[AthkarService] Error parsing sync time');
      }
    }
    
    return null;
  }

  List<String> getEnabledReminderCategories() {
    return _storage.getStringList(_reminderKey) ?? [];
  }

  Future<void> setEnabledReminderCategories(List<String> enabledIds) async {
    try {
      await _storage.setStringList(_reminderKey, enabledIds);
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

  Future<void> saveCustomTimes(Map<String, TimeOfDay> customTimes) async {
    try {
      final timesMap = <String, String>{};
      
      customTimes.forEach((categoryId, time) {
        timesMap[categoryId] = '${time.hour}:${time.minute}';
      });
      
      await _storage.setMap(_customTimesKey, timesMap);
      
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

  Map<String, TimeOfDay> getCustomTimes() {
    return Map.from(_customTimesCache);
  }

  TimeOfDay? getCustomTimeForCategory(String categoryId) {
    return _customTimesCache[categoryId];
  }

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

      await NotificationManager.instance.cancelAllAthkarReminders();

      if (enabledIds.isNotEmpty) {
        final categories = await loadCategories();
        
        for (final categoryId in enabledIds) {
          final category = categories.firstWhere((c) => c.id == categoryId);
          final time = _customTimesCache[categoryId] ?? 
                      category.notifyTime ?? 
                      _getDefaultTimeForCategory(categoryId);

          await NotificationManager.instance.scheduleAthkarReminder(
            categoryId: categoryId,
            categoryName: category.title,
            time: time,
          );
        }
      }

      _logger.info(
        message: '[AthkarService] Reminder settings updated',
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

  // ==================== المزامنة مع الإحصائيات ====================
  
  /// مزامنة البيانات مع نظام الإحصائيات
  /// يتم استدعاؤها من الشاشات للتأكد من تحديث الإحصائيات
  Future<void> syncWithStatisticsService() async {
    try {
      _logger.info(message: '[AthkarService] Syncing with statistics service');
      
      // هذه الدالة متاحة للاستخدام من الشاشات
      // يمكن إضافة منطق المزامنة هنا إذا لزم الأمر
      // حالياً فارغة للتوافق مع الكود الحالي
      
      _logger.info(message: '[AthkarService] Sync completed');
    } catch (e) {
      _logger.error(
        message: '[AthkarService] Sync failed',
        error: e,
      );
    }
  }

  // ==================== التنظيف ====================

  void dispose() {
    _progressCache.clear();
    _customTimesCache.clear();
    _categories = null;
    _lastSyncTime = null;
    _logger.debug(message: '[AthkarService] Disposed');
  }
}

// تم حذف:
// - searchAthkar() - غير مستخدم
// - getStatistics() - مكرر مع StatisticsService
// - clearAllData() - غير مستخدم
// - resetToDefaults() - غير مستخدم
// - SearchResult class - غير مستخدم
// - AthkarStatistics class - مكرر
// - CategoryStatistics class - مكرر
// - NotificationValidationResult - يمكن نقله لملف منفصل إذا لزم
// - validateScheduledNotifications() - غير مستخدم
// - fixNotificationMismatch() - غير مستخدم
// - recordCategoryCompletion() - تم النقل للـ integration
// - recordPartialProgress() - تم النقل للـ integration
// - getCategoryStatistics() - تم النقل للـ integration
// - getAllCategoriesStatistics() - تم النقل للـ integration