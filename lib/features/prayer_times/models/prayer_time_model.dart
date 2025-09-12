// lib/features/prayer_times/models/prayer_time_model_fixed.dart

import 'package:flutter/foundation.dart';

/// نموذج وقت الصلاة المحسن
@immutable
class PrayerTime {
  final String id;
  final String nameAr;
  final String nameEn;
  final DateTime time;
  final DateTime? adhanTime;
  final DateTime? iqamaTime;
  final bool isNext;
  final bool isPassed;
  final PrayerType type;

  const PrayerTime({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.time,
    this.adhanTime,
    this.iqamaTime,
    this.isNext = false,
    this.isPassed = false,
    required this.type,
  }) : assert(id != '', 'Prayer ID cannot be empty'),
       assert(nameAr != '', 'Arabic name cannot be empty'),
       assert(nameEn != '', 'English name cannot be empty');

  /// الحصول على الوقت المتبقي
  Duration get remainingTime {
    final now = DateTime.now();
    if (time.isAfter(now)) {
      return time.difference(now);
    }
    return Duration.zero;
  }

  /// التحقق من اقتراب الوقت (قبل 15 دقيقة)
  bool get isApproaching {
    final remaining = remainingTime;
    return remaining.inMinutes <= 15 && remaining.inMinutes > 0;
  }

