// lib/features/qibla/services/qibla_service.dart - نسخة منظفة
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../models/qibla_model.dart';

/// خدمة القبلة
class QiblaService extends ChangeNotifier {
  final StorageService _storage;
  final PermissionService _permissionService;

  // مفاتيح التخزين
  static const String _qiblaDataKey = 'qibla_data';
  static const String _calibrationDataKey = 'compass_calibration';

  // حالة الخدمة
  QiblaModel? _qiblaData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  // البوصلة
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentDirection = 0.0;
  double _smoothDirection = 0.0;
  bool _hasCompass = false;
  double _compassAccuracy = 0.0;

  // معايرة
  bool _isCalibrated = false;
  bool _isCalibrating = false;
  final List<double> _calibrationReadings = [];

  // تصفية القراءات
  static const int _filterSize = 10;
  final List<double> _directionHistory = [];

  QiblaService({
    required StorageService storage,
    required PermissionService permissionService,
  })  : _storage = storage,
        _permissionService = permissionService {
    _init();
  }

  // ==================== الخصائص العامة ====================

  QiblaModel? get qiblaData => _qiblaData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get currentDirection => _smoothDirection;
  bool get hasCompass => _hasCompass;
  double get compassAccuracy => _compassAccuracy;
  bool get isCalibrated => _isCalibrated;
  bool get isCalibrating => _isCalibrating;
  bool get isDisposed => _disposed;

  double get accuracyPercentage => _hasCompass ? math.min(_compassAccuracy * 100, 100) : 0;
  bool get hasRecentData => _qiblaData != null && !_qiblaData!.isStale;
  bool get needsCalibration => _hasCompass && (!_isCalibrated || _compassAccuracy < 0.5);

  Map<String, dynamic> getDiagnostics() => {
    'hasCompass': _hasCompass,
    'isCalibrated': _isCalibrated,
    'compassAccuracy': _compassAccuracy,
    'currentDirection': _currentDirection,
    'smoothDirection': _smoothDirection,
  };

  // ==================== التهيئة ====================

  Future<void> _init() async {
    if (_disposed) return;

    try {
      debugPrint('[QiblaService] بدء تهيئة خدمة القبلة');
      
      await _loadCalibrationData();
      await _checkCompassAvailability();

      if (_hasCompass) {
        await _startCompassListener();
      }

      await _loadStoredQiblaData();
      
      debugPrint('[QiblaService] تمت التهيئة بنجاح');
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التهيئة';
      debugPrint('[QiblaService] خطأ في التهيئة: $e');
    }
  }

  Future<void> _checkCompassAvailability() async {
    try {
      final compassEvents = await FlutterCompass.events
          ?.timeout(const Duration(seconds: 3))
          .take(3)
          .toList();

      if (compassEvents != null && compassEvents.isNotEmpty) {
        _hasCompass = compassEvents.any((event) => event.heading != null);
        if (_hasCompass && compassEvents.last.accuracy != null) {
          _compassAccuracy = _calculateAccuracy(compassEvents.last.accuracy!);
        }
      }
    } catch (e) {
      _hasCompass = false;
      debugPrint('[QiblaService] خطأ في التحقق من البوصلة');
    }
  }

