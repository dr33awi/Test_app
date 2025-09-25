// lib/core/infrastructure/firebase/remote_config_manager.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/storage/storage_service.dart';
import 'remote_config_service.dart';

/// مدير الإعدادات عن بعد - يربط Firebase Remote Config مع باقي التطبيق
class RemoteConfigManager {
  static final RemoteConfigManager _instance = RemoteConfigManager._internal();
  factory RemoteConfigManager() => _instance;
  RemoteConfigManager._internal();

  late FirebaseRemoteConfigService _remoteConfig;
  late StorageService _storage;
  
  bool _isInitialized = false;
  Timer? _periodicRefreshTimer;
  
  // ValueNotifiers للميزات الرئيسية
  final ValueNotifier<bool> _prayerTimesEnabled = ValueNotifier(true);
  final ValueNotifier<bool> _qiblaEnabled = ValueNotifier(true);
  final ValueNotifier<bool> _athkarEnabled = ValueNotifier(true);
  final ValueNotifier<bool> _notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> _maintenanceMode = ValueNotifier(false);
  final ValueNotifier<bool> _forceUpdate = ValueNotifier(false);

  // Getters للاستماع للتغييرات
  ValueListenable<bool> get prayerTimesEnabled => _prayerTimesEnabled;
  ValueListenable<bool> get qiblaEnabled => _qiblaEnabled;
  ValueListenable<bool> get athkarEnabled => _athkarEnabled;
  ValueListenable<bool> get notificationsEnabled => _notificationsEnabled;
  ValueListenable<bool> get maintenanceMode => _maintenanceMode;
  ValueListenable<bool> get forceUpdate => _forceUpdate;

  /// تهيئة المدير
  Future<void> initialize({
    required FirebaseRemoteConfigService remoteConfig,
    required StorageService storage,
  }) async {
    if (_isInitialized) return;
    
    _remoteConfig = remoteConfig;
    _storage = storage;
    
    try {
      // تحديث القيم الأولية
      await _updateAllValues();
      
      // بدء التحديث الدوري (كل ساعة)
      _startPeriodicRefresh();
      
      _isInitialized = true;
      debugPrint('RemoteConfigManager initialized successfully');
      
    } catch (e, stackTrace) {
      debugPrint('Error initializing RemoteConfigManager: $e');
    }
  }

  /// تحديث جميع القيم
  Future<void> _updateAllValues() async {
    try {
      // تحديث الميزات
      final features = _remoteConfig.featuresConfig;
      _prayerTimesEnabled.value = features['prayer_times_enabled'] ?? true;
      _qiblaEnabled.value = features['qibla_enabled'] ?? true;
      _athkarEnabled.value = features['athkar_enabled'] ?? true;
      _notificationsEnabled.value = features['notifications_enabled'] ?? true;
      
      // تحديث حالات النظام
      _maintenanceMode.value = _remoteConfig.isMaintenanceModeEnabled;
      _forceUpdate.value = _remoteConfig.isForceUpdateRequired;
      
      debugPrint('All remote config values updated');
      
    } catch (e) {
      debugPrint('Error updating remote config values: $e');
    }
  }

