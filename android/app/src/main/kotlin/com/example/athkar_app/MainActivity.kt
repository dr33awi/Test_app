package com.example.test_athkar_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * خدمة Firebase Messaging المخصصة
 */
class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MyFCMService"
        private const val CHANNEL_ID = "athkar_channel_id"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Firebase Messaging Service created")
        createNotificationChannel()
    }

    /**
     * يتم استدعاؤها عند تحديث التوكن
     */
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "New FCM token: $token")
        
        // حفظ التوكن الجديد
        saveTokenToPreferences(token)
        
        // إرسال التوكن للخادم (إذا لزم الأمر)
        sendTokenToServer(token)
    }

    /**
     * يتم استدعاؤها عند استلام رسالة
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d(TAG, "Message received from: ${remoteMessage.from}")
        Log.d(TAG, "Message data: ${remoteMessage.data}")
        Log.d(TAG, "Message notification: ${remoteMessage.notification}")

        // التحقق من وجود بيانات
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "Message data payload: ${remoteMessage.data}")
            handleDataMessage(remoteMessage.data)
        }

        // التحقق من وجود إشعار
        remoteMessage.notification?.let { notification ->
            Log.d(TAG, "Message notification body: ${notification.body}")
            showNotification(
                title = notification.title ?: "تطبيق الأذكار",
                body = notification.body ?: "",
                data = remoteMessage.data
            )
        }
    }

    /**
     * معالجة رسائل البيانات
     */
    private fun handleDataMessage(data: Map<String, String>) {
        val type = data["type"]
        val title = data["title"] ?: "تطبيق الأذكار"
        val body = data["body"] ?: ""
        
        Log.d(TAG, "Handling data message of type: $type")
        
        when (type) {
            "prayer" -> {
                val prayerName = data["prayer_name"] ?: ""
                val prayerTime = data["prayer_time"] ?: ""
                showNotification("حان الآن وقت $prayerName", "الوقت: $prayerTime", data)
            }
            "athkar" -> {
                val athkarType = data["athkar_type"] ?: ""
                showNotification("تذكير بالأذكار", "حان وقت $athkarType", data)
            }
            "reminder" -> {
                showNotification(title, body, data)
            }
            else -> {
                if (title.isNotEmpty() || body.isNotEmpty()) {
                    showNotification(title, body, data)
                }
            }
        }
    }

    /**
     * عرض الإشعار
     */
    private fun showNotification(title: String, body: String, data: Map<String, String> = emptyMap()) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // إنشاء Intent لفتح التطبيق
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            // إضافة البيانات للـ Intent
            data.forEach { (key, value) ->
                putExtra(key, value)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            NOTIFICATION_ID,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // بناء الإشعار
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))

        // إضافة لون للإشعار
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder.setColor(resources.getColor(R.color.notification_color, null))
        }

        // عرض الإشعار
        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
        
        Log.d(TAG, "Notification shown: $title - $body")
    }

    /**
     * إنشاء قناة الإشعارات (Android O+)
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = "أذكار"
            val channelDescription = "إشعارات تطبيق الأذكار"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(CHANNEL_ID, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                enableLights(true)
                setBypassDnd(true) // السماح بتجاوز وضع عدم الإزعاج
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            
            Log.d(TAG, "Notification channel created: $CHANNEL_ID")
        }
    }

    /**
     * حفظ التوكن محلياً
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
            Log.e(TAG, "Error saving token: ${e.message}", e)
        }
    }

    /**
     * إرسال التوكن للخادم
     */
    private fun sendTokenToServer(token: String) {
        Log.d(TAG, "Sending token to server: $token")
        
        // TODO: إضافة كود إرسال التوكن للخادم
        // يمكن استخدام Retrofit أو أي مكتبة HTTP أخرى
        
        // مثال على الاستخدام:
        // ApiService.sendTokenToServer(token)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Firebase Messaging Service destroyed")
    }
}