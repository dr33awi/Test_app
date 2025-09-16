// lib/features/qibla/services/qibla_service.dart - نسخة محسنة
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../models/qibla_model.dart';

/// Cancellation Token لإلغاء العمليات المُعلقة
class CancelToken {
  bool _isCancelled = false;
  String? _reason;

  bool get isCancelled => _isCancelled;
  String? get reason => _reason;

  void cancel([String? reason]) {
    _isCancelled = true;
    _reason = reason ?? 'Operation cancelled';
  }
}

/// خدمة القبلة المحسنة مع إدارة أفضل للعمليات والذاكرة
class QiblaService extends ChangeNotifier {
  final LoggerService _logger;
  final StorageService _storage;
  final PermissionService _permissionService;

  // مفاتيح التخزين
  static const String _qiblaDataKey = 'qibla_data';
  static const String _lastUpdateKey = 'qibla_last_update';
  static const String _calibrationDataKey = 'compass_calibration';

  // حالة الخدمة
  QiblaModel? _qiblaData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  // إدارة العمليات المُعلقة
  CancelToken? _currentUpdateToken;
  Timer? _dataValidationTimer;
  Timer? _calibrationTimer;

  // البوصلة والحساسات
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  double _currentDirection = 0.0;
  double _filteredDirection = 0.0;
  bool _hasCompass = false;
  double _compassAccuracy = 0.0;

  // معايرة البوصلة
  double _magneticDeclination = 0.0;
  bool _isCalibrated = false;
  bool _isCalibrating = false;
  final List<double> _calibrationReadings = [];

  // تصفية القراءات
  static const int _filterSize = 10;
  final List<double> _directionHistory = [];
  final List<double> _magnetometerReadings = [];

  // معدل التحديث والإحصائيات
  DateTime? _lastCompassUpdate;
  DateTime? _lastSuccessfulUpdate;
  int _updateAttempts = 0;
  int _successfulUpdates = 0;
  static const Duration _updateThreshold = Duration(milliseconds: 100);
  static const Duration _dataExpiryDuration = Duration(hours: 6);

  QiblaService({
    required LoggerService logger,
    required StorageService storage,
    required PermissionService permissionService,
  })  : _logger = logger,
        _storage = storage,
        _permissionService = permissionService {
    _init();
  }

  // ==================== الخصائص العامة ====================

  QiblaModel? get qiblaData => _qiblaData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get currentDirection => _filteredDirection;
  bool get hasCompass => _hasCompass;
  double get compassAccuracy => _compassAccuracy;
  bool get isCalibrated => _isCalibrated;
  bool get isCalibrating => _isCalibrating;
  bool get isDisposed => _disposed;

  // اتجاه القبلة بالنسبة للاتجاه الحالي
  double get qiblaAngle {
    if (_qiblaData == null) return 0;
    final adjustedQiblaDirection = (_qiblaData!.qiblaDirection + _magneticDeclination + 360) % 360;
    return (adjustedQiblaDirection - _filteredDirection + 360) % 360;
  }

  // دقة البوصلة كنسبة مئوية
  double get accuracyPercentage {
    if (!_hasCompass) return 0;
    return math.min(_compassAccuracy * 100, 100);
  }

  // إحصائيات الخدمة
  bool get hasRecentData => _qiblaData != null && !_qiblaData!.isStale;
  bool get needsCalibration => _hasCompass && (!_isCalibrated || _compassAccuracy < 0.5);
  double get dataFreshness => _qiblaData?.age.inMinutes.toDouble() ?? double.infinity;
  
  Map<String, dynamic> get serviceStats => {
    'hasCompass': _hasCompass,
    'isCalibrated': _isCalibrated,
    'compassAccuracy': _compassAccuracy,
    'updateAttempts': _updateAttempts,
    'successfulUpdates': _successfulUpdates,
    'successRate': _updateAttempts > 0 ? (_successfulUpdates / _updateAttempts * 100) : 0,
    'lastUpdate': _lastSuccessfulUpdate?.toIso8601String(),
    'dataAge': _qiblaData?.age.inMinutes,
    'needsCalibration': needsCalibration,
  };

  // ==================== التهيئة الأولية ====================

