// lib/features/settings/services/settings_services_manager.dart (منظف)

import 'package:flutter/material.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../app/themes/core/theme_notifier.dart';
import '../models/app_settings.dart';

/// مدير خدمات الإعدادات المبسط
/// يدير فقط الإعدادات التي لا تتعلق بالأذونات
class SettingsServicesManager {
  final StorageService _storage;
  final PermissionService _permissionService;
  final LoggerService _logger;
  final ThemeNotifier _themeNotifier;

  // مفاتيح الإعدادات
  static const String _settingsKey = 'app_settings';
  static const String _themeKey = 'theme_mode';

  // الإعدادات الحالية
  AppSettings _currentSettings = const AppSettings();

  SettingsServicesManager({
    required StorageService storage,
    required PermissionService permissionService,
    required LoggerService logger,
    required ThemeNotifier themeNotifier,
  }) : _storage = storage,
       _permissionService = permissionService,
       _logger = logger,
       _themeNotifier = themeNotifier {
    _loadSettings();
  }

  // ==================== تحميل وحفظ الإعدادات ====================
  
  Future<void> _loadSettings() async {
    try {
      _logger.debug(message: '[SettingsManager] Loading settings');
      
      // تحميل الإعدادات من التخزين
      final settingsJson = _storage.getMap(_settingsKey);
      if (settingsJson != null) {
        _currentSettings = AppSettings.fromJson(settingsJson);
      }
      
      // تحميل الثيم
      final themeString = _storage.getString(_themeKey);
      if (themeString != null) {
        _themeNotifier.value = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeString,
          orElse: () => ThemeMode.system,
        );
      }
      
      _logger.info(message: '[SettingsManager] Settings loaded successfully');
    } catch (e) {
      _logger.error(message: '[SettingsManager] Error loading settings', error: e);
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storage.setMap(_settingsKey, _currentSettings.toJson());
      _logger.debug(message: '[SettingsManager] Settings saved');
    } catch (e) {
      _logger.error(message: '[SettingsManager] Error saving settings', error: e);
    }
  }

  // ==================== Getters ====================
  
  AppSettings get settings => _currentSettings;
  ThemeMode get currentTheme => _themeNotifier.value;
  bool get vibrationEnabled => _currentSettings.vibrationEnabled;
  bool get notificationsEnabled => _currentSettings.notificationsEnabled;
  bool get prayerNotificationsEnabled => _currentSettings.prayerNotificationsEnabled;
  bool get athkarNotificationsEnabled => _currentSettings.athkarNotificationsEnabled;
  bool get soundEnabled => _currentSettings.soundEnabled;
  String get language => _currentSettings.language;
  double get fontSize => _currentSettings.fontSize;
  
  // Getter للوصول المباشر لخدمة الأذونات
  PermissionService get permissionService => _permissionService;

  // ==================== Theme Settings ====================
  
  Future<void> changeTheme(ThemeMode mode) async {
    _themeNotifier.value = mode;
    await _storage.setString(_themeKey, mode.toString());
    _logger.info(message: '[SettingsManager] Theme changed', data: {'theme': mode.toString()});
  }

  // ==================== إعدادات الإشعارات ====================
  
  Future<void> toggleVibration(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Vibration toggled', data: {'enabled': enabled});
  }

  Future<void> toggleNotifications(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
    
    if (enabled) {
      // طلب إذن الإشعارات إذا لزم الأمر
      final status = await _permissionService.checkPermissionStatus(AppPermissionType.notification);
      if (status != AppPermissionStatus.granted) {
        await _permissionService.requestPermission(AppPermissionType.notification);
      }
    }
    
    _logger.info(message: '[SettingsManager] Notifications toggled', data: {'enabled': enabled});
  }

  Future<void> togglePrayerNotifications(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(prayerNotificationsEnabled: enabled);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Prayer notifications toggled', data: {'enabled': enabled});
  }

  Future<void> toggleAthkarNotifications(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(athkarNotificationsEnabled: enabled);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Athkar notifications toggled', data: {'enabled': enabled});
  }

  // ==================== إعدادات إضافية ====================
  
  Future<void> toggleSound(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(soundEnabled: enabled);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Sound toggled', data: {'enabled': enabled});
  }

  Future<void> changeLanguage(String language) async {
    _currentSettings = _currentSettings.copyWith(language: language);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Language changed', data: {'language': language});
  }

  Future<void> changeFontSize(double size) async {
    _currentSettings = _currentSettings.copyWith(fontSize: size);
    await _saveSettings();
    _logger.info(message: '[SettingsManager] Font size changed', data: {'size': size});
  }

  // ==================== إعادة تعيين الإعدادات ====================
  
  Future<void> resetSettings() async {
    _logger.info(message: '[SettingsManager] Resetting all settings');
    
    // إعادة تعيين إلى القيم الافتراضية
    _currentSettings = const AppSettings();
    await _storage.remove(_settingsKey);
    
    // إعادة تعيين الثيم
    _themeNotifier.value = ThemeMode.system;
    await _storage.remove(_themeKey);
    
    _logger.info(message: '[SettingsManager] Settings reset completed');
  }

  // ==================== Cleanup ====================
  
  void dispose() {
    _logger.debug(message: '[SettingsManager] Disposing settings manager');
  }
}