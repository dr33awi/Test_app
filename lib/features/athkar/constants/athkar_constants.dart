// lib/features/athkar/constants/athkar_constants.dart - مُنظف
import 'package:flutter/material.dart';

/// ثوابت موحدة لميزة الأذكار
class AthkarConstants {
  AthkarConstants._();

  // ==================== أوقات التذكير الافتراضية ====================
  static const Map<String, TimeOfDay> defaultTimes = {
    'morning': TimeOfDay(hour: 6, minute: 0),      // أذكار الصباح
    'evening': TimeOfDay(hour: 18, minute: 0),     // أذكار المساء
    'sleep': TimeOfDay(hour: 22, minute: 0),       // أذكار النوم
    'wakeup': TimeOfDay(hour: 5, minute: 30),      // أذكار الاستيقاظ
    'prayer': TimeOfDay(hour: 12, minute: 0),      // أذكار الصلاة
    'eating': TimeOfDay(hour: 19, minute: 0),      // أذكار الطعام
    'travel': TimeOfDay(hour: 8, minute: 0),       // أذكار السفر
    'general': TimeOfDay(hour: 14, minute: 0),     // أذكار عامة
  };

  // ==================== الفئات الأساسية ====================
  /// الفئات التي يتم تفعيلها تلقائياً عند أول استخدام
  static const Set<String> autoEnabledCategories = {
    'morning',
    'الصباح',
    'evening',
    'المساء',
    'sleep',
    'النوم',
  };

  /// الفئات الأساسية التي يجب إظهارها دائماً مع شارة "أساسي"
  static const Set<String> essentialCategories = {
    'morning',
    'الصباح',
    'evening',
    'المساء',
    'sleep',
    'النوم',
  };

  /// الفئات التي لا يظهر لها وقت في البطاقة
  static const Set<String> hiddenTimeCategories = {
    'morning',
    'الصباح',
    'evening',
    'المساء',
    'sleep',
    'النوم',
  };

  // ==================== مفاتيح التخزين ====================
  static const String categoriesKey = 'athkar_categories_v2';
  static const String progressKey = 'athkar_progress';
  static const String reminderKey = 'athkar_reminder_enabled';
  static const String customTimesKey = 'athkar_custom_times_v2';
  static const String fontSizeKey = 'athkar_font_size';
  static const String lastSyncKey = 'athkar_last_sync';
  static const String settingsVersionKey = 'athkar_settings_version';
  
  // ==================== إصدارات الإعدادات ====================
  static const int currentSettingsVersion = 2;
  static const int minimumSupportedVersion = 1;

  // ==================== قيم افتراضية ====================
  static const double defaultFontSize = 18.0;
  static const double minFontSize = 14.0;
  static const double maxFontSize = 30.0;
  
  // ==================== حدود الكاش ====================
  static const int cacheValidityHours = 24;

  // ==================== دوال مساعدة ====================
  
  /// الحصول على الوقت الافتراضي لفئة معينة
  static TimeOfDay getDefaultTimeForCategory(String categoryId) {
    final lowerCaseId = categoryId.toLowerCase();
    
    for (final entry in defaultTimes.entries) {
      if (lowerCaseId.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return const TimeOfDay(hour: 9, minute: 0); // الوقت الافتراضي العام
  }

  /// التحقق من أن الفئة يجب تفعيلها تلقائياً
  static bool shouldAutoEnable(String categoryId) {
    final lowerCaseId = categoryId.toLowerCase();
    
    for (final key in autoEnabledCategories) {
      if (lowerCaseId == key.toLowerCase() || lowerCaseId.contains(key)) {
        return true;
      }
    }
    return false;
  }

  /// التحقق من أن الفئة أساسية
  static bool isEssentialCategory(String categoryId) {
    final lowerCaseId = categoryId.toLowerCase();
    
    for (final key in essentialCategories) {
      if (lowerCaseId == key.toLowerCase() || lowerCaseId.contains(key)) {
        return true;
      }
    }
    return false;
  }

  /// التحقق من عرض الوقت للفئة
  static bool shouldShowTime(String categoryId) {
    return !hiddenTimeCategories.contains(categoryId.toLowerCase());
  }

  /// تحويل نص إلى TimeOfDay
  static TimeOfDay? parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        if (hour != null && minute != null && 
            hour >= 0 && hour < 24 && 
            minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (_) {
      // تجاهل الأخطاء وإرجاع null
    }
    return null;
  }

  /// تحويل TimeOfDay إلى نص
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// الحصول على مفتاح التقدم لفئة معينة
  static String getProgressKey(String categoryId) {
    return '${progressKey}_$categoryId';
  }

  /// التحقق من صلاحية الكاش
  static bool isCacheValid(DateTime? cachedAt) {
    if (cachedAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inHours < cacheValidityHours;
  }
}

/// أنواع أحجام الخط
enum AthkarFontSize {
  small(size: 16.0, label: 'صغير'),
  medium(size: 18.0, label: 'متوسط'),
  large(size: 22.0, label: 'كبير'),
  extraLarge(size: 26.0, label: 'كبير جداً');

  final double size;
  final String label;

  const AthkarFontSize({
    required this.size,
    required this.label,
  });

  static AthkarFontSize fromSize(double size) {
    for (final fontSize in AthkarFontSize.values) {
      if (fontSize.size == size) {
        return fontSize;
      }
    }
    return AthkarFontSize.medium;
  }
}

/// أولويات الفئات للعرض
class AthkarCategoryPriority {
  static const Map<String, int> priorities = {
    'morning': 1,
    'الصباح': 1,
    'evening': 2,
    'المساء': 2,
    'sleep': 3,
    'النوم': 3,
    'wakeup': 4,
    'الاستيقاظ': 4,
    'prayer': 5,
    'الصلاة': 5,
    'eating': 6,
    'الطعام': 6,
    'quran': 7,
    'القرآن': 7,
    'tasbih': 8,
    'التسبيح': 8,
    'dua': 9,
    'الدعاء': 9,
    'istighfar': 10,
    'الاستغفار': 10,
    'friday': 11,
    'الجمعة': 11,
    'travel': 12,
    'السفر': 12,
    'ramadan': 13,
    'رمضان': 13,
    'hajj': 14,
    'الحج': 14,
    'eid': 15,
    'العيد': 15,
    'illness': 16,
    'المرض': 16,
    'rain': 17,
    'المطر': 17,
    'wind': 18,
    'الرياح': 18,
    'general': 19,
    'عامة': 19,
  };

  static int getPriority(String categoryId) {
    return priorities[categoryId.toLowerCase()] ?? 99;
  }

  static int compare(String categoryA, String categoryB) {
    final priorityA = getPriority(categoryA);
    final priorityB = getPriority(categoryB);
    return priorityA.compareTo(priorityB);
  }
}