  Future<void> _startCompassListener() async {
    if (!_hasCompass || _disposed) return;

    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (!_disposed && event.heading != null) {
          _processCompassReading(event);
        }
      },
      onError: (error) {
        debugPrint('[QiblaService] خطأ في قراءة البوصلة');
      },
    );
  }

  void _processCompassReading(CompassEvent event) {
    if (_disposed) return;

    _currentDirection = event.heading!;
    
    if (event.accuracy != null) {
      _compassAccuracy = _calculateAccuracy(event.accuracy!);
    }

    _directionHistory.add(_currentDirection);
    if (_directionHistory.length > _filterSize) {
      _directionHistory.removeAt(0);
    }

    _smoothDirection = _applySmoothing(_directionHistory);

    if (_isCalibrating) {
      _calibrationReadings.add(_currentDirection);
    }

    notifyListeners();
  }

  // ==================== تحديث البيانات ====================

  Future<void> updateQiblaData({bool forceUpdate = false}) async {
    if (_disposed || _isLoading) return;

    if (!forceUpdate && hasRecentData && _qiblaData!.hasHighAccuracy) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[QiblaService] بدء تحديث بيانات القبلة');

      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('لم يتم منح إذن الوصول إلى الموقع');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 25),
      );

      String? cityName;
      String? countryName;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        ).timeout(const Duration(seconds: 10));

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          cityName = placemark.locality ?? placemark.administrativeArea;
          countryName = placemark.country;
        }
      } catch (e) {
        debugPrint('[QiblaService] لم يتم الحصول على معلومات الموقع');
      }

      _qiblaData = QiblaModel.fromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        cityName: cityName,
        countryName: countryName,
      );

      await _saveQiblaData(_qiblaData!);
      
      debugPrint('[QiblaService] تم تحديث بيانات القبلة بنجاح');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('[QiblaService] خطأ في تحديث البيانات: $e');
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> forceUpdate() => updateQiblaData(forceUpdate: true);

  // ==================== المعايرة ====================

  Future<void> startCalibration() async {
    if (_disposed || !_hasCompass || _isCalibrating) return;

    _isCalibrating = true;
    _isCalibrated = false;
    _calibrationReadings.clear();
    
    debugPrint('[QiblaService] بدء عملية معايرة البوصلة');
    notifyListeners();

    Timer(const Duration(seconds: 15), () {
      if (!_disposed) {
        _completeCalibration();
      }
    });
  }

  void _completeCalibration() {
    if (_disposed) return;

    _isCalibrating = false;

    if (_calibrationReadings.length >= 30) {
      final stdDev = _calculateStandardDeviation(_calibrationReadings);
      _isCalibrated = stdDev < 15;
      
      if (_isCalibrated) {
        _compassAccuracy = math.max(_compassAccuracy, 0.8);
        debugPrint('[QiblaService] تمت المعايرة بنجاح');
      }
    }

    _saveCalibrationData();
    notifyListeners();
  }

  void resetCalibration() {
    if (_disposed) return;
    
    _isCalibrating = false;
    _isCalibrated = false;
    _calibrationReadings.clear();
    _compassAccuracy = 0.0;
    
    _saveCalibrationData();
    notifyListeners();
  }

  // ==================== التخزين ====================

  Future<void> _loadStoredQiblaData() async {
    try {
      final qiblaJson = _storage.getMap(_qiblaDataKey);
      if (qiblaJson != null && qiblaJson.isNotEmpty) {
        _qiblaData = QiblaModel.fromJson(qiblaJson);
        debugPrint('[QiblaService] تم تحميل بيانات القبلة المخزنة');
      }
    } catch (e) {
      debugPrint('[QiblaService] خطأ في تحميل البيانات المخزنة');
    }
  }

  Future<void> _saveQiblaData(QiblaModel data) async {
    try {
      await _storage.setMap(_qiblaDataKey, data.toJson());
    } catch (e) {
      debugPrint('[QiblaService] خطأ في حفظ البيانات');
    }
  }

  Future<void> _loadCalibrationData() async {
    try {
      final data = _storage.getMap(_calibrationDataKey);
      if (data != null) {
        _isCalibrated = data['isCalibrated'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('[QiblaService] خطأ في تحميل بيانات المعايرة');
    }
  }

  Future<void> _saveCalibrationData() async {
    try {
      await _storage.setMap(_calibrationDataKey, {
        'isCalibrated': _isCalibrated,
        'lastCalibration': DateTime.now().toIso8601String(),
        'accuracy': _compassAccuracy,
      });
    } catch (e) {
      debugPrint('[QiblaService] خطأ في حفظ بيانات المعايرة');
    }
  }

  // ==================== الوظائف المساعدة ====================

  double _applySmoothing(List<double> readings) {
    if (readings.isEmpty) return 0;

    final sines = readings.map((angle) => math.sin(angle * math.pi / 180)).toList();
    final cosines = readings.map((angle) => math.cos(angle * math.pi / 180)).toList();

    final avgSin = sines.reduce((a, b) => a + b) / readings.length;
    final avgCos = cosines.reduce((a, b) => a + b) / readings.length;

    double angle = math.atan2(avgSin, avgCos) * 180 / math.pi;
    return (angle + 360) % 360;
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    
    return math.sqrt(variance);
  }

  double _calculateAccuracy(double rawAccuracy) {
    if (rawAccuracy < 0) return 1.0;
    if (rawAccuracy > 180) return 0.0;
    return 1.0 - (rawAccuracy / 180.0);
  }

  Future<bool> _checkLocationPermission() async {
    try {
      final status = await _permissionService.checkPermissionStatus(
        AppPermissionType.location,
      );

      if (status != AppPermissionStatus.granted) {
        final result = await _permissionService.requestPermission(
          AppPermissionType.location,
        );
        return result == AppPermissionStatus.granted;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'انتهت مهلة الحصول على الموقع';
    } else if (error is LocationServiceDisabledException) {
      return 'خدمة الموقع معطلة';
    } else if (error is PermissionDeniedException) {
      return 'لم يتم منح إذن الوصول';
    }
    return 'حدث خطأ غير متوقع';
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    debugPrint('[QiblaService] بدء تنظيف موارد الخدمة');
    
    _compassSubscription?.cancel();
    _directionHistory.clear();
    _calibrationReadings.clear();

    super.dispose();
  }
}