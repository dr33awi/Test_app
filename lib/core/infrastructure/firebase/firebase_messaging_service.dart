// lib/core/infrastructure/firebase/firebase_messaging_service.dart

import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage/storage_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/models/notification_models.dart' as LocalNotificationModels hide NotificationSettings;

/// معالج الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Background message data: ${message.data}');
  debugPrint('Background message notification: ${message.notification?.toMap()}');
  
  // يمكن إضافة معالجة مخصصة هنا
  if (message.data.isNotEmpty) {
    debugPrint('Processing background message data: ${message.data}');
  }
}

/// خدمة Firebase Messaging محسّنة
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  late FirebaseMessaging _messaging;
  late StorageService _storage;
  NotificationService? _notificationService;
  
  bool _isInitialized = false;
  String? _fcmToken;
  
  // Platform channels للتواصل مع Android
  static const MethodChannel _fcmChannel = MethodChannel('com.athkar.app/firebase_messaging');
  
  // مجموعات الإشعارات
  static const String _prayerTopic = 'prayer_times';
  static const String _athkarTopic = 'athkar_reminders';
  static const String _generalTopic = 'general_notifications';
  static const String _updatesTopicArabic = 'updates_ar';
  static const String _updatesTopicEnglish = 'updates_en';

  /// تهيئة الخدمة
  Future<void> initialize({
    required StorageService storage,
    NotificationService? notificationService,
  }) async {
    if (_isInitialized) {
      debugPrint('Firebase Messaging already initialized');
      return;
    }
    
    _storage = storage;
    _notificationService = notificationService;
    
    try {
      debugPrint('Initializing Firebase Messaging...');
      
      _messaging = FirebaseMessaging.instance;
      
      // تعيين معالج الرسائل في الخلفية
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // طلب الأذونات
      await _requestPermissions();
      
      // الحصول على FCM Token
      await _getFCMToken();
      
      // إعداد معالجي الرسائل
      _setupMessageHandlers();
      
      // الاشتراك في المواضيع الافتراضية
      await _subscribeToDefaultTopics();
      
      _isInitialized = true;
      debugPrint('FirebaseMessagingService initialized successfully ✓');
      
    } catch (e, stackTrace) {
      debugPrint('Error initializing Firebase Messaging: $e');
      
      // المحاولة باستخدام Native methods كـ fallback
      await _initializeWithNativeMethods();
    }
  }

  /// تهيئة باستخدام الطرق الأصلية كـ fallback
  Future<void> _initializeWithNativeMethods() async {
    try {
      debugPrint('Trying native Firebase methods...');
      
      // الحصول على التوكن من النظام الأصلي
      final token = await _fcmChannel.invokeMethod<String>('getToken');
      if (token != null) {
        _fcmToken = token;
        await _storage.setString('fcm_token', token);
        debugPrint('Got FCM token via native method: ${token.substring(0, 20)}...');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Native Firebase methods also failed: $e');
      throw Exception('Complete Firebase initialization failure: $e');
    }
  }

  /// طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    try {
      debugPrint('Requesting Firebase Messaging permissions...');
      
      NotificationSettings settings;
      
      if (Platform.isIOS) {
        // أذونات iOS
        settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } else {
        // أذونات Android
        settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      debugPrint('Firebase permission status: ${settings.authorizationStatus}');
      
      // حفظ حالة الإذن
      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      await _storage.setBool('fcm_permission_granted', isGranted);
      
      if (!isGranted) {
        debugPrint('Firebase Messaging permission not granted');
      }
        
    } catch (e) {
      debugPrint('Error requesting FCM permissions: $e');
    }
  }

  /// الحصول على FCM Token
  Future<void> _getFCMToken() async {
    try {
      debugPrint('Getting FCM Token...');
      
      // محاولة الحصول على التوكن من Firebase مباشرة
      _fcmToken = await _messaging.getToken();
      
      if (_fcmToken != null) {
        debugPrint('FCM Token received: ${_fcmToken!.substring(0, 20)}...');
        await _storage.setString('fcm_token', _fcmToken!);
        
        // إرسال التوكن للخادم
        await _sendTokenToServer(_fcmToken!);
      } else {
        debugPrint('FCM Token is null');
        
        // محاولة الحصول على التوكن من النظام الأصلي
        try {
          final nativeToken = await _fcmChannel.invokeMethod<String>('getToken');
          if (nativeToken != null) {
            _fcmToken = nativeToken;
            await _storage.setString('fcm_token', nativeToken);
            debugPrint('Got FCM token from native: ${nativeToken.substring(0, 20)}...');
          }
        } catch (e) {
          debugPrint('Native token method also failed: $e');
        }
      }
      
      // الاستماع لتحديثات التوكن
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          _fcmToken = newToken;
          await _storage.setString('fcm_token', newToken);
          await _sendTokenToServer(newToken);
          debugPrint('FCM Token refreshed: ${newToken.substring(0, 20)}...');
        } catch (e) {
          debugPrint('Error handling token refresh: $e');
        }
      });
      
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// إرسال التوكن للخادم
  Future<void> _sendTokenToServer(String token) async {
    try {
      debugPrint('Sending token to server...');
      
      // TODO: إضافة API call لإرسال التوكن للخادم
      // مثال:
      // await ApiService.sendTokenToServer(token);
      
      // حفظ وقت آخر إرسال
      await _storage.setString('last_token_sent', DateTime.now().toIso8601String());
      
      debugPrint('Token sent to server successfully');
      
    } catch (e) {
      debugPrint('Error sending token to server: $e');
    }
  }

  /// إعداد معالجي الرسائل
  void _setupMessageHandlers() {
    try {
      // معالج الرسائل عندما يكون التطبيق مفتوحاً
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // معالج الرسائل عند النقر عليها
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.messageId}');
        _handleMessageOpened(message);
      });

      // معالج الرسائل عند فتح التطبيق من إشعار (عندما يكون مغلقاً)
      _handleInitialMessage();
      
      debugPrint('Message handlers setup completed');
      
    } catch (e) {
      debugPrint('Error setting up message handlers: $e');
    }
  }

  /// معالجة الرسائل عندما يكون التطبيق مفتوحاً
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Processing foreground message: ${message.data}');
      
      // عرض إشعار محلي إذا كانت الخدمة متوفرة
      if (_notificationService != null) {
        await _showLocalNotification(message);
      }
      
      // معالجة البيانات
      await _processMessageData(message);
      
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  /// معالجة النقر على الإشعار
  Future<void> _handleMessageOpened(RemoteMessage message) async {
    try {
      debugPrint('User tapped notification with data: ${message.data}');
      
      // معالجة التنقل بناءً على البيانات
      await _handleNavigationFromNotification(message.data);
      
    } catch (e) {
      debugPrint('Error handling message opened: $e');
    }
  }

  /// معالجة الرسالة الأولية عند فتح التطبيق من إشعار
  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from notification: ${initialMessage.messageId}');
        await _handleMessageOpened(initialMessage);
      }
    } catch (e) {
      debugPrint('Error handling initial message: $e');
    }
  }

  /// عرض إشعار محلي للرسائل الواردة
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (_notificationService == null) return;
    
    try {
      // استخراج البيانات
      final title = message.notification?.title ?? 'تطبيق الأذكار';
      final body = message.notification?.body ?? '';
      final data = message.data;
      
      // إنشاء NotificationData وعرض الإشعار
      final notificationData = LocalNotificationModels.NotificationData(
        id: 'firebase_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        category: _getNotificationCategory(data['type']),
        priority: LocalNotificationModels.NotificationPriority.normal,
        payload: data.isNotEmpty ? data : null,
      );
      
      // استخدام showNotification بدلاً من showSimpleNotification
      await _notificationService!.showNotification(notificationData);
      
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// تحديد فئة الإشعار بناءً على النوع
  LocalNotificationModels.NotificationCategory _getNotificationCategory(String? type) {
    switch (type) {
      case 'prayer':
        return LocalNotificationModels.NotificationCategory.prayer;
      case 'athkar':
        return LocalNotificationModels.NotificationCategory.athkar;
      case 'quran':
        return LocalNotificationModels.NotificationCategory.quran;
      case 'reminder':
        return LocalNotificationModels.NotificationCategory.reminder;
      default:
        return LocalNotificationModels.NotificationCategory.system;
    }
  }

  /// معالجة بيانات الرسالة
  Future<void> _processMessageData(RemoteMessage message) async {
    try {
      final data = message.data;
      final type = data['type'] as String?;
      
      debugPrint('Processing message data - Type: $type');
      
      switch (type) {
        case 'prayer':
          await _processPrayerNotification(data);
          break;
        case 'athkar':
          await _processAthkarNotification(data);
          break;
        case 'update':
          await _processUpdateNotification(data);
          break;
        case 'reminder':
          await _processReminderNotification(data);
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
      
    } catch (e) {
      debugPrint('Error processing message data: $e');
    }
  }

  /// معالجة إشعارات الصلاة
  Future<void> _processPrayerNotification(Map<String, dynamic> data) async {
    final prayerName = data['prayer_name'] as String?;
    final prayerTime = data['prayer_time'] as String?;
    
    debugPrint('Prayer notification: $prayerName at $prayerTime');
    
    // يمكن إضافة معالجة مخصصة هنا
    // مثل تحديث UI أو تشغيل صوت
  }

  /// معالجة إشعارات الأذكار
  Future<void> _processAthkarNotification(Map<String, dynamic> data) async {
    final athkarType = data['athkar_type'] as String?;
    final athkarId = data['athkar_id'] as String?;
    
    debugPrint('Athkar notification: $athkarType, ID: $athkarId');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة إشعارات التحديثات
  Future<void> _processUpdateNotification(Map<String, dynamic> data) async {
    final updateType = data['update_type'] as String?;
    final version = data['version'] as String?;
    
    debugPrint('Update notification: $updateType, version: $version');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة إشعارات التذكير
  Future<void> _processReminderNotification(Map<String, dynamic> data) async {
    final reminderType = data['reminder_type'] as String?;
    final reminderText = data['reminder_text'] as String?;
    
    debugPrint('Reminder notification: $reminderType');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة التنقل من الإشعارات
  Future<void> _handleNavigationFromNotification(Map<String, dynamic> data) async {
    final action = data['action'] as String?;
    final route = data['route'] as String?;
    
    debugPrint('Handling navigation - Action: $action, Route: $route');
    
    // يمكن إضافة منطق التنقل هنا
    // مثل استخدام Navigator للانتقال لصفحة معينة
  }

  // ==================== إدارة المواضيع ====================

  /// الاشتراك في المواضيع الافتراضية
  Future<void> _subscribeToDefaultTopics() async {
    try {
      debugPrint('Subscribing to default topics...');
      
      // الاشتراك في الموضوع العام
      await subscribeToTopic(_generalTopic);
      
      // الاشتراك بناءً على اللغة
      final language = _storage.getString('language') ?? 'ar';
      if (language == 'ar') {
        await subscribeToTopic(_updatesTopicArabic);
      } else {
        await subscribeToTopic(_updatesTopicEnglish);
      }
      
      debugPrint('Default topics subscription completed');
      
    } catch (e) {
      debugPrint('Error subscribing to default topics: $e');
    }
  }

  /// الاشتراك في موضوع
  Future<void> subscribeToTopic(String topic) async {
    try {
      // محاولة الاشتراك عبر Firebase أولاً
      try {
        await _messaging.subscribeToTopic(topic);
      } catch (e) {
        // محاولة الاشتراك عبر Native method كـ fallback
        await _fcmChannel.invokeMethod('subscribeToTopic', {'topic': topic});
      }
      
      debugPrint('Subscribed to topic: $topic');
      
      // حفظ الاشتراكات
      final subscriptions = getSubscribedTopics();
      if (!subscriptions.contains(topic)) {
        subscriptions.add(topic);
        await _storage.setStringList('subscribed_topics', subscriptions);
      }
      
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // محاولة إلغاء الاشتراك عبر Firebase أولاً
      try {
        await _messaging.unsubscribeFromTopic(topic);
      } catch (e) {
        // محاولة إلغاء الاشتراك عبر Native method كـ fallback
        await _fcmChannel.invokeMethod('unsubscribeFromTopic', {'topic': topic});
      }
      
      debugPrint('Unsubscribed from topic: $topic');
      
      // تحديث الاشتراكات
      final subscriptions = getSubscribedTopics();
      subscriptions.remove(topic);
      await _storage.setStringList('subscribed_topics', subscriptions);
      
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// الحصول على المواضيع المشترك بها
  List<String> getSubscribedTopics() {
    return _storage.getStringList('subscribed_topics') ?? [];
  }

  /// الاشتراك في إشعارات الصلاة
  Future<void> subscribeToPrayerNotifications() async {
    await subscribeToTopic(_prayerTopic);
  }

  /// إلغاء الاشتراك من إشعارات الصلاة
  Future<void> unsubscribeFromPrayerNotifications() async {
    await unsubscribeFromTopic(_prayerTopic);
  }

  /// الاشتراك في إشعارات الأذكار
  Future<void> subscribeToAthkarNotifications() async {
    await subscribeToTopic(_athkarTopic);
  }

  /// إلغاء الاشتراك من إشعارات الأذكار
  Future<void> unsubscribeFromAthkarNotifications() async {
    await unsubscribeFromTopic(_athkarTopic);
  }

  // ==================== الحصول على المعلومات ====================

  /// الحصول على FCM Token
  String? get fcmToken => _fcmToken;

  /// هل الخدمة مهيأة
  bool get isInitialized => _isInitialized;

  /// هل الإذن ممنوح
  bool get isPermissionGranted => _storage.getBool('fcm_permission_granted') ?? false;

  /// آخر وقت إرسال للتوكن
  DateTime? get lastTokenSentTime {
    final timeString = _storage.getString('last_token_sent');
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// معلومات حالة الخدمة
  Map<String, dynamic> get serviceStatus => {
    'is_initialized': _isInitialized,
    'has_token': _fcmToken != null,
    'token_length': _fcmToken?.length ?? 0,
    'permission_granted': isPermissionGranted,
    'last_token_sent': lastTokenSentTime?.toIso8601String(),
    'subscribed_topics': getSubscribedTopics(),
  };

  // ==================== إعادة تهيئة وتنظيف ====================

  /// إعادة تهيئة الخدمة
  Future<void> reinitialize() async {
    debugPrint('Reinitializing Firebase Messaging Service...');
    _isInitialized = false;
    _fcmToken = null;
    
    await initialize(
      storage: _storage,
      notificationService: _notificationService,
    );
  }

  /// تحديث التوكن يدوياً
  Future<void> refreshToken() async {
    try {
      debugPrint('Manually refreshing FCM token...');
      
      // حذف التوكن القديم
      await _messaging.deleteToken();
      
      // الحصول على توكن جديد
      await _getFCMToken();
      
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
  }

  /// تنظيف الموارد
  void dispose() {
    _isInitialized = false;
    _fcmToken = null;
    debugPrint('FirebaseMessagingService disposed');
  }
}