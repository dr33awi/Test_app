// lib/core/infrastructure/services/permissions/permission_service_impl.dart (منظف)

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import '../logging/logger_service.dart';
import '../storage/storage_service.dart';
import 'permission_service.dart';
import 'permission_constants.dart';
import 'widgets/permission_dialogs.dart';
import 'handlers/permission_handler_factory.dart';

/// تنفيذ مبسط لخدمة الأذونات بدون مراقبة دورية
class PermissionServiceImpl implements PermissionService {
  final LoggerService _logger;
  final StorageService _storage;
  final BuildContext? _context;
  
  // Cache
  final Map<AppPermissionType, AppPermissionStatus> _statusCache = {};
  final Map<AppPermissionType, DateTime> _lastRequestTime = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(seconds: 30);
  static const Duration _minRequestInterval = Duration(seconds: 5);
  
  // Stream controller
  final StreamController<PermissionChange> _permissionChangeController = 
      StreamController<PermissionChange>.broadcast();
  
  PermissionServiceImpl({
    required LoggerService logger,
    required StorageService storage,
    BuildContext? context,
  }) : _logger = logger,
       _storage = storage,
       _context = context {
    _initializeService();
  }
  
  void _initializeService() {
    _logger.debug(message: '[PermissionService] Initializing');
    _loadCachedStatuses();
    // تم حذف _startPermissionMonitoring() - لا نحتاج مراقبة دورية هنا
  }
  
  @override
  Future<bool> checkNotificationPermission() async {
    final status = await checkPermissionStatus(AppPermissionType.notification);
    return status == AppPermissionStatus.granted;
  }
  
