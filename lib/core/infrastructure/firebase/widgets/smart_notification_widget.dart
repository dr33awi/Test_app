// lib/features/notifications/widgets/smart_notification_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:athkar_app/core/infrastructure/firebase/firebase_messaging_service.dart';
import 'package:athkar_app/core/infrastructure/firebase/remote_config_manager.dart';

/// Widget ذكي للإشعارات يتكيف مع إعدادات Remote Config
class SmartNotificationWidget extends StatefulWidget {
  final Widget child;
  
  const SmartNotificationWidget({
    super.key,
    required this.child,
  });

  @override
  State<SmartNotificationWidget> createState() => _SmartNotificationWidgetState();
}

class _SmartNotificationWidgetState extends State<SmartNotificationWidget> {
  FirebaseMessagingService? _messagingService;
  RemoteConfigManager? _configManager;
  StreamSubscription? _configSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  void _initializeServices() {
    // محاولة الحصول على الخدمات من Service Locator
    try {
      // يمكن استخدام GetIt هنا إذا كان متوفراً
      // _messagingService = getIt<FirebaseMessagingService>();
      // _configManager = getIt<RemoteConfigManager>();
      
      if (_configManager != null) {
        _setupConfigListener();
      }
    } catch (e) {
      debugPrint('Smart notification widget: Services not available');
    }
  }
  
  void _setupConfigListener() {
    // مراقبة تغييرات إعدادات الإشعارات
    _configManager?.notificationsEnabled.addListener(_onNotificationSettingsChanged);
  }
  
  void _onNotificationSettingsChanged() {
    if (!mounted) return;
    
    final enabled = _configManager?.isNotificationsFeatureEnabled ?? true;
    
    if (enabled) {
      _enableNotifications();
    } else {
      _disableNotifications();
    }
  }
  
  Future<void> _enableNotifications() async {
    if (_messagingService == null) return;
    
    try {
      // إعادة تفعيل الاشتراكات المهمة
      await _messagingService!.subscribeToPrayerNotifications();
      await _messagingService!.subscribeToAthkarNotifications();
      
      _showNotificationSnackBar(
        'تم تفعيل الإشعارات',
        Colors.green,
        Icons.notifications_active,
      );
    } catch (e) {
      debugPrint('Error enabling notifications: $e');
    }
  }
  
  Future<void> _disableNotifications() async {
    if (_messagingService == null) return;
    
    try {
      // إلغاء الاشتراكات
      await _messagingService!.unsubscribeFromPrayerNotifications();
      await _messagingService!.unsubscribeFromAthkarNotifications();
      
      _showNotificationSnackBar(
        'تم تعطيل الإشعارات',
        Colors.orange,
        Icons.notifications_off,
      );
    } catch (e) {
      debugPrint('Error disabling notifications: $e');
    }
  }
  
  void _showNotificationSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  @override
  void dispose() {
    _configSubscription?.cancel();
    _configManager?.notificationsEnabled.removeListener(_onNotificationSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Widget لعرض حالة الإشعارات في الإعدادات
class NotificationStatusWidget extends StatefulWidget {
  const NotificationStatusWidget({super.key});

  @override
  State<NotificationStatusWidget> createState() => _NotificationStatusWidgetState();
}

class _NotificationStatusWidgetState extends State<NotificationStatusWidget> {
  FirebaseMessagingService? _messagingService;
  RemoteConfigManager? _configManager;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  void _initializeServices() {
    try {
      // الحصول على الخدمات
      // _messagingService = getIt<FirebaseMessagingService>();
      // _configManager = getIt<RemoteConfigManager>();
    } catch (e) {
      debugPrint('Notification status widget: Services not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isServiceAvailable = _messagingService?.isInitialized ?? false;
    final isFeatureEnabled = _configManager?.isNotificationsFeatureEnabled ?? true;
    final hasPermission = _messagingService?.isPermissionGranted ?? false;
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'حالة الإشعارات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // حالة الخدمة
            _buildStatusRow(
              'خدمة Firebase',
              isServiceAvailable,
              isServiceAvailable ? 'متصلة' : 'غير متاحة',
            ),
            
            const SizedBox(height: 8),
            
            // حالة الميزة
            _buildStatusRow(
              'تفعيل الميزة',
              isFeatureEnabled,
              isFeatureEnabled ? 'مفعلة' : 'معطلة من الخادم',
            ),
            
            const SizedBox(height: 8),
            
            // حالة الإذن
            _buildStatusRow(
              'أذونات الجهاز',
              hasPermission,
              hasPermission ? 'ممنوحة' : 'مطلوبة',
            ),
            
            const SizedBox(height: 16),
            
            // معلومات إضافية
            if (_messagingService?.fcmToken != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'معرف الجهاز:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _messagingService!.fcmToken!.substring(0, 32) + '...',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, bool isActive, String status) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}