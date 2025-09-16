// lib/features/qibla/models/qibla_model.dart - نسخة محسنة ومبسطة
import 'dart:math' as math;

/// نموذج بيانات القبلة المبسط
class QiblaModel {
  final double latitude;
  final double longitude;
  final double qiblaDirection;
  final double accuracy;
  final double distance;
  final String? cityName;
  final String? countryName;
  final DateTime calculatedAt;

  // إحداثيات الكعبة المشرفة
  static const double kaabaLatitude = 21.4224827;
  static const double kaabaLongitude = 39.8261816;

  QiblaModel({
    required this.latitude,
    required this.longitude,
    required this.qiblaDirection,
    required this.accuracy,
    required this.distance,
    this.cityName,
    this.countryName,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  /// إنشاء نموذج من الإحداثيات
  factory QiblaModel.fromCoordinates({
    required double latitude,
    required double longitude,
    double accuracy = 0,
    String? cityName,
    String? countryName,
  }) {
    // التحقق من صحة الإحداثيات
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90 degrees');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180 degrees');
    }

    // حساب اتجاه القبلة
    final qiblaDirection = _calculateQiblaDirection(latitude, longitude);

    // حساب المسافة
    final distance = _calculateDistance(latitude, longitude);

    return QiblaModel(
      latitude: latitude,
      longitude: longitude,
      qiblaDirection: qiblaDirection,
      accuracy: accuracy,
      distance: distance,
      cityName: cityName,
      countryName: countryName,
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

  /// حساب المسافة للكعبة
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

  // ===== الخصائص المحسوبة =====

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
    return 'الشمال الغربي';
  }

  /// وصف المسافة
  String get distanceDescription {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} متر';
    } else if (distance < 100) {
      return '${distance.toStringAsFixed(1)} كم';
    } else if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} كم';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} ألف كم';
    }
  }

  /// عمر البيانات
  Duration get age => DateTime.now().difference(calculatedAt);
  
  /// هل البيانات حديثة
  bool get isFresh => age.inMinutes < 30;
  
  /// هل البيانات قديمة
  bool get isStale => age.inHours > 6;

  /// وصف عمر البيانات
  String get ageDescription {
    if (age.inMinutes < 1) return 'الآن';
    if (age.inMinutes < 60) return 'منذ ${age.inMinutes} دقيقة';
    if (age.inHours < 24) return 'منذ ${age.inHours} ساعة';
    return 'منذ ${age.inDays} يوم';
  }

  // ===== التحويل والتخزين =====

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'qiblaDirection': qiblaDirection,
      'accuracy': accuracy,
      'distance': distance,
      'cityName': cityName,
      'countryName': countryName,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    return QiblaModel(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      qiblaDirection: json['qiblaDirection']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble() ?? 0.0,
      cityName: json['cityName'],
      countryName: json['countryName'],
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'])
          : DateTime.now(),
    );
  }

  // ===== دوال مساعدة =====
  
  static double _toRadians(double degrees) => degrees * (math.pi / 180);
  static double _toDegrees(double radians) => radians * (180 / math.pi);

  @override
  String toString() {
    return 'QiblaModel(lat: ${latitude.toStringAsFixed(4)}, '
        'lng: ${longitude.toStringAsFixed(4)}, '
        'qibla: ${qiblaDirection.toStringAsFixed(1)}°, '
        'distance: ${distance.toStringAsFixed(1)} km)';
  }
}