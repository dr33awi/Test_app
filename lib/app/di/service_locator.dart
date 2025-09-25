// lib/app/di/service_locator.dart
// DEPRECATED: This file is kept for backward compatibility
// Use lib/core/dependency_injection.dart for new implementations

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Import new dependency injection system
import '../../core/dependency_injection.dart';
import '../../core/services/service_extensions.dart';

final getIt = GetIt.instance;

/// Service Locator - DEPRECATED
/// 
/// This class is kept for backward compatibility.
/// New code should use DependencyInjection from lib/core/dependency_injection.dart
@deprecated
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  /// Initialize services - delegates to new DependencyInjection system
  static Future<void> init() async {
    debugPrint('ServiceLocator: Delegating to new DependencyInjection system...');
    await DependencyInjection.initialize();
  }

  /// Check if services are initialized
  static bool get isInitialized => DependencyInjection.isInitialized;

  /// Check if Firebase is available
  static bool get isFirebaseAvailable => DependencyInjection.isFirebaseAvailable;

  /// Check if services are ready
  static bool areServicesReady() => DependencyInjection.areServicesReady();

  /// Reset services
  static Future<void> reset() async => await DependencyInjection.reset();

  /// Dispose services
  static Future<void> dispose() async => await DependencyInjection.reset();
}

// ==================== Helper Functions ====================

/// Get service with type safety
T getService<T extends Object>() {
  if (!getIt.isRegistered<T>()) {
    throw Exception('Service $T is not registered. Make sure to call ServiceLocator.init() first.');
  }
  return getIt<T>();
}

/// Safe service access
T? getServiceSafe<T extends Object>() {
  try {
    return getIt.isRegistered<T>() ? getIt<T>() : null;
  } catch (e) {
    debugPrint('Error getting service $T: $e');
    return null;
  }
}
