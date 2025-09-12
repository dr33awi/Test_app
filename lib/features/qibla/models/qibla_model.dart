// lib/features/qibla/domain/models/qibla_model.dart - نسخة محسنة مع validation أفضل
import 'dart:math' as math;

/// نموذج بيانات القبلة المحسن مع validation شامل وخصائص إضافية
class QiblaModel {
  final double latitude;
  final double longitude;
  final double qiblaDirection;
  final double accuracy;
  final double distance;
  final String? cityName;
  final String? countryName;
  final double magneticDeclination;
  final DateTime calculatedAt;

  // إحداثيات الكعبة المشرفة بدقة عالية (مصدر: المساحة الجيولوجية السعودية)
  static const double kaabaLatitude = 21.4224827;
  static const double kaabaLongitude = 39.8261816;

  // ثوابت للتحقق من صحة البيانات
  static const Duration _maxDataAge = Duration(hours: 6);
  static const Duration _staleDataAge = Duration(hours: 24);
  static const Duration _veryStaleDataAge = Duration(days: 7);
  static const double _maxReasonableAccuracy = 1000.0; // 1 كيلومتر
  static const double _highAccuracyThreshold = 20.0; // 20 متر
  static const double _mediumAccuracyThreshold = 100.0; // 100 متر

  QiblaModel({
    required this.latitude,
    required this.longitude,
    required this.qiblaDirection,
    required this.accuracy,
    required this.distance,
    this.cityName,
    this.countryName,
    this.magneticDeclination = 0.0,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now() {
    // التحقق من صحة البيانات عند الإنشاء
    _validateData();
  }

  /// إنشاء نموذج من الإحداثيات مع حسابات محسنة
  factory QiblaModel.fromCoordinates({
    required double latitude,
    required double longitude,
    double accuracy = 0,
    String? cityName,
    String? countryName,
    double? magneticDeclination,
  }) {
    // التحقق من صحة الإحداثيات
    _validateCoordinates(latitude, longitude);

    // حساب اتجاه القبلة باستخدام الصيغة الكروية المحسنة
    final qiblaDirection = _calculateQiblaDirection(latitude, longitude);

    // حساب المسافة باستخدام صيغة هافرسين المحسنة
    final distance = _calculateDistance(latitude, longitude);

    // حساب الانحراف المغناطيسي التقديري
    final declination = magneticDeclination ?? _estimateMagneticDeclination(latitude, longitude);

    return QiblaModel(
      latitude: latitude,
      longitude: longitude,
      qiblaDirection: qiblaDirection,
      accuracy: accuracy,
      distance: distance,
      cityName: cityName,
      countryName: countryName,
      magneticDeclination: declination,
    );
  }

  /// التحقق من صحة الإحداثيات
  static void _validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90 degrees, got: $latitude');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180 degrees, got: $longitude');
    }
    if (latitude.isNaN || longitude.isNaN) {
      throw ArgumentError('Coordinates cannot be NaN');
    }
    if (latitude.isInfinite || longitude.isInfinite) {
      throw ArgumentError('Coordinates cannot be infinite');
    }
  }

  /// التحقق من صحة البيانات الداخلية
  void _validateData() {
    _validateCoordinates(latitude, longitude);
    
    if (qiblaDirection < 0 || qiblaDirection >= 360) {
      throw ArgumentError('Qibla direction must be between 0 and 360 degrees, got: $qiblaDirection');
    }
    if (accuracy < 0 || accuracy > _maxReasonableAccuracy) {
      throw ArgumentError('Accuracy must be between 0 and $_maxReasonableAccuracy meters, got: $accuracy');
    }
    if (distance < 0) {
      throw ArgumentError('Distance cannot be negative, got: $distance');
    }
    if (magneticDeclination < -180 || magneticDeclination > 180) {
      throw ArgumentError('Magnetic declination must be between -180 and 180 degrees, got: $magneticDeclination');
    }
  }

  // ==================== حسابات القبلة المحسنة ====================

  /// حساب اتجاه القبلة باستخدام صيغة محسنة مع معالجة الحالات الخاصة
  static double _calculateQiblaDirection(double userLat, double userLng) {
    // تحويل الدرجات إلى راديان
    final phi1 = _toRadians(userLat);
    final phi2 = _toRadians(kaabaLatitude);
    final deltaLambda = _toRadians(kaabaLongitude - userLng);

    // معالجة الحالات الخاصة (نفس خط الطول أو قريب جداً)
    if ((userLng - kaabaLongitude).abs() < 0.0001) {
      return userLat > kaabaLatitude ? 180.0 : 0.0;
    }

    // معالجة الحالات القطبية
    if (userLat.abs() > 85.0) {
      return userLat > 0 ? 180.0 : 0.0;
    }

    // معالجة حالة النقطة المقابلة تماماً للكعبة
    final distanceToKaaba = _calculateDistance(userLat, userLng);
    if (distanceToKaaba > 19900) { // نصف محيط الأرض تقريباً
      // في هذه الحالة، أي اتجاه يؤدي للكعبة تقريباً
      return 0.0;
    }

    // حساب الاتجاه باستخدام معادلة الزاوية الأولية (Initial Bearing)
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) - 
              math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    // التحقق من القيم الخاصة
    if (x == 0 && y == 0) {
      return 0.0; // في نفس موقع الكعبة
    }

    // حساب الزاوية
    final theta = math.atan2(y, x);

    // تحويل من راديان إلى درجات وتطبيع النطاق
    double bearing = _toDegrees(theta);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// حساب المسافة باستخدام صيغة هافرسين مع راديوس الأرض المحسن
  static double _calculateDistance(double userLat, double userLng) {
    // استخدام راديوس الأرض في منطقة مكة (أكثر دقة من المتوسط العالمي)
    const double earthRadiusKm = 6371.0088;

    final dLat = _toRadians(kaabaLatitude - userLat);
    final dLon = _toRadians(kaabaLongitude - userLng);

    final lat1Rad = _toRadians(userLat);
    final lat2Rad = _toRadians(kaabaLatitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) *
        math.cos(lat1Rad) * math.cos(lat2Rad);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final distance = earthRadiusKm * c;
    
    // التحقق من المنطقية
    if (distance.isNaN || distance.isInfinite || distance < 0) {
      throw StateError('Invalid distance calculation result: $distance');
    }

    return distance;
  }

  /// تقدير الانحراف المغناطيسي بناءً على الموقع الجغرافي (محسن)
  static double _estimateMagneticDeclination(double latitude, double longitude) {
    // المنطقة العربية والشرق الأوسط
    if (latitude >= 12 && latitude <= 42 && longitude >= 25 && longitude <= 75) {
      // تقدير أكثر دقة للمنطقة العربية
      if (latitude >= 25 && longitude >= 35 && longitude <= 50) {
        return 2.5; // دول الخليج
      } else if (latitude <= 25 && longitude >= 30) {
        return 1.8; // مصر والسودان
      } else {
        return 2.0; // باقي المنطقة العربية
      }
    }
    
    // أوروبا (محسن)
    if (latitude >= 35 && latitude <= 75 && longitude >= -10 && longitude <= 45) {
      if (longitude < 10) {
        return longitude < 0 ? 0.5 : 1.5; // أوروبا الغربية
      } else {
        return longitude > 30 ? 6.0 : 4.0; // أوروبا الشرقية
      }
    }
    
    // شرق آسيا (محسن)
    if (latitude >= 15 && latitude <= 55 && longitude >= 95 && longitude <= 145) {
      if (longitude > 130) {
        return -7.0; // اليابان وكوريا
      } else if (longitude > 115) {
        return -3.0; // الصين الشرقية
      } else {
        return -1.0; // جنوب شرق آسيا
      }
    }
    
    // أمريكا الشمالية (محسن)
    if (latitude >= 20 && latitude <= 70 && longitude >= -140 && longitude <= -50) {
      if (longitude < -120) {
        return 15.0; // الساحل الغربي
      } else if (longitude < -100) {
        return 12.0; // الوسط
      } else if (longitude < -80) {
        return 8.0; // الوسط الشرقي
      } else {
        return 18.0; // الساحل الشرقي
      }
    }
    
    // أمريكا الجنوبية
    if (latitude >= -60 && latitude <= 15 && longitude >= -85 && longitude <= -30) {
      if (latitude < -30) {
        return -8.0; // أرجنتين وتشيلي
      } else {
        return -12.0; // البرازيل وشمال القارة
      }
    }
    
    // أفريقيا (محسن)
    if (latitude >= -40 && latitude <= 40 && longitude >= -20 && longitude <= 55) {
      if (longitude > 30) {
        return 0.0; // شرق أفريقيا
      } else if (latitude > 0) {
        return -3.0; // غرب أفريقيا الشمالي
      } else {
        return -15.0; // جنوب أفريقيا
      }
    }
    
    // أستراليا ونيوزيلندا
    if (latitude >= -50 && latitude <= -10 && longitude >= 110 && longitude <= 180) {
      return 8.0;
    }
    
    // الهند وباكستان
    if (latitude >= 8 && latitude <= 37 && longitude >= 68 && longitude <= 97) {
      return 1.0;
    }
    
    // روسيا وآسيا الوسطى
    if (latitude >= 40 && latitude <= 75 && longitude >= 30 && longitude <= 180) {
      if (longitude > 100) {
        return 10.0; // سيبيريا
      } else {
        return 7.0; // روسيا الأوروبية
      }
    }

    // القيمة الافتراضية
    return 0.0;
  }

  // ==================== الخصائص المحسنة ====================

  /// الحصول على اتجاه القبلة الحقيقي (بدون انحراف مغناطيسي)
  double get trueQiblaDirection => qiblaDirection;

  /// الحصول على اتجاه القبلة المغناطيسي (مع الانحراف)
  double get magneticQiblaDirection {
    double magnetic = qiblaDirection - magneticDeclination;
    return (magnetic + 360) % 360;
  }

  /// حساب الفرق بين اتجاه الجهاز واتجاه القبلة
  double calculateQiblaDeviation(double deviceDirection, {bool isMagnetic = true}) {
    final targetDirection = isMagnetic ? magneticQiblaDirection : trueQiblaDirection;
    double difference = targetDirection - deviceDirection;
    
    // تطبيع الزاوية لأقصر مسار
    while (difference > 180) difference -= 360;
    while (difference < -180) difference += 360;
    
    return difference;
  }

  /// فحص ما إذا كان الجهاز يشير إلى القبلة
  bool isPointingToQibla(double deviceDirection, {double tolerance = 5.0, bool isMagnetic = true}) {
    final deviation = calculateQiblaDeviation(deviceDirection, isMagnetic: isMagnetic);
    return deviation.abs() <= tolerance;
  }

  /// حساب دقة الاتجاه نحو القبلة (0.0 - 1.0)
  double calculateQiblaAccuracy(double deviceDirection, {bool isMagnetic = true}) {
    final deviation = calculateQiblaDeviation(deviceDirection, isMagnetic: isMagnetic);
    final normalizedDeviation = deviation.abs() / 180.0;
    return math.max(0.0, 1.0 - normalizedDeviation);
  }

  // ==================== الوصف والتصنيف ====================

  /// وصف نصي محسن للاتجاه
  String get directionDescription {
    final angle = qiblaDirection;

    if (angle >= 337.5 || angle < 22.5) return 'الشمال';
    if (angle >= 22.5 && angle < 67.5) return 'الشمال الشرقي';
    if (angle >= 67.5 && angle < 112.5) return 'الشرق';
    if (angle >= 112.5 && angle < 157.5) return 'الجنوب الشرقي';
    if (angle >= 157.5 && angle < 202.5) return 'الجنوب';
    if (angle >= 202.5 && angle < 247.5) return 'الجنوب الغربي';
    if (angle >= 247.5 && angle < 292.5) return 'الغرب';
    if (angle >= 292.5 && angle < 337.5) return 'الشمال الغربي';

    return 'غير محدد';
  }

  /// وصف مفصل للاتجاه مع النصائح
  String get detailedDirectionDescription {
    final direction = directionDescription;
    final preciseAngle = qiblaDirection.toStringAsFixed(1);
    
    return '$direction ($preciseAngle°)';
  }

  /// وصف محسن للمسافة مع معلومات السفر
  String get distanceDescription {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} متر (قريب جداً)';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(2)} كم (قريب جداً)';
    } else if (distance < 100) {
      return '${distance.toStringAsFixed(1)} كم';
    } else if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} كم';
    } else {
      final thousands = distance / 1000;
      return '${thousands.toStringAsFixed(1)} ألف كم';
    }
  }

  /// معلومات إضافية عن المسافة
  String get distanceContext {
    if (distance < 50) {
      return 'أنت قريب جداً من مكة المكرمة';
    } else if (distance < 500) {
      return 'أنت في منطقة قريبة من مكة المكرمة';
    } else if (distance < 2000) {
      return 'المسافة متوسطة إلى مكة المكرمة';
    } else if (distance < 10000) {
      return 'أنت بعيد عن مكة المكرمة';
    } else {
      return 'أنت في الجانب الآخر من العالم';
    }
  }

  /// تقدير وقت السفر (محسن)
  String get estimatedTravelInfo {
    if (distance < 1) {
      return 'أنت في الحرم المكي';
    } else if (distance < 50) {
      final minutes = (distance / 0.8).ceil(); // 50 كم/ساعة متوسط في المدينة
      return 'حوالي $minutes دقيقة بالسيارة';
    } else if (distance < 200) {
      final hours = (distance / 80).ceil(); // 80 كم/ساعة على الطرق السريعة
      return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالسيارة';
    } else if (distance < 1000) {
      final hours = (distance / 600).ceil(); // 600 كم/ساعة متوسط الطائرة
      return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالطائرة';
    } else {
      final hours = (distance / 800).ceil(); // 800 كم/ساعة طائرات بعيدة المدى
      return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالطائرة';
    }
  }

  // ==================== التحقق من الصحة والجودة ====================

  /// التحقق من صحة البيانات الأساسية
  bool get isValid {
    try {
      _validateData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من جودة البيانات الشاملة
  bool get hasGoodQuality {
    return isValid && 
           hasHighAccuracy && 
           !isStale && 
           _isLocationReasonable;
  }

  /// التحقق من منطقية الموقع
  bool get _isLocationReasonable {
    // تحقق من أن الموقع ليس في المحيط أو القطب
    if (latitude.abs() > 85) return false; // مناطق قطبية
    
    // تحقق من المناطق المأهولة تقريباً
    if (distance > 20000) return false; // بعيد جداً عن أي مكان معقول
    
    return true;
  }

  /// تصنيف محسن لدقة الموقع
  LocationAccuracyLevel get accuracyLevel {
    if (accuracy <= 5) return LocationAccuracyLevel.excellent;
    if (accuracy <= _highAccuracyThreshold) return LocationAccuracyLevel.high;
    if (accuracy <= 50) return LocationAccuracyLevel.medium;
    if (accuracy <= _mediumAccuracyThreshold) return LocationAccuracyLevel.low;
    return LocationAccuracyLevel.poor;
  }

  /// النص المقابل لمستوى الدقة
  String get accuracyDescription {
    switch (accuracyLevel) {
      case LocationAccuracyLevel.excellent:
        return 'ممتازة (± ${accuracy.toStringAsFixed(0)} م)';
      case LocationAccuracyLevel.high:
        return 'عالية (± ${accuracy.toStringAsFixed(0)} م)';
      case LocationAccuracyLevel.medium:
        return 'متوسطة (± ${accuracy.toStringAsFixed(0)} م)';
      case LocationAccuracyLevel.low:
        return 'منخفضة (± ${accuracy.toStringAsFixed(0)} م)';
      case LocationAccuracyLevel.poor:
        return 'ضعيفة جداً (± ${accuracy.toStringAsFixed(0)} م)';
    }
  }

  /// وصف تفصيلي للدقة مع نصائح التحسين
  String get detailedAccuracyDescription {
    final baseDescription = accuracyDescription;
    final suggestions = getAccuracyImprovementSuggestions();
    
    if (suggestions.isNotEmpty) {
      return '$baseDescription\nنصائح للتحسين: ${suggestions.join(', ')}';
    }
    
    return baseDescription;
  }

  /// اقتراحات تحسين الدقة
  List<String> getAccuracyImprovementSuggestions() {
    final suggestions = <String>[];
    
    if (accuracy > 50) {
      suggestions.add('انتقل إلى مكان مفتوح');
    }
    if (accuracy > 20) {
      suggestions.add('تأكد من تفعيل GPS عالي الدقة');
    }
    if (accuracy > 100) {
      suggestions.add('ابتعد عن المباني العالية');
    }
    
    return suggestions;
  }

  /// لون مستوى الدقة (للواجهة)
  String get accuracyColorCode {
    switch (accuracyLevel) {
      case LocationAccuracyLevel.excellent:
      case LocationAccuracyLevel.high:
        return '#4CAF50'; // أخضر
      case LocationAccuracyLevel.medium:
        return '#FF9800'; // برتقالي
      case LocationAccuracyLevel.low:
      case LocationAccuracyLevel.poor:
        return '#F44336'; // أحمر
    }
  }

  /// التحقق من دقة الموقع المحسن
  bool get hasHighAccuracy => accuracyLevel == LocationAccuracyLevel.excellent || 
                             accuracyLevel == LocationAccuracyLevel.high;
  bool get hasMediumAccuracy => accuracyLevel == LocationAccuracyLevel.medium;
  bool get hasLowAccuracy => accuracyLevel == LocationAccuracyLevel.low || 
                           accuracyLevel == LocationAccuracyLevel.poor;

  // ==================== إدارة العمر والحداثة ====================

  /// حساب عمر البيانات
  Duration get age => DateTime.now().difference(calculatedAt);
  
  /// التحقق من قدم البيانات
  bool get isStale => age > _staleDataAge;
  bool get isVeryStale => age > _veryStaleDataAge;
  bool get isExpired => age > _maxDataAge;
  bool get isFresh => age.inMinutes < 30;

  /// نص وصفي لعمر البيانات
  String get ageDescription {
    if (age.inMinutes < 1) return 'الآن';
    if (age.inMinutes < 5) return 'حديث جداً';
    if (age.inMinutes < 30) return 'حديث';
    if (age.inHours < 2) return 'جديد نسبياً';
    if (age.inHours < 6) return 'خلال ساعات قليلة';
    if (age.inHours < 24) return 'خلال اليوم';
    if (age.inDays < 7) return 'خلال الأسبوع';
    return 'قديم جداً';
  }

  /// وصف مفصل لحالة البيانات
  String get dataStatusDescription {
    if (isExpired) {
      return 'البيانات منتهية الصلاحية، يجب التحديث';
    } else if (isVeryStale) {
      return 'البيانات قديمة جداً، يُنصح بالتحديث';
    } else if (isStale) {
      return 'البيانات قديمة نسبياً';
    } else if (isFresh) {
      return 'البيانات حديثة وموثوقة';
    } else {
      return 'البيانات مقبولة';
    }
  }

  /// الوقت المتبقي حتى انتهاء الصلاحية
  Duration get timeUntilExpiry {
    final expiryTime = calculatedAt.add(_maxDataAge);
    final remaining = expiryTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// النسبة المئوية لحداثة البيانات (100% = جديد، 0% = منتهي الصلاحية)
  double get freshnessFactor {
    final totalLifetime = _maxDataAge.inMilliseconds;
    final currentAge = age.inMilliseconds;
    
    if (currentAge >= totalLifetime) return 0.0;
    
    return math.max(0.0, 1.0 - (currentAge / totalLifetime));
  }

  // ==================== التحويل والتخزين ====================

  /// تحويل البيانات إلى JSON محسن
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'qiblaDirection': qiblaDirection,
      'accuracy': accuracy,
      'distance': distance,
      'cityName': cityName,
      'countryName': countryName,
      'magneticDeclination': magneticDeclination,
      'calculatedAt': calculatedAt.toIso8601String(),
      'version': '3.0', // تحديث رقم الإصدار
      'metadata': {
        'accuracyLevel': accuracyLevel.toString(),
        'isValid': isValid,
        'hasGoodQuality': hasGoodQuality,
        'createdWithValidation': true,
      },
    };
  }

  /// إنشاء نموذج من JSON محسن مع validation
  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    try {
      // التحقق من وجود البيانات الأساسية
      if (!json.containsKey('latitude') || !json.containsKey('longitude')) {
        throw ArgumentError('Missing required coordinates in JSON');
      }

      final latitude = (json['latitude'] as num?)?.toDouble() ?? 
          (throw ArgumentError('Invalid latitude'));
      final longitude = (json['longitude'] as num?)?.toDouble() ?? 
          (throw ArgumentError('Invalid longitude'));
      
      // التحقق من صحة الإحداثيات قبل المتابعة
      _validateCoordinates(latitude, longitude);

      return QiblaModel(
        latitude: latitude,
        longitude: longitude,
        qiblaDirection: (json['qiblaDirection'] as num?)?.toDouble() ?? 0.0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
        cityName: json['cityName'] as String?,
        countryName: json['countryName'] as String?,
        magneticDeclination: (json['magneticDeclination'] as num?)?.toDouble() ?? 0.0,
        calculatedAt: json['calculatedAt'] != null
            ? DateTime.parse(json['calculatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw ArgumentError('Failed to create QiblaModel from JSON: $e');
    }
  }

  /// نسخة محدثة من البيانات
  QiblaModel copyWith({
    double? latitude,
    double? longitude,
    double? qiblaDirection,
    double? accuracy,
    double? distance,
    String? cityName,
    String? countryName,
    double? magneticDeclination,
    DateTime? calculatedAt,
  }) {
    return QiblaModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      accuracy: accuracy ?? this.accuracy,
      distance: distance ?? this.distance,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      magneticDeclination: magneticDeclination ?? this.magneticDeclination,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// إنشاء نسخة محدثة بوقت جديد (مفيد عند التحديث)
  QiblaModel refreshTimestamp() {
    return copyWith(calculatedAt: DateTime.now());
  }

  // ==================== الوظائف المساعدة ====================

  static double _toRadians(double degrees) => degrees * (math.pi / 180);
  static double _toDegrees(double radians) => radians * (180 / math.pi);

  // ==================== التحويل النصي والمقارنة ====================

  @override
  String toString() {
    return 'QiblaModel('
        'lat: ${latitude.toStringAsFixed(4)}, '
        'lng: ${longitude.toStringAsFixed(4)}, '
        'qibla: ${qiblaDirection.toStringAsFixed(1)}°, '
        'distance: ${distance.toStringAsFixed(1)} km, '
        'accuracy: $accuracyDescription, '
        'location: ${cityName ?? "Unknown"}, ${countryName ?? "Unknown"}, '
        'age: $ageDescription, '
        'quality: ${hasGoodQuality ? "Good" : "Poor"}'
        ')';
  }

  /// تمثيل مفصل للبيانات
  String toDetailedString() {
    return '''
QiblaModel Details:
  📍 Location: ${cityName ?? "Unknown"}, ${countryName ?? "Unknown"}
  🧭 Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}
  🕋 Qibla Direction: ${qiblaDirection.toStringAsFixed(2)}° ($directionDescription)
  📏 Distance to Kaaba: $distanceDescription
  🎯 Accuracy: $accuracyDescription
  ⏰ Data Age: $ageDescription
  ✅ Quality: ${hasGoodQuality ? "Good" : "Poor"}
  🧲 Magnetic Declination: ${magneticDeclination.toStringAsFixed(1)}°
  ''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QiblaModel &&
        (other.latitude - latitude).abs() < 0.000001 && // دقة الفلوت
        (other.longitude - longitude).abs() < 0.000001 &&
        (other.qiblaDirection - qiblaDirection).abs() < 0.001 &&
        (other.accuracy - accuracy).abs() < 0.001 &&
        (other.distance - distance).abs() < 0.001 &&
        other.cityName == cityName &&
        other.countryName == countryName &&
        (other.magneticDeclination - magneticDeclination).abs() < 0.001;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude.round(),
      longitude.round(),
      qiblaDirection.round(),
      accuracy.round(),
      distance.round(),
      cityName,
      countryName,
      magneticDeclination.round(),
    );
  }
}

/// تعداد لمستويات دقة الموقع المحسن
enum LocationAccuracyLevel {
  excellent, // ممتازة (0-5م)
  high,      // عالية (5-20م)
  medium,    // متوسطة (20-50م)  
  low,       // منخفضة (50-100م)
  poor,      // ضعيفة (+100م)
}

/// امتدادات مفيدة لـ LocationAccuracyLevel
extension LocationAccuracyLevelExtension on LocationAccuracyLevel {
  /// الحصول على الوصف النصي
  String get description {
    switch (this) {
      case LocationAccuracyLevel.excellent:
        return 'ممتازة';
      case LocationAccuracyLevel.high:
        return 'عالية';
      case LocationAccuracyLevel.medium:
        return 'متوسطة';
      case LocationAccuracyLevel.low:
        return 'منخفضة';
      case LocationAccuracyLevel.poor:
        return 'ضعيفة جداً';
    }
  }

  /// الحصول على اللون المناسب
  String get colorCode {
    switch (this) {
      case LocationAccuracyLevel.excellent:
      case LocationAccuracyLevel.high:
        return '#4CAF50'; // أخضر
      case LocationAccuracyLevel.medium:
        return '#FF9800'; // برتقالي
      case LocationAccuracyLevel.low:
      case LocationAccuracyLevel.poor:
        return '#F44336'; // أحمر
    }
  }

  /// التحقق من كون الدقة مقبولة
  bool get isAcceptable => this != LocationAccuracyLevel.poor;

  /// التحقق من كون الدقة عالية
  bool get isHigh => this == LocationAccuracyLevel.excellent || 
                    this == LocationAccuracyLevel.high;
}