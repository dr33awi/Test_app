// lib/features/athkar/services/athkar_service.dart (محسن مع دعم حجم الخط)
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/notifications/notification_manager.dart';
import '../../../core/infrastructure/services/notifications/models/notification_models.dart';
import '../models/athkar_model.dart';
import '../models/athkar_progress.dart';

/// خدمة شاملة لإدارة الأذكار محسنة
class AthkarService {
  final LoggerService _logger;
  final StorageService _storage;

  // مفاتيح التخزين المحسنة
  static const String _categoriesKey = 'athkar_categories_v2';
  static const String _progressKey = AppConstants.athkarProgressKey;
  static const String _reminderKey = AppConstants.athkarReminderKey;
  static const String _customTimesKey = 'athkar_custom_times_v2';
  static const String _settingsVersionKey = 'athkar_settings_version';
  static const String _lastSyncKey = 'athkar_last_sync';
  static const String _fontSizeKey = 'athkar_font_size'; // NEW: مفتاح حجم الخط
  
  // إصدار الإعدادات الحالي
  static const int _currentVersion = 2;

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

  // ==================== تحديث الإعدادات ====================

  /// التحقق من إصدار الإعدادات وترقيتها
  Future<void> _checkAndMigrateSettings() async {
    final currentVersion = _storage.getInt(_settingsVersionKey) ?? 1;
    
    if (currentVersion < _currentVersion) {
      await _migrateSettings(currentVersion);
      await _storage.setInt(_settingsVersionKey, _currentVersion);
      
      _logger.info(
        message: '[AthkarService] تم ترقية الإعدادات',
        data: {'من': currentVersion, 'إلى': _currentVersion},
      );
    }
  }

  /// ترقية الإعدادات من إصدار قديم
  Future<void> _migrateSettings(int fromVersion) async {
    try {
      if (fromVersion < 2) {
        // ترقية من الإصدار 1 إلى 2
        await _migrateFromV1ToV2();
      }
    } catch (e) {
      _logger.error(
        message: '[AthkarService] خطأ في ترقية الإعدادات',
        error: e,
      );
    }
  }

  /// ترقية من الإصدار 1 إلى 2
  Future<void> _migrateFromV1ToV2() async {
    // نقل الأوقات المخصصة إذا كانت موجودة في مفتاح قديم
    const oldKey = 'athkar_custom_times';
    final oldTimes = _storage.getMap(oldKey);
    
    if (oldTimes != null) {
      await _storage.setMap(_customTimesKey, oldTimes);
      await _storage.remove(oldKey);
    }
    
    // تحديث آخر وقت مزامنة
    await _storage.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // ==================== إدارة حجم الخط (NEW) ====================

  /// حفظ حجم الخط المختار
  Future<void> saveFontSize(double fontSize) async {
    try {
      await _storage.setDouble(_fontSizeKey, fontSize);
      _logger.info(
        message: '[AthkarService] تم حفظ حجم الخط',
        data: {'fontSize': fontSize},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] خطأ في حفظ حجم الخط',
        error: e,
      );
    }
  }

  /// الحصول على حجم الخط المحفوظ
  Future<double> getSavedFontSize() async {
    try {
      return _storage.getDouble(_fontSizeKey) ?? 18.0; // الافتراضي متوسط
    } catch (e) {
      _logger.error(
        message: '[AthkarService] خطأ في الحصول على حجم الخط المحفوظ',
        error: e,
      );
      return 18.0; // الافتراضي متوسط
    }
  }

  // ==================== تحميل البيانات ====================

