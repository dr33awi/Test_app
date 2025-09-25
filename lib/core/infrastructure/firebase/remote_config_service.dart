// lib/core/infrastructure/firebase/remote_config_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// خدمة Firebase Remote Config
class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance = FirebaseRemoteConfigService._internal();
  factory FirebaseRemoteConfigService() => _instance;
  FirebaseRemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;
  
  // مفاتيح الإعدادات
  static const String _keyAppVersion = 'app_version';
  static const String _keyForceUpdate = 'force_update';
  static const String _keyMaintenanceMode = 'maintenance_mode';
  static const String _keyFeaturesConfig = 'features_config';
  static const String _keyNotificationConfig = 'notification_config';
  static const String _keyThemeConfig = 'theme_config';
  static const String _keyAthkarSettings = 'athkar_settings';

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // إعداد التحديث التلقائي
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // تحديث كل ساعة
      ));
      
      // تعيين القيم الافتراضية
      await _setDefaults();
      
      // جلب الإعدادات الأولية
      await _fetchAndActivate();
      
      _isInitialized = true;
      debugPrint('FirebaseRemoteConfigService initialized successfully');
      
    } catch (e, stackTrace) {
      debugPrint('Error initializing Firebase Remote Config: $e');
      throw Exception('Failed to initialize Firebase Remote Config: $e');
    }
  }

  /// تعيين القيم الافتراضية
  Future<void> _setDefaults() async {
    await _remoteConfig.setDefaults({
      _keyAppVersion: '1.0.0',
      _keyForceUpdate: false,
      _keyMaintenanceMode: false,
      _keyFeaturesConfig: jsonEncode({
        'prayer_times_enabled': true,
        'qibla_enabled': true,
        'athkar_enabled': true,
        'tasbih_enabled': true,
        'dua_enabled': true,
        'notifications_enabled': true,
      }),
      _keyNotificationConfig: jsonEncode({
        'prayer_notifications': true,
        'athkar_reminders': true,
        'daily_motivations': true,
        'custom_notifications': true,
      }),
      _keyThemeConfig: jsonEncode({
        'primary_color': '#2E7D32',
        'accent_color': '#4CAF50',
        'dark_mode_enabled': true,
        'custom_themes': [],
      }),
      _keyAthkarSettings: jsonEncode({
        'auto_scroll_enabled': true,
        'vibration_feedback': true,
        'sound_effects': false,
        'reading_mode': 'normal',
      }),
    });
  }

  /// جلب وتفعيل الإعدادات
  Future<bool> _fetchAndActivate() async {
    try {
      final fetchResult = await _remoteConfig.fetchAndActivate();
      debugPrint('Remote config fetch result: $fetchResult');
      return fetchResult;
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
      return false;
    }
  }

  /// جلب الإعدادات يدوياً
  Future<bool> refresh() async {
    if (!_isInitialized) {
      debugPrint('Remote config not initialized');
      return false;
    }
    
    return await _fetchAndActivate();
  }

  // ==================== الحصول على القيم ====================

  /// الحصول على إصدار التطبيق المطلوب
  String get requiredAppVersion => _remoteConfig.getString(_keyAppVersion);

  /// هل يجب فرض التحديث
  bool get isForceUpdateRequired => _remoteConfig.getBool(_keyForceUpdate);

  /// هل التطبيق في وضع الصيانة
  bool get isMaintenanceModeEnabled => _remoteConfig.getBool(_keyMaintenanceMode);

  /// إعدادات الميزات
  Map<String, dynamic> get featuresConfig {
    try {
      final jsonString = _remoteConfig.getString(_keyFeaturesConfig);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing features config: $e');
      return {
        'prayer_times_enabled': true,
        'qibla_enabled': true,
        'athkar_enabled': true,
        'tasbih_enabled': true,
        'dua_enabled': true,
        'notifications_enabled': true,
      };
    }
  }

  /// إعدادات الإشعارات
  Map<String, dynamic> get notificationConfig {
    try {
      final jsonString = _remoteConfig.getString(_keyNotificationConfig);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing notification config: $e');
      return {
        'prayer_notifications': true,
        'athkar_reminders': true,
        'daily_motivations': true,
        'custom_notifications': true,
      };
    }
  }

  /// إعدادات الثيم
  Map<String, dynamic> get themeConfig {
    try {
      final jsonString = _remoteConfig.getString(_keyThemeConfig);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing theme config: $e');
      return {
        'primary_color': '#2E7D32',
        'accent_color': '#4CAF50',
        'dark_mode_enabled': true,
        'custom_themes': [],
      };
    }
  }

  /// إعدادات الأذكار
  Map<String, dynamic> get athkarSettings {
    try {
      final jsonString = _remoteConfig.getString(_keyAthkarSettings);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing athkar settings: $e');
      return {
        'auto_scroll_enabled': true,
        'vibration_feedback': true,
        'sound_effects': false,
        'reading_mode': 'normal',
      };
    }
  }

  // ==================== التحقق من الميزات ====================

  /// التحقق من تفعيل ميزة معينة
  bool isFeatureEnabled(String featureName) {
    final features = featuresConfig;
    return features[featureName] as bool? ?? false;
  }

  /// التحقق من تفعيل إشعار معين
  bool isNotificationEnabled(String notificationType) {
    final notifications = notificationConfig;
    return notifications[notificationType] as bool? ?? false;
  }

  // ==================== إدارة الإعدادات المخصصة ====================

  /// الحصول على قيمة مخصصة
  String getCustomString(String key, {String defaultValue = ''}) {
    return _remoteConfig.getString(key).isEmpty ? defaultValue : _remoteConfig.getString(key);
  }

  /// الحصول على قيمة منطقية مخصصة
  bool getCustomBool(String key, {bool defaultValue = false}) {
    return _remoteConfig.getBool(key);
  }

  /// الحصول على قيمة رقمية مخصصة
  int getCustomInt(String key, {int defaultValue = 0}) {
    return _remoteConfig.getInt(key);
  }

  /// الحصول على قيمة مخصصة كـ JSON
  Map<String, dynamic>? getCustomJson(String key) {
    try {
      final jsonString = _remoteConfig.getString(key);
      if (jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error parsing custom JSON for key $key: $e');
      return null;
    }
  }

  // ==================== معلومات الحالة ====================

  /// حالة آخر جلب
  RemoteConfigFetchStatus get lastFetchStatus => _remoteConfig.lastFetchStatus;

  /// وقت آخر جلب ناجح
  DateTime get lastFetchTime => _remoteConfig.lastFetchTime;

  /// هل الخدمة مهيأة
  bool get isInitialized => _isInitialized;

  // ==================== معالجة الأخطاء وإعادة التهيئة ====================

  /// إعادة تهيئة الخدمة
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  /// تنظيف الموارد
  void dispose() {
    _isInitialized = false;
    debugPrint('FirebaseRemoteConfigService disposed');
  }
}