  /// الحصول على نص الوقت المتبقي
  String get remainingTimeText {
    final duration = remainingTime;
    if (duration.inMinutes == 0) return 'حان الآن';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return 'بعد $hours ساعة و$minutes دقيقة';
    } else {
      return 'بعد $minutes دقيقة';
    }
  }

  /// نسخ مع تعديل
  PrayerTime copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    DateTime? time,
    DateTime? adhanTime,
    DateTime? iqamaTime,
    bool? isNext,
    bool? isPassed,
    PrayerType? type,
  }) {
    return PrayerTime(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      time: time ?? this.time,
      adhanTime: adhanTime ?? this.adhanTime,
      iqamaTime: iqamaTime ?? this.iqamaTime,
      isNext: isNext ?? this.isNext,
      isPassed: isPassed ?? this.isPassed,
      type: type ?? this.type,
    );
  }

  /// تحويل إلى JSON مع validation
  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'time': time.toIso8601String(),
        'adhanTime': adhanTime?.toIso8601String(),
        'iqamaTime': iqamaTime?.toIso8601String(),
        'isNext': isNext,
        'isPassed': isPassed,
        'type': type.index,
      };
    } catch (e) {
      throw FormatException('Failed to serialize PrayerTime: $e');
    }
  }

  /// إنشاء من JSON مع validation
  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      final id = json['id'] as String?;
      final nameAr = json['nameAr'] as String?;
      final nameEn = json['nameEn'] as String?;
      final timeStr = json['time'] as String?;
      final typeIndex = json['type'] as int?;

      if (id == null || id.isEmpty) {
        throw FormatException('Missing or empty id');
      }
      if (nameAr == null || nameAr.isEmpty) {
        throw FormatException('Missing or empty nameAr');
      }
      if (nameEn == null || nameEn.isEmpty) {
        throw FormatException('Missing or empty nameEn');
      }
      if (timeStr == null) {
        throw FormatException('Missing time');
      }
      if (typeIndex == null || typeIndex < 0 || typeIndex >= PrayerType.values.length) {
        throw FormatException('Invalid type index: $typeIndex');
      }

      return PrayerTime(
        id: id,
        nameAr: nameAr,
        nameEn: nameEn,
        time: DateTime.parse(timeStr),
        adhanTime: json['adhanTime'] != null ? DateTime.parse(json['adhanTime']) : null,
        iqamaTime: json['iqamaTime'] != null ? DateTime.parse(json['iqamaTime']) : null,
        isNext: json['isNext'] ?? false,
        isPassed: json['isPassed'] ?? false,
        type: PrayerType.values[typeIndex],
      );
    } catch (e) {
      throw FormatException('Failed to deserialize PrayerTime: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTime &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameAr == other.nameAr &&
          nameEn == other.nameEn &&
          time == other.time &&
          adhanTime == other.adhanTime &&
          iqamaTime == other.iqamaTime &&
          isNext == other.isNext &&
          isPassed == other.isPassed &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      nameAr.hashCode ^
      nameEn.hashCode ^
      time.hashCode ^
      adhanTime.hashCode ^
      iqamaTime.hashCode ^
      isNext.hashCode ^
      isPassed.hashCode ^
      type.hashCode;

  @override
  String toString() {
    return 'PrayerTime{id: $id, nameAr: $nameAr, time: $time, type: $type, isNext: $isNext, isPassed: $isPassed}';
  }
}

/// أنواع الصلوات
enum PrayerType {
  fajr('fajr', 'الفجر', 'Fajr'),
  sunrise('sunrise', 'الشروق', 'Sunrise'),
  dhuhr('dhuhr', 'الظهر', 'Dhuhr'),
  asr('asr', 'العصر', 'Asr'),
  maghrib('maghrib', 'المغرب', 'Maghrib'),
  isha('isha', 'العشاء', 'Isha'),
  midnight('midnight', 'منتصف الليل', 'Midnight'),
  lastThird('lastThird', 'الثلث الأخير', 'Last Third');

  const PrayerType(this.key, this.nameAr, this.nameEn);

  final String key;
  final String nameAr;
  final String nameEn;

  /// Get prayer type from string key
  static PrayerType? fromKey(String key) {
    for (final type in PrayerType.values) {
      if (type.key == key) return type;
    }
    return null;
  }
}

/// طرق الحساب
enum CalculationMethod {
  muslimWorldLeague(
    'muslim_world_league',
    'رابطة العالم الإسلامي',
    'الفجر 18°، العشاء 17°',
    18.0,
    17.0,
  ),
  egyptian(
    'egyptian',
    'الهيئة المصرية العامة للمساحة',
    'الفجر 19.5°، العشاء 17.5°',
    19.5,
    17.5,
  ),
  karachi(
    'karachi',
    'جامعة العلوم الإسلامية، كراتشي',
    'الفجر 18°، العشاء 18°',
    18.0,
    18.0,
  ),
  ummAlQura(
    'umm_al_qura',
    'أم القرى',
    'الفجر 18.5°، العشاء 90 دقيقة بعد المغرب',
    18.5,
    null,
  ),
  dubai(
    'dubai',
    'دبي',
    'الفجر 18.2°، العشاء 18.2°',
    18.2,
    18.2,
  ),
  qatar(
    'qatar',
    'قطر',
    'الفجر 18°، العشاء 90 دقيقة بعد المغرب',
    18.0,
    null,
  ),
  kuwait(
    'kuwait',
    'الكويت',
    'الفجر 18°، العشاء 17.5°',
    18.0,
    17.5,
  ),
  singapore(
    'singapore',
    'سنغافورة',
    'الفجر 20°، العشاء 18°',
    20.0,
    18.0,
  ),
  northAmerica(
    'north_america',
    'الجمعية الإسلامية لأمريكا الشمالية',
    'الفجر 15°، العشاء 15°',
    15.0,
    15.0,
  ),
  other(
    'other',
    'أخرى',
    'مخصص',
    18.0,
    17.0,
  );

  const CalculationMethod(
    this.key,
    this.nameAr,
    this.description,
    this.fajrAngle,
    this.ishaAngle,
  );

  final String key;
  final String nameAr;
  final String description;
  final double fajrAngle;
  final double? ishaAngle;

  /// Get method from string key
  static CalculationMethod? fromKey(String key) {
    for (final method in CalculationMethod.values) {
      if (method.key == key) return method;
    }
    return null;
  }
}

/// المذهب الفقهي
enum AsrJuristic {
  standard('standard', 'الجمهور', 'الشافعي، المالكي، الحنبلي'),
  hanafi('hanafi', 'الحنفي', 'المذهب الحنفي');

  const AsrJuristic(this.key, this.name, this.description);

  final String key;
  final String name;
  final String description;

  /// Get juristic from string key
  static AsrJuristic? fromKey(String key) {
    for (final juristic in AsrJuristic.values) {
      if (juristic.key == key) return juristic;
    }
    return null;
  }
}

/// إعدادات حساب مواقيت الصلاة المحسنة
@immutable
class PrayerCalculationSettings {
  final CalculationMethod method;
  final AsrJuristic asrJuristic;
  final int fajrAngle;
  final int ishaAngle;
  final int maghribAngle;
  final bool summerTimeAdjustment;
  final Map<String, int> manualAdjustments;

  const PrayerCalculationSettings({
    this.method = CalculationMethod.ummAlQura,
    this.asrJuristic = AsrJuristic.standard,
    this.fajrAngle = 18,
    this.ishaAngle = 17,
    this.maghribAngle = 0,
    this.summerTimeAdjustment = false,
    this.manualAdjustments = const {},
  }) : assert(fajrAngle >= 0 && fajrAngle <= 30, 'Fajr angle must be between 0 and 30'),
       assert(ishaAngle >= 0 && ishaAngle <= 30, 'Isha angle must be between 0 and 30'),
       assert(maghribAngle >= -10 && maghribAngle <= 10, 'Maghrib angle must be between -10 and 10');

  /// نسخ مع تعديل
  PrayerCalculationSettings copyWith({
    CalculationMethod? method,
    AsrJuristic? asrJuristic,
    int? fajrAngle,
    int? ishaAngle,
    int? maghribAngle,
    bool? summerTimeAdjustment,
    Map<String, int>? manualAdjustments,
  }) {
    return PrayerCalculationSettings(
      method: method ?? this.method,
      asrJuristic: asrJuristic ?? this.asrJuristic,
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      maghribAngle: maghribAngle ?? this.maghribAngle,
      summerTimeAdjustment: summerTimeAdjustment ?? this.summerTimeAdjustment,
      manualAdjustments: manualAdjustments ?? Map.from(this.manualAdjustments),
    );
  }

  /// تحويل إلى JSON مع validation
  Map<String, dynamic> toJson() {
    try {
      // Validate adjustments
      for (final entry in manualAdjustments.entries) {
        if (entry.value < -60 || entry.value > 60) {
          throw FormatException('Manual adjustment out of range: ${entry.key}=${entry.value}');
        }
      }

      return {
        'method': method.key,
        'asrJuristic': asrJuristic.key,
        'fajrAngle': fajrAngle,
        'ishaAngle': ishaAngle,
        'maghribAngle': maghribAngle,
        'summerTimeAdjustment': summerTimeAdjustment,
        'manualAdjustments': manualAdjustments,
      };
    } catch (e) {
      throw FormatException('Failed to serialize PrayerCalculationSettings: $e');
    }
  }

  /// إنشاء من JSON مع validation
  factory PrayerCalculationSettings.fromJson(Map<String, dynamic> json) {
    try {
      final methodKey = json['method'] as String?;
      final juristicKey = json['asrJuristic'] as String?;

      final method = methodKey != null 
          ? CalculationMethod.fromKey(methodKey) ?? CalculationMethod.ummAlQura
          : CalculationMethod.ummAlQura;

      final juristic = juristicKey != null
          ? AsrJuristic.fromKey(juristicKey) ?? AsrJuristic.standard
          : AsrJuristic.standard;

      final fajrAngle = (json['fajrAngle'] as int?) ?? 18;
      final ishaAngle = (json['ishaAngle'] as int?) ?? 17;
      final maghribAngle = (json['maghribAngle'] as int?) ?? 0;

      // Validate angles
      if (fajrAngle < 0 || fajrAngle > 30) {
        throw FormatException('Invalid fajr angle: $fajrAngle');
      }
      if (ishaAngle < 0 || ishaAngle > 30) {
        throw FormatException('Invalid isha angle: $ishaAngle');
      }
      if (maghribAngle < -10 || maghribAngle > 10) {
        throw FormatException('Invalid maghrib angle: $maghribAngle');
      }

      // Validate manual adjustments
      final adjustments = Map<String, int>.from(json['manualAdjustments'] ?? {});
      for (final entry in adjustments.entries) {
        if (entry.value < -60 || entry.value > 60) {
          throw FormatException('Invalid manual adjustment: ${entry.key}=${entry.value}');
        }
      }

      return PrayerCalculationSettings(
        method: method,
        asrJuristic: juristic,
        fajrAngle: fajrAngle,
        ishaAngle: ishaAngle,
        maghribAngle: maghribAngle,
        summerTimeAdjustment: json['summerTimeAdjustment'] ?? false,
        manualAdjustments: adjustments,
      );
    } catch (e) {
      throw FormatException('Failed to deserialize PrayerCalculationSettings: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerCalculationSettings &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          asrJuristic == other.asrJuristic &&
          fajrAngle == other.fajrAngle &&
          ishaAngle == other.ishaAngle &&
          maghribAngle == other.maghribAngle &&
          summerTimeAdjustment == other.summerTimeAdjustment &&
          mapEquals(manualAdjustments, other.manualAdjustments);

  @override
  int get hashCode =>
      method.hashCode ^
      asrJuristic.hashCode ^
      fajrAngle.hashCode ^
      ishaAngle.hashCode ^
      maghribAngle.hashCode ^
      summerTimeAdjustment.hashCode ^
      Object.hashAll(manualAdjustments.entries);
}

/// بيانات الموقع للصلاة المحسنة
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
  }) : assert(latitude >= -90 && latitude <= 90, 'Latitude must be between -90 and 90'),
       assert(longitude >= -180 && longitude <= 180, 'Longitude must be between -180 and 180'),
       assert(timezone != '', 'Timezone cannot be empty');

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'cityName': cityName,
    'countryName': countryName,
    'timezone': timezone,
    'altitude': altitude,
  };

  /// إنشاء من JSON مع validation
  factory PrayerLocation.fromJson(Map<String, dynamic> json) {
    try {
      final lat = (json['latitude'] as num?)?.toDouble();
      final lng = (json['longitude'] as num?)?.toDouble();
      final tz = json['timezone'] as String?;

      if (lat == null) {
        throw FormatException('Missing latitude');
      }
      if (lng == null) {
        throw FormatException('Missing longitude');
      }
      if (tz == null || tz.isEmpty) {
        throw FormatException('Missing or empty timezone');
      }

      if (lat < -90 || lat > 90) {
        throw FormatException('Invalid latitude: $lat');
      }
      if (lng < -180 || lng > 180) {
        throw FormatException('Invalid longitude: $lng');
      }

      return PrayerLocation(
        latitude: lat,
        longitude: lng,
        cityName: json['cityName'] as String?,
        countryName: json['countryName'] as String?,
        timezone: tz,
        altitude: (json['altitude'] as num?)?.toDouble(),
      );
    } catch (e) {
      throw FormatException('Failed to deserialize PrayerLocation: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          cityName == other.cityName &&
          countryName == other.countryName &&
          timezone == other.timezone &&
          altitude == other.altitude;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      cityName.hashCode ^
      countryName.hashCode ^
      timezone.hashCode ^
      altitude.hashCode;

  @override
  String toString() {
    return 'PrayerLocation{lat: $latitude, lng: $longitude, city: $cityName, timezone: $timezone}';
  }
}

/// حالة مواقيت الصلاة اليومية المحسنة
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
  }) : assert(prayers.length > 0, 'Prayers list cannot be empty');

  /// الحصول على الصلاة التالية
  PrayerTime? get nextPrayer {
    try {
      return prayers.firstWhere((prayer) => prayer.isNext);
    } catch (_) {
      return null;
    }
  }

  /// الحصول على الصلاة الحالية (آخر صلاة مرت)
  PrayerTime? get currentPrayer {
    final passedPrayers = prayers.where((p) => p.isPassed).toList();
    if (passedPrayers.isEmpty) return null;
    
    // Sort by time and get the latest
    passedPrayers.sort((a, b) => b.time.compareTo(a.time));
    return passedPrayers.first;
  }

  /// تحديث حالات الصلوات
  DailyPrayerTimes updatePrayerStates() {
    final now = DateTime.now();
    final updatedPrayers = <PrayerTime>[];
    
    PrayerTime? nextPrayer;
    
    // Sort prayers by time to ensure correct order
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

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    try {
      return {
        'date': date.toIso8601String(),
        'prayers': prayers.map((p) => p.toJson()).toList(),
        'location': location.toJson(),
        'settings': settings.toJson(),
      };
    } catch (e) {
      throw FormatException('Failed to serialize DailyPrayerTimes: $e');
    }
  }

  /// إنشاء من JSON مع validation
  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    try {
      final dateStr = json['date'] as String?;
      final prayersJson = json['prayers'] as List?;
      final locationJson = json['location'] as Map<String, dynamic>?;
      final settingsJson = json['settings'] as Map<String, dynamic>?;

      if (dateStr == null) {
        throw FormatException('Missing date');
      }
      if (prayersJson == null || prayersJson.isEmpty) {
        throw FormatException('Missing or empty prayers');
      }
      if (locationJson == null) {
        throw FormatException('Missing location');
      }
      if (settingsJson == null) {
        throw FormatException('Missing settings');
      }

      final prayers = prayersJson
          .map((p) => PrayerTime.fromJson(p as Map<String, dynamic>))
          .toList();

      if (prayers.isEmpty) {
        throw FormatException('No valid prayers found');
      }

      return DailyPrayerTimes(
        date: DateTime.parse(dateStr),
        prayers: prayers,
        location: PrayerLocation.fromJson(locationJson),
        settings: PrayerCalculationSettings.fromJson(settingsJson),
      );
    } catch (e) {
      throw FormatException('Failed to deserialize DailyPrayerTimes: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPrayerTimes &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          listEquals(prayers, other.prayers) &&
          location == other.location &&
          settings == other.settings;

  @override
  int get hashCode =>
      date.hashCode ^
      Object.hashAll(prayers) ^
      location.hashCode ^
      settings.hashCode;

  @override
  String toString() {
    return 'DailyPrayerTimes{date: $date, prayers: ${prayers.length}, location: $location}';
  }
}

/// إعدادات تنبيهات الصلاة المحسنة
@immutable
class PrayerNotificationSettings {
  final bool enabled;
  final Map<PrayerType, bool> enabledPrayers;
  final Map<PrayerType, int> minutesBefore;
  final bool playAdhan;
  final String adhanSound;
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
    this.playAdhan = false,
    this.adhanSound = 'default',
    this.vibrate = true,
  });

  /// نسخ مع تعديل
  PrayerNotificationSettings copyWith({
    bool? enabled,
    Map<PrayerType, bool>? enabledPrayers,
    Map<PrayerType, int>? minutesBefore,
    bool? playAdhan,
    String? adhanSound,
    bool? vibrate,
  }) {
    return PrayerNotificationSettings(
      enabled: enabled ?? this.enabled,
      enabledPrayers: enabledPrayers ?? Map.from(this.enabledPrayers),
      minutesBefore: minutesBefore ?? Map.from(this.minutesBefore),
      playAdhan: playAdhan ?? this.playAdhan,
      adhanSound: adhanSound ?? this.adhanSound,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  /// تحويل إلى JSON مع validation
  Map<String, dynamic> toJson() {
    try {
      // Validate minutes before
      for (final entry in minutesBefore.entries) {
        if (entry.value < 0 || entry.value > 120) {
          throw FormatException('Invalid minutes before for ${entry.key}: ${entry.value}');
        }
      }

      // Validate adhan sound
      const validSounds = ['default', 'makkah', 'madinah', 'none'];
      if (!validSounds.contains(adhanSound)) {
        throw FormatException('Invalid adhan sound: $adhanSound');
      }

      return {
        'enabled': enabled,
        'enabledPrayers': enabledPrayers.map((k, v) => MapEntry(k.key, v)),
        'minutesBefore': minutesBefore.map((k, v) => MapEntry(k.key, v)),
        'playAdhan': playAdhan,
        'adhanSound': adhanSound,
        'vibrate': vibrate,
      };
    } catch (e) {
      throw FormatException('Failed to serialize PrayerNotificationSettings: $e');
    }
  }

  /// إنشاء من JSON مع validation
  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    try {
      final enabledPrayersMap = json['enabledPrayers'] as Map<String, dynamic>?;
      final minutesBeforeMap = json['minutesBefore'] as Map<String, dynamic>?;
      final adhanSound = json['adhanSound'] as String? ?? 'default';

      // Validate adhan sound
      const validSounds = ['default', 'makkah', 'madinah', 'none'];
      if (!validSounds.contains(adhanSound)) {
        throw FormatException('Invalid adhan sound: $adhanSound');
      }

      // Parse enabled prayers
      final enabledPrayers = <PrayerType, bool>{};
      if (enabledPrayersMap != null) {
        for (final entry in enabledPrayersMap.entries) {
          final type = PrayerType.fromKey(entry.key);
          if (type != null) {
            enabledPrayers[type] = entry.value as bool? ?? false;
          }
        }
      }

      // Parse minutes before
      final minutesBefore = <PrayerType, int>{};
      if (minutesBeforeMap != null) {
        for (final entry in minutesBeforeMap.entries) {
          final type = PrayerType.fromKey(entry.key);
          if (type != null) {
            final minutes = entry.value as int? ?? 0;
            if (minutes < 0 || minutes > 120) {
              throw FormatException('Invalid minutes before for $type: $minutes');
            }
            minutesBefore[type] = minutes;
          }
        }
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
        playAdhan: json['playAdhan'] ?? false,
        adhanSound: adhanSound,
        vibrate: json['vibrate'] ?? true,
      );
    } catch (e) {
      throw FormatException('Failed to deserialize PrayerNotificationSettings: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerNotificationSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          mapEquals(enabledPrayers, other.enabledPrayers) &&
          mapEquals(minutesBefore, other.minutesBefore) &&
          playAdhan == other.playAdhan &&
          adhanSound == other.adhanSound &&
          vibrate == other.vibrate;

  @override
  int get hashCode =>
      enabled.hashCode ^
      Object.hashAll(enabledPrayers.entries) ^
      Object.hashAll(minutesBefore.entries) ^
      playAdhan.hashCode ^
      adhanSound.hashCode ^
      vibrate.hashCode;

  @override
  String toString() {
    return 'PrayerNotificationSettings{enabled: $enabled, enabledCount: ${enabledPrayers.values.where((v) => v).length}}';
  }
}

/// Result wrapper for prayer operations
@immutable
sealed class PrayerResult<T> {
  const PrayerResult();
}

class PrayerSuccess<T> extends PrayerResult<T> {
  final T data;
  
  const PrayerSuccess(this.data);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

class PrayerError<T> extends PrayerResult<T> {
  final String message;
  final String? code;
  final dynamic originalError;
  final bool canRetry;
  
  const PrayerError({
    required this.message,
    this.code,
    this.originalError,
    this.canRetry = true,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerError<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          canRetry == other.canRetry;

  @override
  int get hashCode => message.hashCode ^ code.hashCode ^ canRetry.hashCode;
}

/// Extension for working with PrayerResult
extension PrayerResultExtension<T> on PrayerResult<T> {
  /// Check if result is success
  bool get isSuccess => this is PrayerSuccess<T>;
  
  /// Check if result is error
  bool get isError => this is PrayerError<T>;
  
  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
    PrayerSuccess<T> success => success.data,
    PrayerError<T> _ => null,
  };
  
  /// Get error if error, null otherwise
  PrayerError<T>? get errorOrNull => switch (this) {
    PrayerError<T> error => error,
    PrayerSuccess<T> _ => null,
  };
  
  /// Fold result into a single value
  R fold<R>(
    R Function(PrayerError<T>) onError,
    R Function(T) onSuccess,
  ) {
    return switch (this) {
      PrayerError<T> error => onError(error),
      PrayerSuccess<T> success => onSuccess(success.data),
    };
  }
  
  /// Map success value to another type
  PrayerResult<R> map<R>(R Function(T) transform) {
    return switch (this) {
      PrayerError<T> error => PrayerError<R>(
          message: error.message,
          code: error.code,
          originalError: error.originalError,
          canRetry: error.canRetry,
        ),
      PrayerSuccess<T> success => PrayerSuccess<R>(transform(success.data)),
    };
  }
}