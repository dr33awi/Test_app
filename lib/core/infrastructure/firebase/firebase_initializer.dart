import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../services/logging/logger_service.dart';

/// مهيئ Firebase
class FirebaseInitializer {
  static bool _isInitialized = false;
  
  /// تهيئة Firebase
  static Future<void> initialize({LoggerService? logger}) async {
    if (_isInitialized) {
      logger?.info('Firebase already initialized');
      return;
    }
    
    try {
      logger?.info('Initializing Firebase...');
      
      // تهيئة Firebase Core
      await Firebase.initializeApp();
      
      _isInitialized = true;
      logger?.info('Firebase initialized successfully ✓');
      
    } catch (e, stackTrace) {
      logger?.error('Failed to initialize Firebase: $e', stackTrace: stackTrace);
      
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
  static Future<void> reinitialize({LoggerService? logger}) async {
    _isInitialized = false;
    await initialize(logger: logger);
  }
}