  /// تحميل فئات الأذكار مع التحسينات
  Future<List<AthkarCategory>> loadCategories() async {
    try {
      // التحقق من ترقية الإعدادات
      await _checkAndMigrateSettings();
      
      // التحقق من الكاش
      if (_categories != null) {
        _logger.debug(message: '[AthkarService] تحميل الفئات من الكاش');
        return _categories!;
      }

      // محاولة تحميل من التخزين المحلي أولاً
      final cachedData = _storage.getMap(_categoriesKey);
      if (cachedData != null && _isCacheValid(cachedData)) {
        _logger.debug(message: '[AthkarService] تحميل الفئات من التخزين المحلي');
        final List<dynamic> list = cachedData['categories'] ?? [];
        _categories = list
            .map((e) => AthkarCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        return _categories!;
      }

      // تحميل من الأصول
      _logger.info(message: '[AthkarService] تحميل الفئات من الأصول');
      final jsonStr = await rootBundle.loadString(AppConstants.athkarDataFile);
      final Map<String, dynamic> data = json.decode(jsonStr);
      
      // إضافة معلومات الكاش
      data['cached_at'] = DateTime.now().toIso8601String();
      data['version'] = _currentVersion;
      
      // حفظ في التخزين المحلي
      await _storage.setMap(_categoriesKey, data);
      
      final List<dynamic> list = data['categories'] ?? [];
      _categories = list
          .map((e) => AthkarCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // تحميل الأوقات المخصصة
      await _loadCustomTimes();
      
      _logger.info(
        message: '[AthkarService] تم تحميل الفئات',
        data: {'count': _categories!.length},
      );
      
      return _categories!;
    } catch (e, stackTrace) {
      _logger.error(
        message: '[AthkarService] فشل تحميل الفئات',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('فشل تحميل بيانات الأذكار: $e');
    }
  }

  /// التحقق من صحة الكاش
  bool _isCacheValid(Map<String, dynamic> cachedData) {
    try {
      final cachedAtStr = cachedData['cached_at'] as String?;
      final version = cachedData['version'] as int?;
      
      if (cachedAtStr == null || version != _currentVersion) {
        return false;
      }
      
      final cachedAt = DateTime.parse(cachedAtStr);
      final now = DateTime.now();
      final hoursSinceCache = now.difference(cachedAt).inHours;
      
      // الكاش صالح لـ 24 ساعة
      return hoursSinceCache < 24;
    } catch (e) {
      return false;
    }
  }

  /// تحميل الأوقات المخصصة
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
        message: '[AthkarService] خطأ في تحميل الأوقات المخصصة',
        data: {'error': e.toString()},
      );
    }
  }