  /// بدء التحديث الدوري
  void _startPeriodicRefresh() {
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) async {
        await refreshConfig();
      },
    );
  }

  /// تحديث الإعدادات يدوياً
  Future<bool> refreshConfig() async {
    try {
      debugPrint('Refreshing remote config...');
      
      final success = await _remoteConfig.refresh();
      if (success) {
        await _updateAllValues();
        await _storage.setString('last_config_refresh', DateTime.now().toIso8601String());
      }
      
      return success;
    } catch (e) {
      debugPrint('Error refreshing config: $e');
      return false;
    }
  }

  // ==================== التحقق من الميزات ====================

  /// فحص تفعيل مواقيت الصلاة
  bool get isPrayerTimesFeatureEnabled => _prayerTimesEnabled.value;

  /// فحص تفعيل القبلة
  bool get isQiblaFeatureEnabled => _qiblaEnabled.value;

  /// فحص تفعيل الأذكار
  bool get isAthkarFeatureEnabled => _athkarEnabled.value;

  /// فحص تفعيل الإشعارات
  bool get isNotificationsFeatureEnabled => _notificationsEnabled.value;

  /// فحص وضع الصيانة
  bool get isMaintenanceModeActive => _maintenanceMode.value;

  /// فحص الحاجة لتحديث إجباري
  bool get isForceUpdateRequired => _forceUpdate.value;

  // ==================== إعدادات الأذكار ====================

  /// الحصول على إعدادات الأذكار
  Map<String, dynamic> get athkarSettings => _remoteConfig.athkarSettings;

  /// هل التمرير التلقائي مفعل
  bool get isAutoScrollEnabled => athkarSettings['auto_scroll_enabled'] ?? true;

  /// هل الاهتزاز مفعل
  bool get isVibrationEnabled => athkarSettings['vibration_feedback'] ?? true;

  /// هل الأصوات مفعلة
  bool get isSoundEffectsEnabled => athkarSettings['sound_effects'] ?? false;

  /// وضع القراءة
  String get readingMode => athkarSettings['reading_mode'] ?? 'normal';

  // ==================== إعدادات الإشعارات ====================

  /// الحصول على إعدادات الإشعارات
  Map<String, dynamic> get notificationConfig => _remoteConfig.notificationConfig;

  /// هل إشعارات الصلاة مفعلة
  bool get isPrayerNotificationsEnabled => notificationConfig['prayer_notifications'] ?? true;

  /// هل تذكيرات الأذكار مفعلة
  bool get isAthkarRemindersEnabled => notificationConfig['athkar_reminders'] ?? true;

  /// هل التحفيز اليومي مفعل
  bool get isDailyMotivationEnabled => notificationConfig['daily_motivations'] ?? true;

  /// هل الإشعارات المخصصة مفعلة
  bool get isCustomNotificationsEnabled => notificationConfig['custom_notifications'] ?? true;

  // ==================== إعدادات الثيم ====================

  /// الحصول على إعدادات الثيم
  Map<String, dynamic> get themeConfig => _remoteConfig.themeConfig;

  /// اللون الأساسي
  String get primaryColor => themeConfig['primary_color'] ?? '#2E7D32';

  /// اللون المساعد
  String get accentColor => themeConfig['accent_color'] ?? '#4CAF50';

  /// هل الوضع المظلم مفعل
  bool get isDarkModeEnabled => themeConfig['dark_mode_enabled'] ?? true;

  /// الثيمات المخصصة
  List<dynamic> get customThemes => themeConfig['custom_themes'] ?? [];

  // ==================== إعدادات مخصصة ====================

  /// الحصول على قيمة مخصصة
  T? getCustomValue<T>(String key, {T? defaultValue}) {
    try {
      if (T == String) {
        return _remoteConfig.getCustomString(key, defaultValue: defaultValue as String? ?? '') as T?;
      } else if (T == bool) {
        return _remoteConfig.getCustomBool(key, defaultValue: defaultValue as bool? ?? false) as T?;
      } else if (T == int) {
        return _remoteConfig.getCustomInt(key, defaultValue: defaultValue as int? ?? 0) as T?;
      } else {
        return defaultValue;
      }
    } catch (e) {
      debugPrint('Error getting custom value for key $key: $e');
      return defaultValue;
    }
  }

  /// الحصول على JSON مخصص
  Map<String, dynamic>? getCustomJson(String key) {
    return _remoteConfig.getCustomJson(key);
  }

  // ==================== متابعة التغييرات ====================

  /// إضافة مستمع لتغييرات ميزة معينة
  void addFeatureListener(String feature, VoidCallback callback) {
    switch (feature.toLowerCase()) {
      case 'prayer_times':
        _prayerTimesEnabled.addListener(callback);
        break;
      case 'qibla':
        _qiblaEnabled.addListener(callback);
        break;
      case 'athkar':
        _athkarEnabled.addListener(callback);
        break;
      case 'notifications':
        _notificationsEnabled.addListener(callback);
        break;
      case 'maintenance':
        _maintenanceMode.addListener(callback);
        break;
      case 'force_update':
        _forceUpdate.addListener(callback);
        break;
    }
  }

  /// إزالة مستمع لتغييرات ميزة معينة
  void removeFeatureListener(String feature, VoidCallback callback) {
    switch (feature.toLowerCase()) {
      case 'prayer_times':
        _prayerTimesEnabled.removeListener(callback);
        break;
      case 'qibla':
        _qiblaEnabled.removeListener(callback);
        break;
      case 'athkar':
        _athkarEnabled.removeListener(callback);
        break;
      case 'notifications':
        _notificationsEnabled.removeListener(callback);
        break;
      case 'maintenance':
        _maintenanceMode.removeListener(callback);
        break;
      case 'force_update':
        _forceUpdate.removeListener(callback);
        break;
    }
  }

  // ==================== معلومات الحالة ====================

  /// هل المدير مهيأ
  bool get isInitialized => _isInitialized;

  /// آخر وقت تحديث
  DateTime? get lastRefreshTime {
    final timeString = _storage.getString('last_config_refresh');
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// معلومات حالة Firebase Remote Config
  Map<String, dynamic> get configStatus => {
    'is_initialized': _remoteConfig.isInitialized,
    'last_fetch_status': _remoteConfig.lastFetchStatus.toString(),
    'last_fetch_time': _remoteConfig.lastFetchTime.toIso8601String(),
    'last_manager_refresh': lastRefreshTime?.toIso8601String(),
  };

  // ==================== تنظيف الموارد ====================

  /// تنظيف الموارد
  void dispose() {
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = null;
    
    _prayerTimesEnabled.dispose();
    _qiblaEnabled.dispose();
    _athkarEnabled.dispose();
    _notificationsEnabled.dispose();
    _maintenanceMode.dispose();
    _forceUpdate.dispose();
    
    _isInitialized = false;
    debugPrint('RemoteConfigManager disposed');
  }
}