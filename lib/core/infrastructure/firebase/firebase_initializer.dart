// lib/core/infrastructure/firebase/firebase_initializer.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// مهيئ Firebase
class FirebaseInitializer {
  static bool _isInitialized = false;
  
  /// تهيئة Firebase
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Firebase already initialized');
      return;
    }
    
    try {
      debugPrint('Initializing Firebase...');
      
      // تهيئة Firebase Core
      await Firebase.initializeApp();
      
      _isInitialized = true;
      debugPrint('Firebase initialized successfully ✓');
      
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      
      // في حالة الخطأ، نحاول المتابعة بدون Firebase
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: $e');
        debugPrint('App will continue without Firebase services');
      }
      
      throw Exception('Firebase initialization failed: $e');
    }
  }
  
  /// التحقق من تهيئة Firebase
  static bool get isInitialized => _isInitialized;
  
  /// إعادة تهيئة Firebase
  static Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
  
  /// تنظيف Firebase (للاستخدام في التطوير)
  static void dispose() {
    _isInitialized = false;
  }
}