  /// تحويل نص إلى TimeOfDay
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
        message: '[AthkarService] خطأ في تحويل الوقت',
        data: {'timeString': timeString},
      );
    }
    return null;
  }

  /// الحصول على فئة حسب المعرف
  Future<AthkarCategory?> getCategoryById(String id) async {
    try {
      final categories = await loadCategories();
      return categories.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('الفئة غير موجودة'),
      );
    } catch (e) {
      _logger.warning(
        message: '[AthkarService] فئة غير موجودة',
        data: {'categoryId': id},
      );
      return null;
    }
  }

  // ==================== إدارة التقدم ====================

  /// الحصول على تقدم فئة معينة
  Future<AthkarProgress> getCategoryProgress(String categoryId) async {
    // التحقق من الكاش
    if (_progressCache.containsKey(categoryId)) {
      return _progressCache[categoryId]!;
    }

    // تحميل من التخزين
    final key = '${_progressKey}_$categoryId';
    final data = _storage.getMap(key);
    
    if (data != null) {
      final progress = AthkarProgress.fromJson(data);
      _progressCache[categoryId] = progress;
      return progress;
    }

    // إنشاء تقدم جديد
    final category = await getCategoryById(categoryId);
    if (category == null) {
      throw Exception('الفئة غير موجودة');
    }

    final progress = AthkarProgress(
      categoryId: categoryId,
      itemProgress: {},
      lastUpdated: DateTime.now(),
    );
    
    _progressCache[categoryId] = progress;
    return progress;
  }

  /// تحديث تقدم ذكر معين
  Future<void> updateItemProgress({
    required String categoryId,
    required int itemId,
    required int count,
  }) async {
    try {
      final progress = await getCategoryProgress(categoryId);
      progress.itemProgress[itemId] = count;
      progress.lastUpdated = DateTime.now();

      // حفظ في التخزين
      final key = '${_progressKey}_$categoryId';
      await _storage.setMap(key, progress.toJson());
      
      // تحديث الكاش
      _progressCache[categoryId] = progress;

      _logger.debug(
        message: '[AthkarService] تم تحديث التقدم',
        data: {
          'categoryId': categoryId,
          'itemId': itemId,
          'count': count,
        },
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل تحديث التقدم',
        error: e,
      );
      rethrow;
    }
  }

  /// إعادة تعيين تقدم فئة
  Future<void> resetCategoryProgress(String categoryId) async {
    try {
      final key = '${_progressKey}_$categoryId';
      await _storage.remove(key);
      _progressCache.remove(categoryId);

      _logger.info(
        message: '[AthkarService] تم إعادة تعيين التقدم',
        data: {'categoryId': categoryId},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل إعادة تعيين التقدم',
        error: e,
      );
      rethrow;
    }
  }

  /// الحصول على نسبة إكمال فئة
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
        message: '[AthkarService] فشل حساب نسبة الإكمال',
        error: e,
      );
      return 0;
    }
  }

  // ==================== إدارة التذكيرات المحسنة ====================

  /// جدولة تذكيرات الفئات بكفاءة
  Future<void> scheduleCategoryReminders() async {
    try {
      final categories = await loadCategories();
      final enabledIds = getEnabledReminderCategories();
      
      if (enabledIds.isEmpty) {
        _logger.info(message: '[AthkarService] لا توجد فئات مفعلة للتذكير');
        return;
      }

      final notificationManager = NotificationManager.instance;
      int scheduledCount = 0;

      for (final category in categories) {
        if (!enabledIds.contains(category.id)) continue;
        
        // الحصول على الوقت المخصص أو الافتراضي
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
          message: '[AthkarService] تم جدولة تذكير',
          data: {
            'categoryId': category.id,
            'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
          },
        );
      }
      
      _logger.info(
        message: '[AthkarService] تم جدولة التذكيرات',
        data: {'scheduledCount': scheduledCount, 'totalEnabled': enabledIds.length},
      );
      
      // تحديث وقت آخر مزامنة
      await _updateLastSyncTime();
      
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل جدولة التذكيرات',
        error: e,
      );
      rethrow;
    }
  }

  /// الحصول على وقت افتراضي للفئة
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

  /// تحديث وقت آخر مزامنة
  Future<void> _updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    await _storage.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
  }

  /// الحصول على وقت آخر مزامنة
  DateTime? getLastSyncTime() {
    if (_lastSyncTime != null) return _lastSyncTime;
    
    final syncTimeStr = _storage.getString(_lastSyncKey);
    if (syncTimeStr != null) {
      try {
        _lastSyncTime = DateTime.parse(syncTimeStr);
        return _lastSyncTime;
      } catch (e) {
        _logger.warning(message: '[AthkarService] خطأ في تحليل وقت المزامنة');
      }
    }
    
    return null;
  }

  /// الحصول على الفئات المفعلة للتذكير
  List<String> getEnabledReminderCategories() {
    return _storage.getStringList(_reminderKey) ?? [];
  }

  /// تحديث الفئات المفعلة للتذكيرات (محسن)
  Future<void> setEnabledReminderCategories(List<String> enabledIds) async {
    try {
      // حفظ القائمة الجديدة
      await _storage.setStringList(_reminderKey, enabledIds);
      
      // تحديث وقت آخر مزامنة
      await _updateLastSyncTime();
      
      _logger.info(
        message: '[AthkarService] تم تحديث الفئات المفعلة للتذكيرات',
        data: {'enabledIds': enabledIds, 'count': enabledIds.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل تحديث الفئات المفعلة للتذكيرات',
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
        timesMap[categoryId] = '${time.hour}:${time.minute}';
      });
      
      await _storage.setMap(_customTimesKey, timesMap);
      
      // تحديث الكاش
      _customTimesCache.clear();
      _customTimesCache.addAll(customTimes);
      
      _logger.debug(
        message: '[AthkarService] تم حفظ الأوقات المخصصة',
        data: {'count': customTimes.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل حفظ الأوقات المخصصة',
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

  /// تحديث إعدادات التذكيرات بكفاءة
  Future<void> updateReminderSettings({
    required Map<String, bool> enabledMap,
    Map<String, TimeOfDay>? customTimes,
  }) async {
    try {
      // تحديد الفئات المفعلة
      final enabledIds = enabledMap.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      
      // حفظ الفئات المفعلة
      await setEnabledReminderCategories(enabledIds);
      
      // حفظ الأوقات المخصصة إذا تم توفيرها
      if (customTimes != null) {
        await saveCustomTimes(customTimes);
      }

      // إلغاء جميع الإشعارات أولاً
      await NotificationManager.instance.cancelAllAthkarReminders();

      // جدولة الإشعارات للفئات المفعلة فقط
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
        message: '[AthkarService] تم تحديث إعدادات التذكيرات',
        data: {'enabledCount': enabledIds.length},
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل تحديث إعدادات التذكيرات',
        error: e,
      );
      rethrow;
    }
  }

  /// التحقق من صحة الإشعارات المجدولة
  Future<NotificationValidationResult> validateScheduledNotifications() async {
    try {
      final enabledIds = getEnabledReminderCategories();
      final scheduledNotifications = await NotificationManager.instance
          .getScheduledNotifications();
      
      final scheduledAthkarIds = scheduledNotifications
          .where((n) => n.category == NotificationCategory.athkar)
          .map((n) => n.payload?['categoryId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();
      
      final enabledSet = enabledIds.toSet();
      final missingNotifications = enabledSet.difference(scheduledAthkarIds);
      final extraNotifications = scheduledAthkarIds.difference(enabledSet);
      
      final result = NotificationValidationResult(
        isValid: missingNotifications.isEmpty && extraNotifications.isEmpty,
        missingNotifications: missingNotifications.toList(),
        extraNotifications: extraNotifications.toList(),
        totalEnabled: enabledIds.length,
        totalScheduled: scheduledAthkarIds.length,
      );
      
      _logger.info(
        message: '[AthkarService] نتيجة التحقق من الإشعارات',
        data: {
          'isValid': result.isValid,
          'missing': result.missingNotifications.length,
          'extra': result.extraNotifications.length,
        },
      );
      
      return result;
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل التحقق من الإشعارات',
        error: e,
      );
      rethrow;
    }
  }

  /// إصلاح الإشعارات غير المتطابقة
  Future<void> fixNotificationMismatch() async {
    try {
      final validationResult = await validateScheduledNotifications();
      
      if (validationResult.isValid) {
        _logger.info(message: '[AthkarService] الإشعارات متطابقة، لا حاجة للإصلاح');
        return;
      }
      
      // إلغاء الإشعارات الزائدة
      for (final extraId in validationResult.extraNotifications) {
        await NotificationManager.instance.cancelAthkarReminder(extraId);
      }
      
      // جدولة الإشعارات المفقودة
      if (validationResult.missingNotifications.isNotEmpty) {
        final categories = await loadCategories();
        
        for (final missingId in validationResult.missingNotifications) {
          final category = categories.firstWhere((c) => c.id == missingId);
          final time = _customTimesCache[missingId] ?? 
                      category.notifyTime ?? 
                      _getDefaultTimeForCategory(missingId);

          await NotificationManager.instance.scheduleAthkarReminder(
            categoryId: missingId,
            categoryName: category.title,
            time: time,
          );
        }
      }
      
      _logger.info(
        message: '[AthkarService] تم إصلاح عدم تطابق الإشعارات',
        data: {
          'canceledExtra': validationResult.extraNotifications.length,
          'scheduledMissing': validationResult.missingNotifications.length,
        },
      );
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل إصلاح عدم تطابق الإشعارات',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== البحث ====================

  /// البحث في الأذكار
  Future<List<SearchResult>> searchAthkar(String query) async {
    try {
      if (query.isEmpty) return [];

      final categories = await loadCategories();
      final results = <SearchResult>[];
      final normalizedQuery = query.toLowerCase().trim();

      for (final category in categories) {
        for (final item in category.athkar) {
          // البحث في النص
          if (item.text.toLowerCase().contains(normalizedQuery)) {
            results.add(SearchResult(
              category: category,
              item: item,
              matchType: MatchType.text,
            ));
          }
          // البحث في الفضل
          else if (item.fadl?.toLowerCase().contains(normalizedQuery) ?? false) {
            results.add(SearchResult(
              category: category,
              item: item,
              matchType: MatchType.fadl,
            ));
          }
          // البحث في المصدر
          else if (item.source?.toLowerCase().contains(normalizedQuery) ?? false) {
            results.add(SearchResult(
              category: category,
              item: item,
              matchType: MatchType.source,
            ));
          }
        }
      }

      _logger.info(
        message: '[AthkarService] نتائج البحث',
        data: {
          'query': query,
          'results': results.length,
        },
      );

      return results;
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل البحث',
        error: e,
      );
      return [];
    }
  }

  // ==================== إحصائيات وتقارير ====================

  /// الحصول على إحصائيات شاملة
  Future<AthkarStatistics> getStatistics() async {
    try {
      final categories = await loadCategories();
      final enabledIds = getEnabledReminderCategories();
      
      int totalAthkar = 0;
      int completedCategories = 0;
      int totalProgress = 0;
      
      for (final category in categories) {
        totalAthkar += category.athkar.length;
        
        final progress = await getCategoryCompletionPercentage(category.id);
        totalProgress += progress;
        
        if (progress >= 100) {
          completedCategories++;
        }
      }
      
      final averageProgress = categories.isNotEmpty ? totalProgress ~/ categories.length : 0;
      
      final stats = AthkarStatistics(
        totalCategories: categories.length,
        enabledCategories: enabledIds.length,
        completedCategories: completedCategories,
        totalAthkar: totalAthkar,
        averageProgress: averageProgress,
        lastSyncTime: getLastSyncTime(),
      );
      
      _logger.info(
        message: '[AthkarService] إحصائيات الأذكار',
        data: {
          'totalCategories': stats.totalCategories,
          'enabledCategories': stats.enabledCategories,
          'completedCategories': stats.completedCategories,
          'averageProgress': stats.averageProgress,
        },
      );
      
      return stats;
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل الحصول على الإحصائيات',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== تنظيف البيانات ====================

  /// مسح جميع البيانات المحفوظة
  Future<void> clearAllData() async {
    try {
      // مسح التقدم
      final categories = await loadCategories();
      for (final category in categories) {
        await resetCategoryProgress(category.id);
      }

      // مسح الأوقات المخصصة
      await _storage.remove(_customTimesKey);
      
      // مسح الفئات المفعلة
      await _storage.remove(_reminderKey);
      
      // مسح الكاش المحلي
      await _storage.remove(_categoriesKey);

      // مسح حجم الخط (NEW)
      await _storage.remove(_fontSizeKey);

      // مسح الكاش في الذاكرة
      _progressCache.clear();
      _customTimesCache.clear();
      _categories = null;
      _lastSyncTime = null;

      _logger.info(message: '[AthkarService] تم مسح جميع البيانات');
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل مسح البيانات',
        error: e,
      );
      rethrow;
    }
  }

  /// إعادة تعيين الإعدادات إلى القيم الافتراضية
  Future<void> resetToDefaults() async {
    try {
      // إلغاء جميع الإشعارات
      await NotificationManager.instance.cancelAllAthkarReminders();
      
      // مسح الإعدادات
      await _storage.remove(_reminderKey);
      await _storage.remove(_customTimesKey);
      await _storage.remove(_fontSizeKey); // NEW
      
      // مسح الكاش
      _customTimesCache.clear();
      
      _logger.info(message: '[AthkarService] تم إعادة تعيين الإعدادات');
    } catch (e) {
      _logger.error(
        message: '[AthkarService] فشل إعادة تعيين الإعدادات',
        error: e,
      );
      rethrow;
    }
  }

  /// التنظيف عند إغلاق التطبيق
  void dispose() {
    _progressCache.clear();
    _customTimesCache.clear();
    _categories = null;
    _lastSyncTime = null;
    _logger.debug(message: '[AthkarService] تم التنظيف');
  }
}

// ==================== نماذج البحث والإحصائيات ====================

enum MatchType { text, fadl, source }

class SearchResult {
  final AthkarCategory category;
  final AthkarItem item;
  final MatchType matchType;

  SearchResult({
    required this.category,
    required this.item,
    required this.matchType,
  });
}

/// نتيجة التحقق من الإشعارات
class NotificationValidationResult {
  final bool isValid;
  final List<String> missingNotifications;
  final List<String> extraNotifications;
  final int totalEnabled;
  final int totalScheduled;

  NotificationValidationResult({
    required this.isValid,
    required this.missingNotifications,
    required this.extraNotifications,
    required this.totalEnabled,
    required this.totalScheduled,
  });
}

/// إحصائيات الأذكار
class AthkarStatistics {
  final int totalCategories;
  final int enabledCategories;
  final int completedCategories;
  final int totalAthkar;
  final int averageProgress;
  final DateTime? lastSyncTime;

  AthkarStatistics({
    required this.totalCategories,
    required this.enabledCategories,
    required this.completedCategories,
    required this.totalAthkar,
    required this.averageProgress,
    this.lastSyncTime,
  });
}