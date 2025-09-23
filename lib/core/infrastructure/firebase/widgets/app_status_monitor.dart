// lib/core/infrastructure/services/firebase/widgets/app_status_monitor.dart

import 'package:flutter/material.dart';
import '../remote_config_manager.dart';
import 'maintenance_screen.dart';
import 'force_update_screen.dart';

/// مراقب حالة التطبيق (الصيانة والتحديث الإجباري)
class AppStatusMonitor extends StatefulWidget {
  final Widget child;
  final RemoteConfigManager? configManager;
  
  const AppStatusMonitor({
    super.key,
    required this.child,
    this.configManager,
  });

  @override
  State<AppStatusMonitor> createState() => _AppStatusMonitorState();
}

class _AppStatusMonitorState extends State<AppStatusMonitor> {
  RemoteConfigManager? _configManager;
  bool _isMaintenanceMode = false;
  bool _isForceUpdateRequired = false;
  
  @override
  void initState() {
    super.initState();
    _configManager = widget.configManager;
    
    if (_configManager != null) {
      _setupListeners();
      _checkInitialStatus();
    }
  }
  
  /// إعداد المستمعين للتغييرات
  void _setupListeners() {
    if (_configManager == null) return;
    
    // مراقبة وضع الصيانة
    _configManager!.maintenanceMode.addListener(_onMaintenanceModeChanged);
    
    // مراقبة التحديث الإجباري
    _configManager!.forceUpdate.addListener(_onForceUpdateChanged);
  }
  
  /// فحص الحالة الأولية
  void _checkInitialStatus() {
    if (_configManager == null) return;
    
    setState(() {
      _isMaintenanceMode = _configManager!.isMaintenanceModeActive;
      _isForceUpdateRequired = _configManager!.isForceUpdateRequired;
    });
  }
  
  /// معالج تغيير وضع الصيانة
  void _onMaintenanceModeChanged() {
    if (!mounted) return;
    
    setState(() {
      _isMaintenanceMode = _configManager!.isMaintenanceModeActive;
    });
    
    if (_isMaintenanceMode) {
      _showMaintenanceDialog();
    }
  }
  
  /// معالج تغيير التحديث الإجباري
  void _onForceUpdateChanged() {
    if (!mounted) return;
    
    setState(() {
      _isForceUpdateRequired = _configManager!.isForceUpdateRequired;
    });
    
    if (_isForceUpdateRequired) {
      _showForceUpdateDialog();
    }
  }
  
  /// عرض شاشة الصيانة
  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MaintenanceScreen(),
    );
  }
  
  /// عرض شاشة التحديث الإجباري
  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ForceUpdateScreen(),
    );
  }
  
  @override
  void dispose() {
    if (_configManager != null) {
      _configManager!.maintenanceMode.removeListener(_onMaintenanceModeChanged);
      _configManager!.forceUpdate.removeListener(_onForceUpdateChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان وضع الصيانة مفعل، عرض شاشة الصيانة
    if (_isMaintenanceMode) {
      return const MaintenanceScreen();
    }
    
    // إذا كان التحديث الإجباري مطلوب، عرض شاشة التحديث
    if (_isForceUpdateRequired) {
      return const ForceUpdateScreen();
    }
    
    // عرض المحتوى العادي
    return widget.child;
  }
}