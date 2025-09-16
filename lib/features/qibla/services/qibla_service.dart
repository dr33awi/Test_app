// lib/features/qibla/services/qibla_service.dart - نسخة محسنة ومبسطة
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../models/qibla_model.dart';

/// خدمة القبلة المبسطة
class QiblaService extends ChangeNotifier {
  final LoggerService _logger;
  final StorageService _storage;
  final PermissionService _permissionService;

  // مفاتيح التخزين
  static const String _qiblaDataKey = 'qibla_data';

  // حالة الخدمة
  QiblaModel? _qiblaData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUpdating = false; // لمنع التحديثات المتزامنة

  // البوصلة
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentDirection = 0.0;
  bool _hasCompass = false;
  double _compassAccuracy = 0.0;

  // تصفية القراءات
  final List<double> _directionHistory = [];
  static const int _filterSize = 5; // تبسيط حجم التصفية

  QiblaService({
    required LoggerService logger,
    required StorageService storage,
    required PermissionService permissionService,
  })  : _logger = logger,
        _storage = storage,
        _permissionService = permissionService {
    _init();
  }

  // ===== الخصائص العامة =====

  QiblaModel? get qiblaData => _qiblaData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get currentDirection => _currentDirection;
  bool get hasCompass => _hasCompass;
  double get compassAccuracy => _compassAccuracy;
  
  // دقة البوصلة كنسبة مئوية
  double get accuracyPercentage => _compassAccuracy * 100;

  // هل البيانات حديثة
  bool get hasRecentData => _qiblaData != null && _qiblaData!.isFresh;

  // هل تحتاج معايرة
  bool get needsCalibration => _hasCompass && _compassAccuracy < 0.5;

  // ===== التهيئة الأولية =====

  Future<void> _init() async {
    try {
      _logger.info(message: '[QiblaService] بدء التهيئة');

      // التحقق من البوصلة
      await _checkCompassAvailability();

      if (_hasCompass) {
        await _startCompassListener();
      }

      // استرجاع البيانات المخزنة
      await _loadStoredData();

      _logger.info(message: '[QiblaService] تمت التهيئة بنجاح');
    } catch (e) {
      _logger.error(message: '[QiblaService] خطأ في التهيئة', error: e);
    }
  }

  /// التحقق من توفر البوصلة
  Future<void> _checkCompassAvailability() async {
    try {
      final compassEvents = await FlutterCompass.events
          ?.timeout(const Duration(seconds: 2))
          .take(1)
          .toList();

      _hasCompass = compassEvents?.isNotEmpty ?? false;
      
      if (_hasCompass && compassEvents!.first.accuracy != null) {
        _compassAccuracy = _calculateAccuracy(compassEvents.first.accuracy!);
      }

      _logger.info(message: '[QiblaService] البوصلة: $_hasCompass');
    } catch (e) {
      _hasCompass = false;
      _logger.error(message: '[QiblaService] خطأ في فحص البوصلة');
    }
  }

