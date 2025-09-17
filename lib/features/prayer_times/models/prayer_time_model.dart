// lib/features/prayer_times/models/prayer_time_model.dart

import 'package:flutter/foundation.dart';

/// نموذج وقت الصلاة المنظف
@immutable
class PrayerTime {
  final String id;
  final String nameAr;
  final String nameEn;
  final DateTime time;
  final bool isNext;
  final bool isPassed;
  final PrayerType type;

  const PrayerTime({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.time,
    this.isNext = false,
    this.isPassed = false,
    required this.type,
  });

  /// الوقت المتبقي
  Duration get remainingTime {
    final now = DateTime.now();
    if (time.isAfter(now)) {
      return time.difference(now);
    }
    return Duration.zero;
  }

  /// التحقق من اقتراب الوقت
  bool get isApproaching {
    final remaining = remainingTime;
    return remaining.inMinutes <= 15 && remaining.inMinutes > 0;
  }

  /// نسخ مع تعديل
  PrayerTime copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    DateTime? time,
    bool? isNext,
    bool? isPassed,
    PrayerType? type,
  }) {
    return PrayerTime(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
      isPassed: isPassed ?? this.isPassed,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'time': time.toIso8601String(),
    'isNext': isNext,
    'isPassed': isPassed,
    'type': type.index,
  };

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      time: DateTime.parse(json['time'] as String),
      isNext: json['isNext'] ?? false,
      isPassed: json['isPassed'] ?? false,
      type: PrayerType.values[json['type'] as int],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTime &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time;

  @override
  int get hashCode => id.hashCode ^ time.hashCode;
}

/// أنواع الصلوات (المستخدمة فقط)
enum PrayerType {
  fajr('fajr', 'الفجر', 'Fajr'),
  sunrise('sunrise', 'الشروق', 'Sunrise'),
  dhuhr('dhuhr', 'الظهر', 'Dhuhr'),
  asr('asr', 'العصر', 'Asr'),
  maghrib('maghrib', 'المغرب', 'Maghrib'),
  isha('isha', 'العشاء', 'Isha');

  const PrayerType(this.key, this.nameAr, this.nameEn);

  final String key;
  final String nameAr;
  final String nameEn;
  
  // للتوافق مع الكود الموجود
  String get name => key;

  static PrayerType? fromKey(String key) {
    for (final type in PrayerType.values) {
      if (type.key == key) return type;
    }
    return null;
  }
}

/// طرق الحساب
enum CalculationMethod {
  muslimWorldLeague('muslim_world_league', 18.0, 17.0),
  egyptian('egyptian', 19.5, 17.5),
  karachi('karachi', 18.0, 18.0),
  ummAlQura('umm_al_qura', 18.5, null),
  dubai('dubai', 18.2, 18.2),
  qatar('qatar', 18.0, null),
  kuwait('kuwait', 18.0, 17.5),
  singapore('singapore', 20.0, 18.0),
  northAmerica('north_america', 15.0, 15.0),
  other('other', 18.0, 17.0);

  const CalculationMethod(this.key, this.fajrAngle, this.ishaAngle);

  final String key;
  final double fajrAngle;
  final double? ishaAngle;

  static CalculationMethod? fromKey(String key) {
    for (final method in CalculationMethod.values) {
      if (method.key == key) return method;
    }
    return null;
  }
}

/// المذهب الفقهي
enum AsrJuristic {
  standard('standard'),
  hanafi('hanafi');

  const AsrJuristic(this.key);
  final String key;

  static AsrJuristic? fromKey(String key) {
    for (final juristic in AsrJuristic.values) {
      if (juristic.key == key) return juristic;
    }
    return null;
  }
}

/// إعدادات حساب مواقيت الصلاة
@immutable
class PrayerCalculationSettings {
  final CalculationMethod method;
  final AsrJuristic asrJuristic;
  final int fajrAngle;
  final int ishaAngle;
  final Map<String, int> manualAdjustments;

  const PrayerCalculationSettings({
    this.method = CalculationMethod.ummAlQura,
    this.asrJuristic = AsrJuristic.standard,
    this.fajrAngle = 18,
    this.ishaAngle = 17,
    this.manualAdjustments = const {},
  });

  PrayerCalculationSettings copyWith({
    CalculationMethod? method,
    AsrJuristic? asrJuristic,
    int? fajrAngle,
    int? ishaAngle,
    Map<String, int>? manualAdjustments,
  }) {
    return PrayerCalculationSettings(
      method: method ?? this.method,
      asrJuristic: asrJuristic ?? this.asrJuristic,
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      manualAdjustments: manualAdjustments ?? Map.from(this.manualAdjustments),
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method.key,
    'asrJuristic': asrJuristic.key,
    'fajrAngle': fajrAngle,
    'ishaAngle': ishaAngle,
    'manualAdjustments': manualAdjustments,
  };

  factory PrayerCalculationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerCalculationSettings(
      method: CalculationMethod.fromKey(json['method']) ?? CalculationMethod.ummAlQura,
      asrJuristic: AsrJuristic.fromKey(json['asrJuristic']) ?? AsrJuristic.standard,
      fajrAngle: json['fajrAngle'] ?? 18,
      ishaAngle: json['ishaAngle'] ?? 17,
      manualAdjustments: Map<String, int>.from(json['manualAdjustments'] ?? {}),
    );
  }
}

/// بيانات الموقع للصلاة
@immutable
class PrayerLocation {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;
  final String timezone;
  final double? altitude;

  const PrayerLocation({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
    required this.timezone,
    this.altitude,
  });