  /// التهيئة الأولية للخدمة
  Future<void> _init() async {
    if (_disposed) return;

    try {
      _logger.info(
        message: '[QiblaService] بدء تهيئة خدمة القبلة',
      );

      // تحميل بيانات المعايرة المحفوظة
      await _loadCalibrationData();

      // التحقق من توفر البوصلة
      await _checkCompassAvailability();

      if (_hasCompass) {
        await _startSensorListeners();
        _logger.info(message: '[QiblaService] تم تشغيل الحساسات بنجاح');
      } else {
        _logger.warning(message: '[QiblaService] البوصلة غير متوفرة على هذا الجهاز');
      }

      // محاولة استرجاع بيانات القبلة المخزنة
      await _loadStoredQiblaData();

      // بدء مراقبة صلاحية البيانات
      _startDataValidationTimer();

      _logger.info(
        message: '[QiblaService] تمت التهيئة بنجاح',
      );
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تهيئة خدمة القبلة';
      _logger.error(
        message: '[QiblaService] خطأ في التهيئة',
        error: e,
      );
    }
  }

  /// التحقق من توفر البوصلة بشكل أكثر دقة
  Future<void> _checkCompassAvailability() async {
    try {
      // محاولة الحصول على قراءات من البوصلة
      final compassEvents = await FlutterCompass.events
          ?.timeout(const Duration(seconds: 3))
          .take(3)
          .toList();

      if (compassEvents != null && compassEvents.isNotEmpty) {
        _hasCompass = compassEvents.any((event) => event.heading != null);

        if (_hasCompass && compassEvents.last.accuracy != null) {
          _compassAccuracy = _calculateAccuracy(compassEvents.last.accuracy!);
        }

        _logger.info(
          message: '[QiblaService] فحص البوصلة مكتمل',
        );
      } else {
        _hasCompass = false;
        _logger.warning(message: '[QiblaService] لم يتم تلقي أحداث من البوصلة');
      }
    } catch (e) {
      _hasCompass = false;
      _logger.error(
        message: '[QiblaService] خطأ في التحقق من البوصلة',
      );
    }
  }

  // ==================== إدارة الحساسات ====================