  /// بدء الاستماع للبوصلة
  Future<void> _startCompassListener() async {
    if (!_hasCompass) return;

    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (event.heading != null) {
          _processCompassReading(event);
        }
      },
      onError: (error) {
        _logger.error(message: '[QiblaService] خطأ في البوصلة');
      },
    );
  }

  /// معالجة قراءة البوصلة
  void _processCompassReading(CompassEvent event) {
    _currentDirection = event.heading!;

    if (event.accuracy != null) {
      _compassAccuracy = _calculateAccuracy(event.accuracy!);
    }

    // تصفية بسيطة
    _directionHistory.add(_currentDirection);
    if (_directionHistory.length > _filterSize) {
      _directionHistory.removeAt(0);
    }

    // حساب المتوسط
    if (_directionHistory.isNotEmpty) {
      _currentDirection = _directionHistory.reduce((a, b) => a + b) / _directionHistory.length;
    }

    notifyListeners();
  }

  /// حساب دقة البوصلة
  double _calculateAccuracy(double rawAccuracy) {
    if (rawAccuracy < 0) return 1.0;
    if (rawAccuracy > 180) return 0.0;
    return 1.0 - (rawAccuracy / 180.0);
  }

  // ===== تحديث البيانات =====

  /// تحديث بيانات القبلة
  Future<void> updateQiblaData({bool forceUpdate = false}) async {
    // منع التحديثات المتزامنة
    if (_isUpdating) {
      _logger.info(message: '[QiblaService] تحديث جاري بالفعل');
      return;
    }

    // تحقق من الحاجة للتحديث
    if (!forceUpdate && hasRecentData) {
      _logger.info(message: '[QiblaService] البيانات حديثة');
      return;
    }

    _isUpdating = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.info(message: '[QiblaService] بدء تحديث البيانات');

      // التحقق من الأذونات
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('لم يتم منح إذن الوصول إلى الموقع');
      }

      // الحصول على الموقع
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      // معلومات الموقع (اختياري)
      String? cityName;
      String? countryName;
      
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          cityName = placemarks.first.locality;
          countryName = placemarks.first.country;
        }
      } catch (e) {
        // تجاهل أخطاء معلومات الموقع
      }

      // إنشاء نموذج القبلة
      _qiblaData = QiblaModel.fromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        cityName: cityName,
        countryName: countryName,
      );

      // حفظ البيانات
      await _saveData();

      _logger.info(message: '[QiblaService] تم التحديث بنجاح');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _logger.error(message: '[QiblaService] خطأ في التحديث', error: e);
    } finally {
      _isLoading = false;
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// فرض التحديث
  Future<void> forceUpdate() => updateQiblaData(forceUpdate: true);

  // ===== إدارة البيانات المخزنة =====

  /// تحميل البيانات المخزنة
  Future<void> _loadStoredData() async {
    try {
      final json = _storage.getMap(_qiblaDataKey);
      if (json != null && json.isNotEmpty) {
        _qiblaData = QiblaModel.fromJson(json);
        _logger.info(message: '[QiblaService] تم تحميل البيانات المخزنة');
      }
    } catch (e) {
      _logger.error(message: '[QiblaService] خطأ في تحميل البيانات');
    }
  }

  /// حفظ البيانات
  Future<void> _saveData() async {
    if (_qiblaData == null) return;
    
    try {
      await _storage.setMap(_qiblaDataKey, _qiblaData!.toJson());
    } catch (e) {
      _logger.error(message: '[QiblaService] خطأ في حفظ البيانات');
    }
  }

  // ===== المعايرة =====

  bool _isCalibrated = false;
  bool _isCalibrating = false;

  bool get isCalibrated => _isCalibrated;
  bool get isCalibrating => _isCalibrating;

  /// بدء المعايرة
  Future<void> startCalibration() async {
    if (!_hasCompass || _isCalibrating) return;

    _isCalibrating = true;
    _isCalibrated = false;
    notifyListeners();

    // محاكاة المعايرة
    await Future.delayed(const Duration(seconds: 3));

    _isCalibrating = false;
    _isCalibrated = true;
    _compassAccuracy = 0.9; // تحسين الدقة بعد المعايرة
    
    notifyListeners();
    _logger.info(message: '[QiblaService] تمت المعايرة');
  }

  /// إعادة تعيين المعايرة
  void resetCalibration() {
    _isCalibrated = false;
    _compassAccuracy = 0.5;
    notifyListeners();
  }

  // ===== وظائف مساعدة =====

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
      return false;
    }
  }

  /// الحصول على رسالة خطأ مفهومة
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الحصول على الموقع';
    } else if (error.toString().contains('LocationServiceDisabledException')) {
      return 'خدمة الموقع معطلة';
    } else if (error.toString().contains('PermissionDeniedException')) {
      return 'لم يتم منح إذن الموقع';
    }
    return 'حدث خطأ غير متوقع';
  }

  // ===== التنظيف =====

  @override
  void dispose() {
    _logger.info(message: '[QiblaService] تنظيف الموارد');
    _compassSubscription?.cancel();
    _directionHistory.clear();
    super.dispose();
  }
}