  String get displayName {
    if (cityName != null && countryName != null) {
      return '$cityName، $countryName';
    } else if (cityName != null) {
      return cityName!;
    } else if (countryName != null) {
      return countryName!;
    } else {
      return 'موقع غير محدد';
    }
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'cityName': cityName,
    'countryName': countryName,
    'timezone': timezone,
    'altitude': altitude,
  };

  factory PrayerLocation.fromJson(Map<String, dynamic> json) {
    return PrayerLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String?,
      countryName: json['countryName'] as String?,
      timezone: json['timezone'] as String,
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    );
  }
}

/// حالة مواقيت الصلاة اليومية
@immutable
class DailyPrayerTimes {
  final DateTime date;
  final List<PrayerTime> prayers;
  final PrayerLocation location;
  final PrayerCalculationSettings settings;

  const DailyPrayerTimes({
    required this.date,
    required this.prayers,
    required this.location,
    required this.settings,
  });

  /// الصلاة التالية
  PrayerTime? get nextPrayer {
    try {
      return prayers.firstWhere((prayer) => prayer.isNext);
    } catch (_) {
      return null;
    }
  }

  /// الصلاة الحالية
  PrayerTime? get currentPrayer {
    final passedPrayers = prayers.where((p) => p.isPassed).toList();
    if (passedPrayers.isEmpty) return null;
    
    passedPrayers.sort((a, b) => b.time.compareTo(a.time));
    return passedPrayers.first;
  }

  /// تحديث حالات الصلوات
  DailyPrayerTimes updatePrayerStates() {
    final now = DateTime.now();
    final updatedPrayers = <PrayerTime>[];
    
    PrayerTime? nextPrayer;
    
    final sortedPrayers = List<PrayerTime>.from(prayers);
    sortedPrayers.sort((a, b) => a.time.compareTo(b.time));
    
    for (final prayer in sortedPrayers) {
      final isPassed = prayer.time.isBefore(now);
      final isNext = nextPrayer == null && !isPassed;
      
      if (isNext) nextPrayer = prayer;
      
      updatedPrayers.add(prayer.copyWith(
        isPassed: isPassed,
        isNext: isNext,
      ));
    }
    
    return DailyPrayerTimes(
      date: date,
      prayers: updatedPrayers,
      location: location,
      settings: settings,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'prayers': prayers.map((p) => p.toJson()).toList(),
    'location': location.toJson(),
    'settings': settings.toJson(),
  };

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: DateTime.parse(json['date'] as String),
      prayers: (json['prayers'] as List)
          .map((p) => PrayerTime.fromJson(p as Map<String, dynamic>))
          .toList(),
      location: PrayerLocation.fromJson(json['location'] as Map<String, dynamic>),
      settings: PrayerCalculationSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }
}

/// إعدادات تنبيهات الصلاة
@immutable
class PrayerNotificationSettings {
  final bool enabled;
  final Map<PrayerType, bool> enabledPrayers;
  final Map<PrayerType, int> minutesBefore;
  final bool vibrate;

  const PrayerNotificationSettings({
    this.enabled = true,
    this.enabledPrayers = const {
      PrayerType.fajr: true,
      PrayerType.dhuhr: true,
      PrayerType.asr: true,
      PrayerType.maghrib: true,
      PrayerType.isha: true,
    },
    this.minutesBefore = const {
      PrayerType.fajr: 15,
      PrayerType.dhuhr: 10,
      PrayerType.asr: 10,
      PrayerType.maghrib: 5,
      PrayerType.isha: 10,
    },
    this.vibrate = true,
  });

  PrayerNotificationSettings copyWith({
    bool? enabled,
    Map<PrayerType, bool>? enabledPrayers,
    Map<PrayerType, int>? minutesBefore,
    bool? vibrate,
  }) {
    return PrayerNotificationSettings(
      enabled: enabled ?? this.enabled,
      enabledPrayers: enabledPrayers ?? Map.from(this.enabledPrayers),
      minutesBefore: minutesBefore ?? Map.from(this.minutesBefore),
      vibrate: vibrate ?? this.vibrate,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'enabledPrayers': enabledPrayers.map((k, v) => MapEntry(k.key, v)),
    'minutesBefore': minutesBefore.map((k, v) => MapEntry(k.key, v)),
    'vibrate': vibrate,
  };

  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    final enabledPrayers = <PrayerType, bool>{};
    final minutesBefore = <PrayerType, int>{};
    
    if (json['enabledPrayers'] != null) {
      (json['enabledPrayers'] as Map<String, dynamic>).forEach((key, value) {
        final type = PrayerType.fromKey(key);
        if (type != null) {
          enabledPrayers[type] = value as bool;
        }
      });
    }
    
    if (json['minutesBefore'] != null) {
      (json['minutesBefore'] as Map<String, dynamic>).forEach((key, value) {
        final type = PrayerType.fromKey(key);
        if (type != null) {
          minutesBefore[type] = value as int;
        }
      });
    }
    
    return PrayerNotificationSettings(
      enabled: json['enabled'] ?? true,
      enabledPrayers: enabledPrayers.isNotEmpty ? enabledPrayers : const {
        PrayerType.fajr: true,
        PrayerType.dhuhr: true,
        PrayerType.asr: true,
        PrayerType.maghrib: true,
        PrayerType.isha: true,
      },
      minutesBefore: minutesBefore.isNotEmpty ? minutesBefore : const {
        PrayerType.fajr: 15,
        PrayerType.dhuhr: 10,
        PrayerType.asr: 10,
        PrayerType.maghrib: 5,
        PrayerType.isha: 10,
      },
      vibrate: json['vibrate'] ?? true,
    );
  }
}