  /// بدء الاستماع للحساسات المختلفة
  Future<void> _startSensorListeners() async {
    if (!_hasCompass || _disposed) return;

    try {
      // الاستماع للبوصلة
      _compassSubscription = FlutterCompass.events?.listen(
        (event) {
          if (!_disposed && event.heading != null) {
            _processCompassReading(event);
          }
        },
        onError: (error) {
          _logger.error(
            message: '[QiblaService] خطأ في قراءة البوصلة',
          );
        },
      );

      // الاستماع لمقياس التسارع
      _accelerometerSubscription = accelerometerEventStream().listen(
        (event) {
          if (!_disposed) {
            _processAccelerometerReading(event);
          }
        },
        onError: (error) {
          _logger.error(
            message: '[QiblaService] خطأ في مقياس التسارع',
          );
        },
      );

      // الاستماع للمغناطيسية
      _magnetometerSubscription = magnetometerEventStream().listen(
        (event) {
          if (!_disposed) {
            _processMagnetometerReading(event);
          }
        },
        onError: (error) {
          _logger.error(
            message: '[QiblaService] خطأ في المغناطيسية',
          );
        },
      );
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في بدء الحساسات',
      );
    }
  }

  /// معالجة قراءة البوصلة مع التصفية المتقدمة
  void _processCompassReading(CompassEvent event) {
    if (_disposed) return;

    final now = DateTime.now();

    // تقليل معدل التحديث لتوفير البطارية
    if (_lastCompassUpdate != null &&
        now.difference(_lastCompassUpdate!) < _updateThreshold) {
      return;
    }

    _lastCompassUpdate = now;
    _currentDirection = event.heading!;

    // حساب الدقة
    if (event.accuracy != null) {
      _compassAccuracy = _calculateAccuracy(event.accuracy!);
    }

    // إضافة القراءة للسجل
    _directionHistory.add(_currentDirection);
    if (_directionHistory.length > _filterSize) {
      _directionHistory.removeAt(0);
    }

    // تطبيق مرشح متوسط متحرك مع أوزان
    _filteredDirection = _applyWeightedMovingAverage(_directionHistory);

    // إضافة قراءات المعايرة إذا كانت جارية
    if (_isCalibrating) {
      _calibrationReadings.add(_currentDirection);
    }

    // تحديث واجهة المستخدم
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// معالجة قراءات مقياس التسارع
  void _processAccelerometerReading(AccelerometerEvent event) {
    if (_disposed) return;

    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    // إذا كان الجهاز يتحرك بشدة، قلل من الثقة في القراءات
    if ((magnitude - 9.8).abs() > 2.0) {
      _compassAccuracy = math.max(0.1, _compassAccuracy * 0.9);
    }
  }

  /// معالجة قراءات المغناطيسية
  void _processMagnetometerReading(MagnetometerEvent event) {
    if (_disposed) return;

    final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
    _magnetometerReadings.add(magnitude);
    if (_magnetometerReadings.length > 20) {
      _magnetometerReadings.removeAt(0);
    }

    // كشف التشويش المغناطيسي
    if (_magnetometerReadings.length >= 20) {
      final stdDev = _calculateStandardDeviation(_magnetometerReadings);
      if (stdDev > 50) {
        _compassAccuracy = math.max(0.1, _compassAccuracy * 0.8);
      }
    }
  }

  // ==================== تحديث البيانات ====================

  /// تحديث بيانات القبلة مع إدارة محسنة للعمليات
  Future<void> updateQiblaData({bool forceUpdate = false}) async {
    if (_disposed) {
      _logger.warning(message: '[QiblaService] محاولة تحديث بعد dispose');
      return;
    }

    // إلغاء العملية السابقة إن وُجدت
    _currentUpdateToken?.cancel('New update requested');
    _currentUpdateToken = CancelToken();
    final token = _currentUpdateToken!;

    _updateAttempts++;

    // تحقق من الحاجة للتحديث
    if (!forceUpdate && _isLoading) {
      _logger.info(message: '[QiblaService] عملية تحديث جارية بالفعل');
      return;
    }

    if (!forceUpdate && hasRecentData && _qiblaData!.hasHighAccuracy) {
      _logger.info(
        message: '[QiblaService] البيانات الحالية حديثة ودقيقة',
        data: {'dataAge': _qiblaData!.age.inMinutes},
      );
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    
    if (!_disposed) {
      notifyListeners();
    }

    try {
      _logger.info(
        message: '[QiblaService] بدء تحديث بيانات القبلة',
        data: {
          'forceUpdate': forceUpdate,
          'attempt': _updateAttempts,
          'hasExistingData': _qiblaData != null,
        },
      );

      // التحقق من الإلغاء
      if (token.isCancelled) return;

      // التحقق من أذونات الموقع
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('لم يتم منح إذن الوصول إلى الموقع');
      }

      // التحقق من الإلغاء
      if (token.isCancelled) return;

      // الحصول على الموقع الحالي
      final position = await _getCurrentPosition(token);
      if (token.isCancelled) return;

      // الحصول على اسم المدينة والدولة
      String? cityName;
      String? countryName;

      try {
        final locationInfo = await _getLocationInfo(position.latitude, position.longitude, token);
        if (!token.isCancelled) {
          cityName = locationInfo['city'];
          countryName = locationInfo['country'];
        }
      } catch (e) {
        _logger.error(
          message: '[QiblaService] لم يتم الحصول على معلومات الموقع',
          error: e,
        );
      }

      if (token.isCancelled) return;

      // حساب اتجاه القبلة
      final qiblaModel = QiblaModel.fromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        cityName: cityName,
        countryName: countryName,
        magneticDeclination: _magneticDeclination,
      );

      if (token.isCancelled) return;

      // حفظ البيانات
      _qiblaData = qiblaModel;
      _lastSuccessfulUpdate = DateTime.now();
      _successfulUpdates++;
      
      await _saveQiblaData(qiblaModel);

      _logger.info(
        message: '[QiblaService] تم تحديث بيانات القبلة بنجاح',
      );
    } catch (e, stackTrace) {
      if (!token.isCancelled) {
        _errorMessage = _getErrorMessage(e);
        _logger.error(
          message: '[QiblaService] خطأ في تحديث بيانات القبلة',
          error: e,
        );
      }
    } finally {
      if (!token.isCancelled && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// الحصول على الموقع الحالي مع معالجة الإلغاء
  Future<Position> _getCurrentPosition(CancelToken token) async {
    final completer = Completer<Position>();
    Timer? timeoutTimer;

    // إعداد timeout
    timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('انتهت مهلة الحصول على الموقع'));
      }
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 25),
      );

      if (!token.isCancelled && !completer.isCompleted) {
        completer.complete(position);
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    } finally {
      timeoutTimer?.cancel();
    }

    return completer.future;
  }

  /// الحصول على معلومات الموقع (المدينة والدولة)
  Future<Map<String, String?>> _getLocationInfo(
    double latitude, 
    double longitude, 
    CancelToken token
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 10));

      if (token.isCancelled) return {};

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return {
          'city': placemark.locality ??
                  placemark.subAdministrativeArea ??
                  placemark.administrativeArea,
          'country': placemark.country,
        };
      }
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في الحصول على معلومات الموقع',
        error: e,
      );
    }

    return {'city': null, 'country': null};
  }

  // ==================== إدارة البيانات المخزنة ====================

  /// تحميل بيانات القبلة المخزنة مع التحقق من الصلاحية
  Future<void> _loadStoredQiblaData() async {
    try {
      final qiblaJson = _storage.getMap(_qiblaDataKey);
      final lastUpdateStr = _storage.getString(_lastUpdateKey);

      if (qiblaJson != null && qiblaJson.isNotEmpty) {
        final storedData = QiblaModel.fromJson(qiblaJson);
        
        // التحقق من صلاحية البيانات
        if (_isDataValid(storedData, lastUpdateStr)) {
          _qiblaData = storedData;
          _lastSuccessfulUpdate = lastUpdateStr != null 
              ? DateTime.tryParse(lastUpdateStr) 
              : storedData.calculatedAt;

          _logger.info(
            message: '[QiblaService] تم تحميل بيانات القبلة المخزنة',
            data: {
              'direction': _qiblaData?.qiblaDirection,
              'distance': _qiblaData?.distance,
              'cityName': _qiblaData?.cityName,
              'age': _qiblaData?.age.inMinutes,
              'accuracy': _qiblaData?.accuracy,
            },
          );
        } else {
          // البيانات قديمة أو غير صالحة
          await _clearStoredData();
          _logger.info(message: '[QiblaService] تم حذف البيانات القديمة');
        }
      }
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في تحميل بيانات القبلة المخزنة',
      );
      // في حالة الخطأ، احذف البيانات المعطوبة
      await _clearStoredData();
    }
  }

  /// التحقق من صلاحية البيانات المخزنة
  bool _isDataValid(QiblaModel data, String? lastUpdateStr) {
    // التحقق من صحة البيانات الأساسية
    if (!data.isValid) return false;

    // التحقق من عمر البيانات
    DateTime lastUpdate;
    if (lastUpdateStr != null) {
      lastUpdate = DateTime.tryParse(lastUpdateStr) ?? data.calculatedAt;
    } else {
      lastUpdate = data.calculatedAt;
    }

    final age = DateTime.now().difference(lastUpdate);
    if (age > _dataExpiryDuration) return false;

    // التحقق من دقة البيانات
    if (data.accuracy > 100) return false; // دقة منخفضة جداً

    return true;
  }

  /// حفظ بيانات القبلة
  Future<void> _saveQiblaData(QiblaModel qiblaModel) async {
    try {
      await _storage.setMap(_qiblaDataKey, qiblaModel.toJson());
      await _storage.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
      _logger.debug(
        message: '[QiblaService] تم حفظ بيانات القبلة',
      );
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في حفظ بيانات القبلة',
      );
    }
  }

  /// حذف البيانات المخزنة
  Future<void> _clearStoredData() async {
    try {
      await _storage.remove(_qiblaDataKey);
      await _storage.remove(_lastUpdateKey);
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في حذف البيانات المخزنة',
      );
    }
  }

  // ==================== مراقبة صلاحية البيانات ====================

  /// بدء مراقبة صلاحية البيانات
  void _startDataValidationTimer() {
    _dataValidationTimer?.cancel();
    _dataValidationTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        _checkDataFreshness();
      },
    );
  }

  /// فحص حداثة البيانات
  void _checkDataFreshness() {
    if (_disposed || _qiblaData == null) return;

    if (_qiblaData!.isVeryStale) {
      _logger.info(
        message: '[QiblaService] البيانات قديمة جداً، يُنصح بالتحديث',
        data: {'dataAge': _qiblaData!.age.inHours},
      );
      
      // إشعار المستمعين أن البيانات قديمة
      notifyListeners();
    }
  }

  // ==================== معايرة البوصلة ====================

  /// بدء عملية المعايرة
  Future<void> startCalibration() async {
    if (_disposed || !_hasCompass || _isCalibrating) return;

    _isCalibrating = true;
    _isCalibrated = false;
    _calibrationReadings.clear();
    
    _logger.info(message: '[QiblaService] بدء عملية معايرة البوصلة');
    
    if (!_disposed) {
      notifyListeners();
    }

    // إعداد مؤقت المعايرة
    _calibrationTimer = Timer(const Duration(seconds: 15), () {
      if (!_disposed) {
        _completeCalibration();
      }
    });
  }

  /// إكمال المعايرة
  void _completeCalibration() {
    if (_disposed) return;

    _calibrationTimer?.cancel();
    _isCalibrating = false;

    if (_calibrationReadings.length >= 30) {
      // تحليل قراءات المعايرة
      final standardDeviation = _calculateStandardDeviation(_calibrationReadings);
      _isCalibrated = standardDeviation < 15; // معيار الاستقرار

      if (_isCalibrated) {
        _compassAccuracy = math.max(_compassAccuracy, 0.8);
        _logger.info(
          message: '[QiblaService] تمت المعايرة بنجاح',
        );
      } else {
        _logger.warning(
          message: '[QiblaService] فشلت المعايرة - عدم استقرار القراءات',
        );
      }
    } else {
      _logger.warning(
        message: '[QiblaService] فشلت المعايرة - قراءات غير كافية',
      );
    }

    _saveCalibrationData();
    
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// إعادة تعيين المعايرة
  void resetCalibration() {
    if (_disposed) return;

    _calibrationTimer?.cancel();
    _isCalibrating = false;
    _isCalibrated = false;
    _magneticDeclination = 0;
    _calibrationReadings.clear();
    _compassAccuracy = 0.0;
    
    _saveCalibrationData();
    
    _logger.info(message: '[QiblaService] تم إعادة تعيين المعايرة');
    
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// تحميل بيانات المعايرة
  Future<void> _loadCalibrationData() async {
    try {
      final calibrationData = _storage.getMap(_calibrationDataKey);
      if (calibrationData != null) {
        _magneticDeclination = (calibrationData['declination'] as num?)?.toDouble() ?? 0.0;
        _isCalibrated = calibrationData['isCalibrated'] as bool? ?? false;
        
        // التحقق من عمر المعايرة
        final lastCalibrationStr = calibrationData['lastCalibration'] as String?;
        if (lastCalibrationStr != null) {
          final lastCalibration = DateTime.tryParse(lastCalibrationStr);
          if (lastCalibration != null) {
            final age = DateTime.now().difference(lastCalibration);
            if (age.inDays > 30) {
              // المعايرة قديمة جداً
              _isCalibrated = false;
              _logger.info(message: '[QiblaService] المعايرة قديمة، يُنصح بمعايرة جديدة');
            }
          }
        }
      }
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في تحميل بيانات المعايرة',
      );
    }
  }

  /// حفظ بيانات المعايرة
  Future<void> _saveCalibrationData() async {
    try {
      await _storage.setMap(_calibrationDataKey, {
        'declination': _magneticDeclination,
        'isCalibrated': _isCalibrated,
        'lastCalibration': DateTime.now().toIso8601String(),
        'accuracy': _compassAccuracy,
      });
    } catch (e) {
      _logger.error(
        message: '[QiblaService] خطأ في حفظ بيانات المعايرة',
      );
    }
  }

  // ==================== الوظائف المساعدة ====================

  /// تطبيق مرشح متوسط متحرك موزون
  double _applyWeightedMovingAverage(List<double> readings) {
    if (readings.isEmpty) return 0;

    final sines = readings.map((angle) => math.sin(angle * math.pi / 180)).toList();
    final cosines = readings.map((angle) => math.cos(angle * math.pi / 180)).toList();

    final weights = List.generate(readings.length, (i) => i + 1.0);
    final totalWeight = weights.reduce((a, b) => a + b);

    double weightedSinSum = 0;
    double weightedCosSum = 0;

    for (int i = 0; i < readings.length; i++) {
      weightedSinSum += sines[i] * weights[i] / totalWeight;
      weightedCosSum += cosines[i] * weights[i] / totalWeight;
    }

    double filteredAngle = math.atan2(weightedSinSum, weightedCosSum) * 180 / math.pi;
    return (filteredAngle + 360) % 360;
  }

  /// حساب الانحراف المعياري
  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;

    return math.sqrt(variance);
  }

  /// حساب دقة البوصلة
  double _calculateAccuracy(double rawAccuracy) {
    if (rawAccuracy < 0) return 1.0;
    if (rawAccuracy > 180) return 0.0;
    return 1.0 - (rawAccuracy / 180.0);
  }

  /// التحقق من أذونات الموقع
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
      _logger.error(
        message: '[QiblaService] خطأ في التحقق من أذونات الموقع',
      );
      return false;
    }
  }

  /// الحصول على رسالة خطأ مفهومة
  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'انتهت مهلة الحصول على الموقع. تأكد من تفعيل GPS';
    } else if (error is LocationServiceDisabledException) {
      return 'خدمة الموقع معطلة. يرجى تفعيل GPS';
    } else if (error is PermissionDeniedException) {
      return 'لم يتم منح إذن الوصول إلى الموقع';
    } else if (error.toString().contains('location')) {
      return 'خطأ في تحديد الموقع. تحقق من إعدادات GPS';
    } else if (error.toString().contains('network')) {
      return 'خطأ في الاتصال بالشبكة';
    } else {
      return 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً';
    }
  }

  // ==================== إدارة دورة الحياة ====================

  /// تنظيف الموارد عند التخلص من الخدمة
  @override
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;

    _logger.info(
      message: '[QiblaService] بدء تنظيف موارد الخدمة',
    );

    // إلغاء العمليات المُعلقة
    _currentUpdateToken?.cancel('Service disposing');

    // إلغاء المؤقتات
    _dataValidationTimer?.cancel();
    _calibrationTimer?.cancel();

    // إلغاء اشتراكات الحساسات
    _compassSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();

    // تنظيف البيانات
    _directionHistory.clear();
    _magnetometerReadings.clear();
    _calibrationReadings.clear();

    _logger.info(message: '[QiblaService] تم تنظيف الموارد بنجاح');

    super.dispose();
  }

  // ==================== الوظائف الإضافية ====================

  /// تحديث الموقع (alias لـ updateQiblaData)
  Future<void> updateLocation() => updateQiblaData();

  /// فرض تحديث البيانات
  Future<void> forceUpdate() => updateQiblaData(forceUpdate: true);

  /// الحصول على تشخيصات مفصلة
  Map<String, dynamic> getDiagnostics() {
    return {
      ...serviceStats,
      'hasCompass': _hasCompass,
      'currentDirection': _currentDirection,
      'filteredDirection': _filteredDirection,
      'qiblaAngle': qiblaAngle,
      'isCalibrating': _isCalibrating,
      'calibrationReadings': _calibrationReadings.length,
      'directionHistory': _directionHistory.length,
      'magnetometerReadings': _magnetometerReadings.length,
      'lastCompassUpdate': _lastCompassUpdate?.toIso8601String(),
      'magneticDeclination': _magneticDeclination,
      'errorMessage': _errorMessage,
      'dataFreshness': dataFreshness,
      'memoryUsage': {
        'directionHistory': _directionHistory.length,
        'magnetometerReadings': _magnetometerReadings.length,
        'calibrationReadings': _calibrationReadings.length,
      },
    };
  }
}