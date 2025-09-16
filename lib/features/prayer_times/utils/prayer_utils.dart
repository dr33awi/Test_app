// lib/features/prayer_times/utils/prayer_utils.dart
import 'package:flutter/material.dart';
import '../../../app/themes/theme_constants.dart';
import '../models/prayer_time_model.dart'; // استخدام النموذج الأصلي

/// أدوات موحدة لمواقيت الصلاة - بدون تكرار
class PrayerUtils {
  PrayerUtils._();

  // ==================== تنسيق الوقت ====================
  
  /// تنسيق وقت الصلاة - دالة واحدة موحدة
  static String formatTime(
    DateTime time, {
    bool use24Hour = false,
    bool showPeriod = true,
    bool shortPeriod = true,
  }) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = shortPeriod 
        ? (hour >= 12 ? 'م' : 'ص')
        : (hour >= 12 ? 'مساءً' : 'صباحاً');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    if (showPeriod) {
      return '$displayHour:$minute $period';
    }
    return '$displayHour:$minute';
  }

  /// تنسيق المدة المتبقية
  static String formatRemainingTime(Duration duration) {
    if (duration.isNegative || duration.inSeconds == 0) {
      return 'حان الآن';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 24) {
      final days = hours ~/ 24;
      return 'بعد $days يوم';
    } else if (hours > 0) {
      if (minutes > 0) {
        return 'بعد ${hours}س ${minutes}د';
      }
      return 'بعد $hours ساعة';
    } else if (minutes > 0) {
      return 'بعد $minutes دقيقة';
    } else {
      return 'بعد $seconds ثانية';
    }
  }

  /// تنسيق الوقت حتى موعد محدد
  static String formatTimeUntil(DateTime targetTime, {DateTime? fromTime}) {
    final from = fromTime ?? DateTime.now();
    final diff = targetTime.difference(from);
    return formatRemainingTime(diff);
  }

  // ==================== الألوان والأيقونات ====================
  
  /// الحصول على لون الصلاة - استخدام ThemeConstants مباشرة
  static Color getPrayerColor(PrayerType type) {
    return ThemeConstants.getPrayerColor(type.name);
  }

  /// الحصول على أيقونة الصلاة - استخدام ThemeConstants مباشرة
  static IconData getPrayerIcon(PrayerType type) {
    return ThemeConstants.getPrayerIcon(type.name);
  }

  /// الحصول على تدرج الصلاة
  static LinearGradient getPrayerGradient(PrayerType type) {
    return ThemeConstants.prayerGradient(type.name);
  }

  // ==================== رسائل الأخطاء ====================
  
  /// رسالة خطأ موحدة للموقع والصلاة
  static String getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // أخطاء الأذونات
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'يرجى السماح بالوصول للموقع من إعدادات التطبيق';
    }
    
    // أخطاء خدمة الموقع
    if (errorStr.contains('service') || errorStr.contains('disabled')) {
      return 'يرجى تفعيل خدمة الموقع من إعدادات الجهاز';
    }
    
    // أخطاء الشبكة
    if (errorStr.contains('network') || errorStr.contains('internet') || errorStr.contains('connection')) {
      return 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
    }
    
    // انتهاء الوقت
    if (errorStr.contains('timeout')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    }
    
    // أخطاء الموقع
    if (errorStr.contains('location')) {
      return 'لم نتمكن من تحديد موقعك، تحقق من إعدادات الموقع';
    }
    
    // خطأ عام
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
  }

  /// نوع الخطأ للتعامل المخصص
  static ErrorType getErrorType(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return ErrorType.permission;
    }
    if (errorStr.contains('service') || errorStr.contains('disabled')) {
      return ErrorType.locationService;
    }
    if (errorStr.contains('network') || errorStr.contains('internet')) {
      return ErrorType.network;
    }
    if (errorStr.contains('timeout')) {
      return ErrorType.timeout;
    }
    if (errorStr.contains('location')) {
      return ErrorType.location;
    }
    
    return ErrorType.unknown;
  }

  // ==================== الحسابات ====================
  
  /// حساب نسبة التقدم بين صلاتين
  static double calculateProgressBetweenPrayers(
    PrayerTime currentPrayer,
    PrayerTime nextPrayer, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final totalDuration = nextPrayer.time.difference(currentPrayer.time);
    final elapsed = now.difference(currentPrayer.time);
    
    if (totalDuration.inSeconds <= 0) return 0.0;
    
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  /// التحقق من اقتراب وقت الصلاة
  static bool isPrayerApproaching(PrayerTime prayer, {int minutesBefore = 15}) {
    final now = DateTime.now();
    final timeDiff = prayer.time.difference(now);
    return timeDiff.inMinutes > 0 && timeDiff.inMinutes <= minutesBefore;
  }

  /// الحصول على الصلاة الحالية من قائمة
  static PrayerTime? getCurrentPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    final passedPrayers = prayers.where((p) => p.time.isBefore(now)).toList();
    
    if (passedPrayers.isEmpty) return null;
    
    // الصلاة الأخيرة التي مر وقتها هي الصلاة الحالية
    passedPrayers.sort((a, b) => b.time.compareTo(a.time));
    return passedPrayers.first;
  }

  /// الحصول على الصلاة التالية من قائمة
  static PrayerTime? getNextPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    final upcomingPrayers = prayers.where((p) => p.time.isAfter(now)).toList();
    
    if (upcomingPrayers.isEmpty) return null;
    
    // أول صلاة قادمة
    upcomingPrayers.sort((a, b) => a.time.compareTo(b.time));
    return upcomingPrayers.first;
  }

  // ==================== النصوص ====================
  
  /// اسم الصلاة بالعربية
  static String getPrayerNameAr(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  /// رسالة التنبيه
  static String getNotificationMessage(PrayerType type, int minutesBefore) {
    final prayerName = getPrayerNameAr(type);
    
    if (minutesBefore == 0) {
      return 'حان الآن وقت صلاة $prayerName';
    } else if (minutesBefore == 1) {
      return 'بقي دقيقة واحدة على صلاة $prayerName';
    } else if (minutesBefore == 2) {
      return 'بقي دقيقتان على صلاة $prayerName';
    } else if (minutesBefore <= 10) {
      return 'بقي $minutesBefore دقائق على صلاة $prayerName';
    } else {
      return 'اقترب وقت صلاة $prayerName (بعد $minutesBefore دقيقة)';
    }
  }

  /// نص حالة الصلاة
  static String getPrayerStatusText(PrayerTime prayer) {
    if (prayer.isNext) {
      return formatRemainingTime(prayer.remainingTime);
    } else if (prayer.isPassed) {
      return 'انتهى الوقت';
    } else {
      return 'قادم';
    }
  }

  // ==================== التواريخ ====================
  
  /// التحقق من تطابق اليوم
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// اسم اليوم بالعربية
  static String getDayName(DateTime date) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[date.weekday % 7];
  }

  /// اسم الشهر بالعربية
  static String getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  // ==================== طرق الحساب ====================
  
  /// اسم طريقة الحساب
  static String getCalculationMethodName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.egyptian:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية، كراتشي';
      case CalculationMethod.ummAlQura:
        return 'أم القرى';
      case CalculationMethod.dubai:
        return 'دبي';
      case CalculationMethod.qatar:
        return 'قطر';
      case CalculationMethod.kuwait:
        return 'الكويت';
      case CalculationMethod.singapore:
        return 'سنغافورة';
      case CalculationMethod.northAmerica:
        return 'الجمعية الإسلامية لأمريكا الشمالية';
      case CalculationMethod.other:
        return 'أخرى';
    }
  }

  /// وصف طريقة الحساب
  static String getCalculationMethodDescription(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.muslimWorldLeague:
        return 'الفجر 18°، العشاء 17°';
      case CalculationMethod.egyptian:
        return 'الفجر 19.5°، العشاء 17.5°';
      case CalculationMethod.karachi:
        return 'الفجر 18°، العشاء 18°';
      case CalculationMethod.ummAlQura:
        return 'الفجر 18.5°، العشاء 90 دقيقة بعد المغرب';
      case CalculationMethod.dubai:
        return 'الفجر 18.2°، العشاء 18.2°';
      case CalculationMethod.qatar:
        return 'الفجر 18°، العشاء 90 دقيقة بعد المغرب';
      case CalculationMethod.kuwait:
        return 'الفجر 18°، العشاء 17.5°';
      case CalculationMethod.singapore:
        return 'الفجر 20°، العشاء 18°';
      case CalculationMethod.northAmerica:
        return 'الفجر 15°، العشاء 15°';
      case CalculationMethod.other:
        return 'إعدادات مخصصة';
    }
  }

  /// اسم المذهب
  static String getJuristicName(AsrJuristic juristic) {
    switch (juristic) {
      case AsrJuristic.standard:
        return 'الجمهور (الشافعي، المالكي، الحنبلي)';
      case AsrJuristic.hanafi:
        return 'الحنفي';
    }
  }
}