  @override
  Future<bool> requestNotificationPermission() async {
    final status = await requestPermission(AppPermissionType.notification);
    return status == AppPermissionStatus.granted;
  }
  
  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType permission) async {
    _logger.info(message: '[PermissionService] Requesting permission', data: {'type': permission.toString()});
    
    // Check throttling
    if (_shouldThrottleRequest(permission)) {
      _logger.debug(message: '[PermissionService] Request throttled');
      return await checkPermissionStatus(permission);
    }
    
    // Check cache first
    final cachedStatus = _getCachedStatus(permission);
    if (cachedStatus != null && cachedStatus == AppPermissionStatus.granted) {
      _logger.debug(message: '[PermissionService] Permission already granted (cached)');
      return cachedStatus;
    }
    
    // Record request time
    _lastRequestTime[permission] = DateTime.now();
    
    // Get appropriate handler
    final handler = PermissionHandlerFactory.getHandler(permission);
    if (handler == null) {
      _logger.warning(message: '[PermissionService] Unsupported permission type');
      return AppPermissionStatus.unknown;
    }
    
    try {
      // Check availability
      if (!handler.isAvailable) {
        _logger.warning(message: '[PermissionService] Permission not available on this platform');
        return AppPermissionStatus.unknown;
      }
      
      // Request permission
      final status = await handler.request();
      
      // Update cache
      _updateCache(permission, status);
      
      // Notify listeners
      _notifyPermissionChange(
        permission, 
        cachedStatus ?? AppPermissionStatus.unknown,
        status
      );
      
      _logger.info(
        message: '[PermissionService] Permission request result',
        data: {
          'type': permission.toString(),
          'status': status.toString(),
        }
      );
      
      return status;
    } catch (e, s) {
      _logger.error(message: '[PermissionService] Error requesting permission', error: e, stackTrace: s);
      return AppPermissionStatus.unknown;
    }
  }
  
  @override
  Future<PermissionBatchResult> requestMultiplePermissions({
    required List<AppPermissionType> permissions,
    Function(PermissionProgress)? onProgress,
    bool showExplanationDialog = true,
  }) async {
    _logger.info(
      message: '[PermissionService] Requesting multiple permissions',
      data: {'permissions': permissions.map((p) => p.toString()).toList()}
    );
    
    // Filter supported permissions
    final supportedPermissions = permissions.where((p) {
      final handler = PermissionHandlerFactory.getHandler(p);
      return handler != null && handler.isAvailable;
    }).toList();
    
    if (supportedPermissions.isEmpty) {
      _logger.warning(message: '[PermissionService] No supported permissions');
      return PermissionBatchResult(
        results: {},
        allGranted: false,
        deniedPermissions: permissions,
      );
    }
    
    // Show explanation dialog if needed
    if (showExplanationDialog && _context != null) {
      final shouldContinue = await PermissionDialogs.showExplanation(
        context: _context!,
        permissions: supportedPermissions,
      );
      
      if (!shouldContinue) {
        _logger.info(message: '[PermissionService] User cancelled permission request');
        return PermissionBatchResult.cancelled();
      }
    }
    
    // Request permissions with progress tracking
    final results = <AppPermissionType, AppPermissionStatus>{};
    
    for (int i = 0; i < supportedPermissions.length; i++) {
      final permission = supportedPermissions[i];
      
      // Send progress update
      onProgress?.call(PermissionProgress(
        current: i + 1,
        total: supportedPermissions.length,
        currentPermission: permission,
      ));
      
      // Request permission
      results[permission] = await requestPermission(permission);
      
      // Small delay between requests
      if (i < supportedPermissions.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    
    // Calculate results
    final deniedPermissions = results.entries
        .where((e) => e.value != AppPermissionStatus.granted)
        .map((e) => e.key)
        .toList();
    
    return PermissionBatchResult(
      results: results,
      allGranted: deniedPermissions.isEmpty,
      deniedPermissions: deniedPermissions,
    );
  }
  
  @override
  Future<AppPermissionStatus> checkPermissionStatus(AppPermissionType permission) async {
    // Check cache first
    final cachedStatus = _getCachedStatus(permission);
    if (cachedStatus != null && _isCacheValid()) {
      return cachedStatus;
    }
    
    // Get appropriate handler
    final handler = PermissionHandlerFactory.getHandler(permission);
    if (handler == null) {
      _logger.warning(message: '[PermissionService] Unsupported permission type for check');
      return AppPermissionStatus.unknown;
    }
    
    try {
      // Check availability
      if (!handler.isAvailable) {
        return AppPermissionStatus.unknown;
      }
      
      // Check status
      final status = await handler.check();
      
      // Update cache
      _updateCache(permission, status);
      
      return status;
    } catch (e) {
      _logger.error(message: '[PermissionService] Error checking permission status', error: e);
      return AppPermissionStatus.unknown;
    }
  }
  
  @override
  Future<Map<AppPermissionType, AppPermissionStatus>> checkAllPermissions() async {
    // فحص الأذونات الحرجة فقط لتحسين الأداء
    final criticalPermissions = PermissionConstants.criticalPermissions;
    
    _logger.info(message: '[PermissionService] Checking critical permissions only');
    
    final results = <AppPermissionType, AppPermissionStatus>{};
    
    // Use parallel requests with batch size limit
    const batchSize = 3;
    for (int i = 0; i < criticalPermissions.length; i += batchSize) {
      final batch = criticalPermissions.skip(i).take(batchSize).toList();
      
      await Future.wait(
        batch.map((permission) async {
          results[permission] = await checkPermissionStatus(permission);
        }),
      );
    }
    
    return results;
  }
  
  @override
  Future<bool> openAppSettings() async {
    _logger.info(message: '[PermissionService] Opening app settings');
    
    try {
      return await handler.openAppSettings();
    } catch (e) {
      _logger.error(message: '[PermissionService] Error opening settings', error: e);
      return false;
    }
  }
  
  @override
  String getPermissionDescription(AppPermissionType permission) {
    return PermissionConstants.getDescription(permission);
  }
  
  @override
  String getPermissionName(AppPermissionType permission) {
    return PermissionConstants.getName(permission);
  }
  
  @override
  Stream<PermissionChange> get permissionChanges => _permissionChangeController.stream;
  
  @override
  void clearPermissionCache() {
    _statusCache.clear();
    _lastRequestTime.clear();
    _lastCacheUpdate = null;
    _logger.debug(message: '[PermissionService] Permission cache cleared');
  }
  
  @override
  Future<void> dispose() async {
    await _permissionChangeController.close();
    clearPermissionCache();
    _logger.debug(message: '[PermissionService] Permission service disposed');
  }
  
  // ==================== Private Methods ====================
  
  bool _shouldThrottleRequest(AppPermissionType permission) {
    final lastRequest = _lastRequestTime[permission];
    if (lastRequest == null) return false;
    
    final timeSinceLastRequest = DateTime.now().difference(lastRequest);
    return timeSinceLastRequest < _minRequestInterval;
  }
  
  AppPermissionStatus? _getCachedStatus(AppPermissionType permission) {
    if (!_isCacheValid()) {
      clearPermissionCache();
      return null;
    }
    return _statusCache[permission];
  }
  
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration;
  }
  
  void _updateCache(AppPermissionType permission, AppPermissionStatus status) {
    _statusCache[permission] = status;
    _lastCacheUpdate = DateTime.now();
    _saveCacheToStorage();
  }
  
  void _saveCacheToStorage() {
    try {
      final cacheData = <String, String>{};
      _statusCache.forEach((key, value) {
        cacheData[key.toString()] = value.toString();
      });
      _storage.setMap('permission_cache', cacheData);
    } catch (e) {
      _logger.warning(message: '[PermissionService] Error saving permission cache');
    }
  }
  
  void _loadCachedStatuses() {
    try {
      final cached = _storage.getMap('permission_cache');
      if (cached != null) {
        cached.forEach((key, value) {
          try {
            final permission = AppPermissionType.values.firstWhere(
              (p) => p.toString() == key,
            );
            final status = AppPermissionStatus.values.firstWhere(
              (s) => s.toString() == value,
            );
            _statusCache[permission] = status;
          } catch (e) {
            // Ignore parsing errors
          }
        });
        _lastCacheUpdate = DateTime.now();
      }
    } catch (e) {
      _logger.warning(message: '[PermissionService] Error loading permission cache');
    }
  }
  
  // تم حذف _startPermissionMonitoring() بالكامل
  
  void _notifyPermissionChange(
    AppPermissionType permission,
    AppPermissionStatus oldStatus,
    AppPermissionStatus newStatus,
  ) {
    if (oldStatus != newStatus) {
      _permissionChangeController.add(PermissionChange(
        permission: permission,
        oldStatus: oldStatus,
        newStatus: newStatus,
        timestamp: DateTime.now(),
      ));
    }
  }
}