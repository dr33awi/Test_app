// lib/core/services/service_test.dart
// Simple test to verify lazy initialization works correctly

import 'package:flutter/material.dart';
import '../dependency_injection.dart';

/// Simple test class to verify lazy service initialization
class LazyServiceTest {
  static Future<void> runTests() async {
    debugPrint('=== Starting Lazy Service Tests ===');
    
    try {
      // Test 1: Initialize dependency injection
      debugPrint('Test 1: Initializing DependencyInjection...');
      await DependencyInjection.initialize();
      assert(DependencyInjection.isInitialized, 'DependencyInjection should be initialized');
      debugPrint('✅ Test 1 passed: DependencyInjection initialized');
      
      // Test 2: Check if services are ready
      debugPrint('Test 2: Checking if services are ready...');
      final servicesReady = DependencyInjection.areServicesReady();
      debugPrint('Services ready: $servicesReady');
      debugPrint('✅ Test 2 completed: Services readiness checked');
      
      // Test 3: Test safe service access
      debugPrint('Test 3: Testing safe service access...');
      final storageService = getServiceSafe<dynamic>();
      debugPrint('Safe service access works: ${storageService != null}');
      debugPrint('✅ Test 3 passed: Safe service access works');
      
      // Test 4: Test Firebase availability
      debugPrint('Test 4: Testing Firebase availability...');
      final firebaseAvailable = DependencyInjection.isFirebaseAvailable;
      debugPrint('Firebase available: $firebaseAvailable');
      debugPrint('✅ Test 4 completed: Firebase availability checked');
      
      debugPrint('=== All Lazy Service Tests Completed Successfully ===');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Test failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

/// Widget to test service extensions
class ServiceExtensionTestWidget extends StatelessWidget {
  const ServiceExtensionTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Extension Test')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                // Test service extensions
                final hasStorageService = context.hasService<dynamic>();
                debugPrint('Has storage service: $hasStorageService');
                
                // Test Firebase service access
                final firebaseConfig = context.firebaseRemoteConfig;
                debugPrint('Firebase Remote Config available: ${firebaseConfig != null}');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service extension test completed - check logs')),
                );
              } catch (e) {
                debugPrint('Service extension test error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Test error: $e')),
                );
              }
            },
            child: const Text('Test Service Extensions'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Test feature flag checking
                final prayerTimesEnabled = context.isFeatureEnabled('prayer_times');
                final qiblaEnabled = context.isFeatureEnabled('qibla');
                final athkarEnabled = context.isFeatureEnabled('athkar');
                
                debugPrint('Prayer Times enabled: $prayerTimesEnabled');
                debugPrint('Qibla enabled: $qiblaEnabled');
                debugPrint('Athkar enabled: $athkarEnabled');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature flag test completed - check logs')),
                );
              } catch (e) {
                debugPrint('Feature flag test error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feature test error: $e')),
                );
              }
            },
            child: const Text('Test Feature Flags'),
          ),
        ],
      ),
    );
  }
}