/// أنواع الأخطاء
enum ErrorType {
  permission,
  locationService,
  network,
  timeout,
  location,
  unknown,
}

/// Extension للسهولة
extension PrayerTimeUtils on PrayerTime {
  String get formattedTime => PrayerUtils.formatTime(time);
  String get formattedTime24 => PrayerUtils.formatTime(time, use24Hour: true);
  String get statusText => PrayerUtils.getPrayerStatusText(this);
  Color get color => PrayerUtils.getPrayerColor(type);
  IconData get icon => PrayerUtils.getPrayerIcon(type);
  LinearGradient get gradient => PrayerUtils.getPrayerGradient(type);
  bool isApproachingIn(int minutes) => PrayerUtils.isPrayerApproaching(this, minutesBefore: minutes);
}

extension DailyPrayerTimesUtils on DailyPrayerTimes {
  /// الصلوات الرئيسية فقط (بدون الشروق)
  List<PrayerTime> get mainPrayers => prayers.where((p) => p.type != PrayerType.sunrise).toList();
  
  /// نسبة التقدم في اليوم
  double get dayProgress {
    final mainList = mainPrayers;
    if (mainList.isEmpty) return 0.0;
    
    final passedCount = mainList.where((p) => p.isPassed).length;
    return (passedCount / mainList.length).clamp(0.0, 1.0);
  }
  
  /// نسبة التقدم بين الصلاة الحالية والتالية
  double get currentPrayerProgress {
    if (currentPrayer == null || nextPrayer == null) return 0.0;
    return PrayerUtils.calculateProgressBetweenPrayers(currentPrayer!, nextPrayer!);
  }
}