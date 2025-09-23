// lib/core/infrastructure/firebase/firebase_messaging_service.dart

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/storage/storage_service.dart';
import '../services/logging/logger_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/models/notification_models.dart';

/// معالج الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  
  // يمكن إضافة معالجة مخصصة هنا
  if (message.data.isNotEmpty) {
    print('Background message data: ${message.data}');
  }
}

/// خدمة Firebase Messaging
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  late FirebaseMessaging _messaging;
  late LoggerService _logger;
  late StorageService _storage;
  late NotificationService _notificationService;
  
  bool _isInitialized = false;
  String? _fcmToken;
  
  // مجموعات الإشعارات
  static const String _prayerTopic = 'prayer_times';
  static const String _athkarTopic = 'athkar_reminders';
  static const String _generalTopic = 'general_notifications';
  static const String _updatesTopicArabic = 'updates_ar';
  static const String _updatesTopicEnglish = 'updates_en';

  /// تهيئة الخدمة
  Future<void> initialize({
    required LoggerService logger,
    required StorageService storage,
    required NotificationService notificationService,
  }) async {
    if (_isInitialized) return;
    
    _logger = logger;
    _storage = storage;
    _notificationService = notificationService;
    
    try {
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
      _logger.info(message: 'FirebaseMessagingService initialized successfully');
      
    } catch (e, stackTrace) {
      _logger.error(message: 'Error initializing Firebase Messaging: $e', stackTrace: stackTrace);
      throw Exception('Failed to initialize Firebase Messaging: $e');
    }
  }

  /// طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      _logger.info(message: 'Firebase Messaging permission status: ${settings.authorizationStatus}');
      
      // حفظ حالة الإذن
      await _storage.setBool('fcm_permission_granted', 
        settings.authorizationStatus == AuthorizationStatus.authorized);
        
    } catch (e) {
      _logger.error(message: 'Error requesting FCM permissions: $e');
    }
  }

  /// الحصول على FCM Token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      
      if (_fcmToken != null) {
        _logger.info(message: 'FCM Token: $_fcmToken');
        await _storage.setString('fcm_token', _fcmToken!);
        
        // يمكن إرسال التوكن للخادم هنا
        await _sendTokenToServer(_fcmToken!);
      }
      
      // الاستماع لتحديثات التوكن
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await _storage.setString('fcm_token', newToken);
        await _sendTokenToServer(newToken);
        _logger.info(message: 'FCM Token refreshed: $newToken');
      });
      
    } catch (e) {
      _logger.error(message: 'Error getting FCM token: $e');
    }
  }

  /// إرسال التوكن للخادم
  Future<void> _sendTokenToServer(String token) async {
    try {
      // TODO: إضافة API call لإرسال التوكن للخادم
      _logger.info(message: 'Token sent to server: $token');
      
      // حفظ وقت آخر إرسال
      await _storage.setString('last_token_sent', DateTime.now().toIso8601String());
      
    } catch (e) {
      _logger.error(message: 'Error sending token to server: $e');
    }
  }

  /// إعداد معالجي الرسائل
  void _setupMessageHandlers() {
    // معالج الرسائل عندما يكون التطبيق مفتوحاً
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.info(message: 'Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // معالج الرسائل عند النقر عليها
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.info(message: 'Message opened app: ${message.messageId}');
      _handleMessageOpened(message);
    });

    // معالج الرسائل عند فتح التطبيق من إشعار (عندما يكون مغلقاً)
    _handleInitialMessage();
  }

  /// معالجة الرسائل عندما يكون التطبيق مفتوحاً
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      // إنشاء إشعار محلي
      await _showLocalNotification(message);
      
      // معالجة البيانات
      await _processMessageData(message);
      
    } catch (e) {
      _logger.error(message: 'Error handling foreground message: $e');
    }
  }

  /// معالجة النقر على الإشعار
  Future<void> _handleMessageOpened(RemoteMessage message) async {
    try {
      _logger.info(message: 'User tapped notification: ${message.data}');
      
      // معالجة التنقل بناءً على البيانات
      await _handleNavigationFromNotification(message.data);
      
    } catch (e) {
      _logger.error(message: 'Error handling message opened: $e');
    }
  }

  /// معالجة الرسالة الأولية عند فتح التطبيق من إشعار
  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.info(message: 'App opened from notification: ${initialMessage.messageId}');
        await _handleMessageOpened(initialMessage);
      }
    } catch (e) {
      _logger.error(message: 'Error handling initial message: $e');
    }
  }

  /// عرض إشعار محلي للرسائل الواردة
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // استخراج البيانات
      final title = message.notification?.title ?? 'تطبيق الأذكار';
      final body = message.notification?.body ?? '';
      final data = message.data;
      
      // إنشاء NotificationData object
      final notificationData = NotificationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        category: _getNotificationCategory(data),
        priority: NotificationPriority.normal,
        payload: data,
      );
      
      // عرض الإشعار
      await _notificationService.showNotification(notificationData);
      
    } catch (e) {
      _logger.error(message: 'Error showing local notification: $e');
    }
  }

  /// تحديد فئة الإشعار
  NotificationCategory _getNotificationCategory(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'prayer':
        return NotificationCategory.prayer;
      case 'athkar':
        return NotificationCategory.athkar;
      case 'dua':
        return NotificationCategory.quran;
      default:
        return NotificationCategory.system;
    }
  }

  /// معالجة بيانات الرسالة
  Future<void> _processMessageData(RemoteMessage message) async {
    try {
      final data = message.data;
      final type = data['type'] as String?;
      
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
          _logger.info(message: 'Unknown notification type: $type');
      }
      
    } catch (e) {
      _logger.error(message: 'Error processing message data: $e');
    }
  }

  /// معالجة إشعارات الصلاة
  Future<void> _processPrayerNotification(Map<String, dynamic> data) async {
    final prayerName = data['prayer_name'] as String?;
    final prayerTime = data['prayer_time'] as String?;
    
    _logger.info(message: 'Prayer notification: $prayerName at $prayerTime');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة إشعارات الأذكار
  Future<void> _processAthkarNotification(Map<String, dynamic> data) async {
    final athkarType = data['athkar_type'] as String?;
    final athkarId = data['athkar_id'] as String?;
    
    _logger.info(message: 'Athkar notification: $athkarType, ID: $athkarId');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة إشعارات التحديثات
  Future<void> _processUpdateNotification(Map<String, dynamic> data) async {
    final updateType = data['update_type'] as String?;
    final version = data['version'] as String?;
    
    _logger.info(message: 'Update notification: $updateType, version: $version');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة إشعارات التذكير
  Future<void> _processReminderNotification(Map<String, dynamic> data) async {
    final reminderType = data['reminder_type'] as String?;
    final reminderText = data['reminder_text'] as String?;
    
    _logger.info(message: 'Reminder notification: $reminderType');
    
    // يمكن إضافة معالجة مخصصة هنا
  }

  /// معالجة التنقل من الإشعارات
  Future<void> _handleNavigationFromNotification(Map<String, dynamic> data) async {
    final action = data['action'] as String?;
    final route = data['route'] as String?;
    
    switch (action) {
      case 'open_prayer_times':
        // التنقل لشاشة مواقيت الصلاة
        break;
      case 'open_athkar':
        final athkarId = data['athkar_id'] as String?;
        // التنقل لشاشة الأذكار المحددة
        break;
      case 'open_qibla':
        // التنقل لشاشة القبلة
        break;
      default:
        if (route != null) {
          // التنقل للمسار المحدد
        }
    }
  }

  // ==================== إدارة المواضيع ====================

  /// الاشتراك في المواضيع الافتراضية
  Future<void> _subscribeToDefaultTopics() async {
    try {
      // الاشتراك في الموضوع العام
      await subscribeToTopic(_generalTopic);
      
      // الاشتراك بناءً على اللغة
      final language = _storage.getString('language') ?? 'ar';
      if (language == 'ar') {
        await subscribeToTopic(_updatesTopicArabic);
      } else {
        await subscribeToTopic(_updatesTopicEnglish);
      }
      
      _logger.info(message: 'Subscribed to default topics');
      
    } catch (e) {
      _logger.error(message: 'Error subscribing to default topics: $e');
    }
  }

  /// الاشتراك في موضوع
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.info(message: 'Subscribed to topic: $topic');
      
      // حفظ الاشتراكات
      final subscriptions = getSubscribedTopics();
      if (!subscriptions.contains(topic)) {
        subscriptions.add(topic);
        await _storage.setStringList('subscribed_topics', subscriptions);
      }
      
    } catch (e) {
      _logger.error(message: 'Error subscribing to topic $topic: $e');
    }
  }

  /// إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.info(message: 'Unsubscribed from topic: $topic');
      
      // تحديث الاشتراكات
      final subscriptions = getSubscribedTopics();
      subscriptions.remove(topic);
      await _storage.setStringList('subscribed_topics', subscriptions);
      
    } catch (e) {
      _logger.error(message: 'Error unsubscribing from topic $topic: $e');
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

  // ==================== تنظيف الموارد ====================

  /// إعادة تهيئة الخدمة
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize(
      logger: _logger,
      storage: _storage,
      notificationService: _notificationService,
    );
  }

  /// تنظيف الموارد
  void dispose() {
    _isInitialized = false;
    _fcmToken = null;
    _logger.info(message: 'FirebaseMessagingService disposed');
  }
}