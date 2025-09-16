// lib/features/qibla/domain/models/qibla_model.dart - نسخة منظفة
import 'dart:math' as math;

/// نموذج بيانات القبلة
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

  // إحداثيات الكعبة المشرفة
  static const double kaabaLatitude = 21.4224827;
  static const double kaabaLongitude = 39.8261816;

  // ثوابت للتحقق من صحة البيانات
  static const Duration _maxDataAge = Duration(hours: 6);
  static const Duration _staleDataAge = Duration(hours: 24);

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
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  /// إنشاء نموذج من الإحداثيات
  factory QiblaModel.fromCoordinates({
    required double latitude,
    required double longitude,
    double accuracy = 0,
    String? cityName,
    String? countryName,
    double? magneticDeclination,
  }) {
    final qiblaDirection = _calculateQiblaDirection(latitude, longitude);
    final distance = _calculateDistance(latitude, longitude);
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

  /// حساب اتجاه القبلة
  static double _calculateQiblaDirection(double userLat, double userLng) {
    final phi1 = _toRadians(userLat);
    final phi2 = _toRadians(kaabaLatitude);
    final deltaLambda = _toRadians(kaabaLongitude - userLng);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) - 
              math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    double bearing = _toDegrees(theta);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// حساب المسافة باستخدام صيغة هافرسين
  static double _calculateDistance(double userLat, double userLng) {
    const double earthRadiusKm = 6371.0088;

    final dLat = _toRadians(kaabaLatitude - userLat);
    final dLon = _toRadians(kaabaLongitude - userLng);

    final lat1Rad = _toRadians(userLat);
    final lat2Rad = _toRadians(kaabaLatitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) *
        math.cos(lat1Rad) * math.cos(lat2Rad);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// تقدير الانحراف المغناطيسي
  static double _estimateMagneticDeclination(double latitude, double longitude) {
    // المنطقة العربية
    if (latitude >= 12 && latitude <= 42 && longitude >= 25 && longitude <= 75) {
      return 2.0;
    }
    // أوروبا
    if (latitude >= 35 && latitude <= 75 && longitude >= -10 && longitude <= 45) {
      return longitude < 10 ? 1.5 : 4.0;
    }
    // شرق آسيا
    if (latitude >= 15 && latitude <= 55 && longitude >= 95 && longitude <= 145) {
      return longitude > 130 ? -7.0 : -3.0;
    }
    // أمريكا الشمالية
    if (latitude >= 20 && latitude <= 70 && longitude >= -140 && longitude <= -50) {
      return longitude < -100 ? 12.0 : 8.0;
    }
    return 0.0;
  }

  // ==================== الخصائص ====================

  /// الاتجاه المغناطيسي
  double get magneticQiblaDirection {
    double magnetic = qiblaDirection - magneticDeclination;
    return (magnetic + 360) % 360;
  }

  /// وصف الاتجاه
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

  /// وصف المسافة
  String get distanceDescription {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} متر';
    } else if (distance < 100) {
      return '${distance.toStringAsFixed(1)} كم';
    } else {
      return '${distance.toStringAsFixed(0)} كم';
    }
  }

  /// التحقق من دقة الموقع
  bool get hasHighAccuracy => accuracy <= 20;
  bool get hasMediumAccuracy => accuracy > 20 && accuracy <= 100;
  bool get hasLowAccuracy => accuracy > 100;

  /// إدارة العمر
  Duration get age => DateTime.now().difference(calculatedAt);
  bool get isStale => age > _staleDataAge;
  bool get isFresh => age.inMinutes < 30;

  /// وصف العمر
  String get ageDescription {
    if (age.inMinutes < 1) return 'الآن';
    if (age.inMinutes < 30) return 'حديث';
    if (age.inHours < 24) return 'خلال اليوم';
    return 'قديم';
  }

  /// جودة البيانات
  bool get hasGoodQuality => hasHighAccuracy && !isStale;

  /// التحقق من صحة البيانات
  bool get isValid => 
      latitude >= -90 && latitude <= 90 &&
      longitude >= -180 && longitude <= 180 &&
      qiblaDirection >= 0 && qiblaDirection < 360 &&
      accuracy >= 0 && distance >= 0;

  /// خصائص إضافية للتوافق
  bool get isVeryStale => age > const Duration(days: 7);
  
  String get dataStatusDescription {
    if (age > const Duration(days: 7)) {
      return 'البيانات قديمة جداً، يجب التحديث';
    } else if (isStale) {
      return 'البيانات قديمة نسبياً';
    } else if (isFresh) {
      return 'البيانات حديثة وموثوقة';
    }
    return 'البيانات مقبولة';
  }

  double get freshnessFactor {
    final totalLifetime = _maxDataAge.inMilliseconds;
    final currentAge = age.inMilliseconds;
    if (currentAge >= totalLifetime) return 0.0;
    return math.max(0.0, 100.0 - (currentAge / totalLifetime * 100));
  }

  String get accuracyLevel {
    if (accuracy <= 5) return 'ممتازة';
    if (accuracy <= 20) return 'عالية';
    if (accuracy <= 50) return 'متوسطة';
    if (accuracy <= 100) return 'منخفضة';
    return 'ضعيفة';
  }

  String get detailedAccuracyDescription {
    return 'الدقة: ± ${accuracy.toStringAsFixed(0)} متر ($accuracyLevel)';
  }

  double get trueQiblaDirection => qiblaDirection;

  String get detailedDirectionDescription {
    return '$directionDescription (${qiblaDirection.toStringAsFixed(1)}°)';
  }

  String get distanceContext {
    if (distance < 50) {
      return 'أنت قريب جداً من مكة المكرمة';
    } else if (distance < 500) {
      return 'أنت في منطقة قريبة من مكة';
    } else if (distance < 2000) {
      return 'المسافة متوسطة إلى مكة';
    } else if (distance < 10000) {
      return 'أنت بعيد عن مكة المكرمة';
    }
    return 'أنت في الجانب الآخر من العالم';
  }

  String get estimatedTravelInfo {
    if (distance < 1) {
      return 'أنت في الحرم المكي';
    } else if (distance < 50) {
      final minutes = (distance / 0.8).ceil();
      return 'حوالي $minutes دقيقة بالسيارة';
    } else if (distance < 200) {
      final hours = (distance / 80).ceil();
      return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالسيارة';
    } else if (distance < 1000) {
      final hours = (distance / 600).ceil();
      return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالطائرة';
    }
    final hours = (distance / 800).ceil();
    return 'حوالي $hours ${hours == 1 ? 'ساعة' : 'ساعات'} بالطائرة';
  }

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

  // ==================== التحويل ====================

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
    };
  }

  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    return QiblaModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
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
  }

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

  static double _toRadians(double degrees) => degrees * (math.pi / 180);
  static double _toDegrees(double radians) => radians * (180 / math.pi);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QiblaModel &&
        (other.latitude - latitude).abs() < 0.000001 &&
        (other.longitude - longitude).abs() < 0.000001 &&
        (other.qiblaDirection - qiblaDirection).abs() < 0.001 &&
        other.cityName == cityName &&
        other.countryName == countryName;
  }

  @override
  int get hashCode => Object.hash(
    latitude.round(),
    longitude.round(),
    qiblaDirection.round(),
    cityName,
    countryName,
  );
}