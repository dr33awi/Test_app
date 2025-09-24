package com.example.test_athkar_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    private val DND_CHANNEL = "com.athkar.app/do_not_disturb"
    private val DND_EVENTS_CHANNEL = "com.athkar.app/do_not_disturb_events"
    private val BATTERY_CHANNEL = "com.athkar.app/battery_optimization"
    private val FCM_CHANNEL = "com.athkar.app/firebase_messaging"
    
    private var doNotDisturbHandler: DoNotDisturbHandler? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // تهيئة Firebase Messaging Token
        initializeFirebaseMessaging()
        
        // معالجة البيانات من الإشعارات عند فتح التطبيق
        handleNotificationData(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // معالجة البيانات عند النقر على إشعار والتطبيق مفتوح
        handleNotificationData(intent)
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // إنشاء DND handler
        doNotDisturbHandler = DoNotDisturbHandler(applicationContext)
        
        // إعداد Method Channels
        setupMethodChannels(flutterEngine)
        
        // إعداد Event Channels
        setupEventChannels(flutterEngine)
        
        // تكوين قنوات الإشعارات
        doNotDisturbHandler?.configureNotificationChannelsForDoNotDisturb()
    }
    
    private fun setupMethodChannels(flutterEngine: FlutterEngine) {
        // قناة Do Not Disturb
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DND_CHANNEL)
            .setMethodCallHandler(doNotDisturbHandler)
        
        // قناة Battery Optimization
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isBatteryOptimizationEnabled" -> {
                        result.success(isBatteryOptimizationEnabled())
                    }
                    "requestBatteryOptimizationDisable" -> {
                        result.success(requestBatteryOptimizationDisable())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        
        // قناة Firebase Messaging
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FCM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getToken" -> {
                        getFirebaseToken(result)
                    }
                    "deleteToken" -> {
                        deleteFirebaseToken(result)
                    }
                    "subscribeToTopic" -> {
                        val topic = call.argument<String>("topic")
                        if (topic != null) {
                            subscribeToTopic(topic, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Topic is required", null)
                        }
                    }
                    "unsubscribeFromTopic" -> {
                        val topic = call.argument<String>("topic")
                        if (topic != null) {
                            unsubscribeFromTopic(topic, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Topic is required", null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    private fun setupEventChannels(flutterEngine: FlutterEngine) {
        // قناة أحداث Do Not Disturb
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DND_EVENTS_CHANNEL)
            .setStreamHandler(
                doNotDisturbHandler?.getDndStreamHandler() ?: object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {}
                    override fun onCancel(arguments: Any?) {}
                }
            )
    }
    
    /**
     * تهيئة Firebase Messaging والحصول على التوكن
     */
    private fun initializeFirebaseMessaging() {
        try {
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.w(TAG, "Fetching FCM registration token failed", task.exception)
                    return@addOnCompleteListener
                }

                // الحصول على التوكن
                val token = task.result
                Log.d(TAG, "FCM Registration Token: $token")
                
                // حفظ التوكن محلياً
                saveTokenToPreferences(token)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Firebase Messaging: ${e.message}", e)
        }
    }
    
    /**
     * معالجة بيانات الإشعارات
     */
    private fun handleNotificationData(intent: Intent?) {
        try {
            intent?.extras?.let { extras ->
                val data = mutableMapOf<String, String>()
                
                for (key in extras.keySet()) {
                    val value = extras.get(key)
                    if (value is String) {
                        data[key] = value
                    }
                }
                
                if (data.isNotEmpty()) {
                    Log.d(TAG, "Notification data received: $data")
                    
                    // يمكنك معالجة البيانات هنا أو إرسالها لـ Flutter
                    // sendNotificationDataToFlutter(data)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling notification data: ${e.message}", e)
        }
    }
    
    /**
     * حفظ التوكن في Shared Preferences
     */
    private fun saveTokenToPreferences(token: String) {
        try {
            val sharedPref = getSharedPreferences("firebase_prefs", Context.MODE_PRIVATE)
            with(sharedPref.edit()) {
                putString("fcm_token", token)
                putLong("token_timestamp", System.currentTimeMillis())
                apply()
            }
            Log.d(TAG, "Token saved to preferences")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving token to preferences: ${e.message}", e)
        }
    }
    
    // ==================== Firebase Messaging Methods ====================
    
    /**
     * الحصول على Firebase Token
     */
    private fun getFirebaseToken(result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val token = task.result
                result.success(token)
            } else {
                result.error("TOKEN_ERROR", "Failed to get FCM token", task.exception?.message)
            }
        }
    }
    
    /**
     * حذف Firebase Token
     */
    private fun deleteFirebaseToken(result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().deleteToken().addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(true)
            } else {
                result.error("DELETE_ERROR", "Failed to delete FCM token", task.exception?.message)
            }
        }
    }
    
    /**
     * الاشتراك في موضوع
     */
    private fun subscribeToTopic(topic: String, result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().subscribeToTopic(topic).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                Log.d(TAG, "Subscribed to topic: $topic")
                result.success(true)
            } else {
                Log.e(TAG, "Failed to subscribe to topic: $topic", task.exception)
                result.error("SUBSCRIBE_ERROR", "Failed to subscribe to topic", task.exception?.message)
            }
        }
    }
    
    /**
     * إلغاء الاشتراك من موضوع
     */
    private fun unsubscribeFromTopic(topic: String, result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().unsubscribeFromTopic(topic).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                Log.d(TAG, "Unsubscribed from topic: $topic")
                result.success(true)
            } else {
                Log.e(TAG, "Failed to unsubscribe from topic: $topic", task.exception)
                result.error("UNSUBSCRIBE_ERROR", "Failed to unsubscribe from topic", task.exception?.message)
            }
        }
    }
    
    // ==================== Battery Optimization Methods ====================
    
    /**
     * التحقق من تفعيل تحسين البطارية
     */
    private fun isBatteryOptimizationEnabled(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val packageName = packageName
            return !powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return false
    }
    
    /**
     * طلب تعطيل تحسين البطارية
     */
    private fun requestBatteryOptimizationDisable(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent()
            val packageName = packageName
            
            intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
            intent.data = Uri.parse("package:$packageName")
            
            try {
                startActivity(intent)
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Error requesting battery optimization disable", e)
                try {
                    val settingsIntent = Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
                    startActivity(settingsIntent)
                    return true
                } catch (e2: Exception) {
                    Log.e(TAG, "Error opening battery settings", e2)
                    return false
                }
            }
        }
        return false
    }
    
    override fun onResume() {
        super.onResume()
        // إشعار مستمعي DND بتغييرات محتملة
        doNotDisturbHandler?.notifyDndStatusChange()
    }
}