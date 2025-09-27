// lib/main.dart - مبسط للغة العربية فقط

import 'dart:async';
import 'package:athkar_app/core/infrastructure/services/permissions/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Service Locator والخدمات
import 'app/di/service_locator.dart';
import 'app/themes/core/theme_notifier.dart';
import 'core/infrastructure/services/permissions/permission_manager.dart';
import 'core/infrastructure/services/permissions/widgets/permission_monitor.dart';
import 'core/infrastructure/services/permissions/screens/permission_onboarding_screen.dart';

// Firebase services
import 'core/infrastructure/firebase/firebase_initializer.dart';

// الثيمات والمسارات
import 'app/themes/app_theme.dart';
import 'app/routes/app_router.dart';

// الشاشات
import 'features/home/screens/home_screen.dart';

/// نقطة دخول التطبيق - مبسط تماماً
Future<void> main() async {
  // تهيئة ربط Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // تعيين اتجاه التطبيق (عمودي فقط)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // تشغيل التطبيق مع معالجة الأخطاء
  runZonedGuarded(
    () async {
      try {
        // تهيئة جميع الخدمات
        await _initializeApp();
        
        // تحديد الشاشة الأولى
        final permissionManager = getIt<UnifiedPermissionManager>();
        final initialRoute = _determineInitialRoute(permissionManager);
        
        // تشغيل التطبيق
        runApp(AthkarApp(initialRoute: initialRoute));
        
      } catch (e, s) {
        debugPrint('خطأ في تشغيل التطبيق: $e');
        debugPrint('Stack trace: $s');
        
        // عرض شاشة الخطأ
        runApp(_ErrorApp(error: e.toString()));
      }
    },
    (error, stack) {
      // معالجة الأخطاء غير المتوقعة
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

/// تهيئة التطبيق والخدمات
Future<void> _initializeApp() async {
  debugPrint('========== بدء تهيئة التطبيق ==========');
  
  try {
    // 1. تهيئة Firebase أولاً
    debugPrint('تهيئة Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ تمت تهيئة Firebase بنجاح');
    
    // 2. تهيئة ServiceLocator
    await ServiceLocator.init();
    
    // 3. تهيئة Firebase services إضافية (اختياري)
    try {
      await FirebaseInitializer.initialize();
      debugPrint('✅ تمت تهيئة خدمات Firebase الإضافية');
    } catch (e) {
      debugPrint('⚠️ تحذير: بعض خدمات Firebase غير متوفرة: $e');
      // المتابعة بدون Firebase services
    }
    
    // 4. التحقق من جاهزية الخدمات
    if (!ServiceLocator.areServicesReady()) {
      throw Exception('فشل في تهيئة بعض الخدمات المطلوبة');
    }
    
    debugPrint('========== تمت تهيئة التطبيق بنجاح ==========');
    
  } catch (e, s) {
    debugPrint('❌ خطأ في تهيئة التطبيق: $e');
    debugPrint('Stack trace: $s');
    rethrow;
  }
}

/// تحديد المسار الأولي بناءً على حالة المستخدم
String _determineInitialRoute(UnifiedPermissionManager permissionManager) {
  // إذا كان المستخدم جديد، عرض شاشة Onboarding
  if (permissionManager.isNewUser) {
    debugPrint('مستخدم جديد - عرض شاشة Onboarding');
    return '/onboarding';
  }
  
  // مستخدم عائد - عرض الشاشة الرئيسية
  debugPrint('مستخدم عائد - عرض الشاشة الرئيسية');
  return AppRouter.home;
}

/// التطبيق الرئيسي - مبسط للعربية فقط
class AthkarApp extends StatefulWidget {
  final String initialRoute;
  
  const AthkarApp({
    super.key, 
    required this.initialRoute,
  });

  @override
  State<AthkarApp> createState() => _AthkarAppState();
}

class _AthkarAppState extends State<AthkarApp> {
  late final UnifiedPermissionManager _permissionManager;
  
  // متغير للتحكم في تفعيل المراقب
  bool _enableMonitor = true;
  
  @override
  void initState() {
    super.initState();
    
    _permissionManager = getIt<UnifiedPermissionManager>();
    
    // تعطيل المراقب مؤقتاً إذا كنا قادمين من Onboarding
    if (_permissionManager.isNewUser) {
      _enableMonitor = false;
    }
    
    // فحص أولي واحد فقط للمستخدمين العائدين
    if (!_permissionManager.isNewUser) {
      _performInitialCheck();
    }
  }
  
  /// فحص أولي واحد عند بدء التطبيق
  Future<void> _performInitialCheck() async {
    // تأخير قصير لضمان تحميل الواجهة
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted && !_permissionManager.hasCheckedThisSession) {
      debugPrint('[AthkarApp] Performing initial permission check');
      await _permissionManager.performInitialCheck();
    }
  }
  
  /// تفعيل المراقب بعد الانتهاء من Onboarding
  void _enableMonitorAfterOnboarding() {
    // تأخير لمدة 3 ثواني بعد الانتهاء من Onboarding
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _enableMonitor = true;
        });
        debugPrint('[AthkarApp] Monitor enabled after onboarding delay');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: getIt<ThemeNotifier>(),
      builder: (context, themeMode, child) {
        return MaterialApp(
          // معلومات التطبيق
          title: 'تطبيق الأذكار',
          debugShowCheckedModeBanner: false,
          
          // الثيمات
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          
          // اللغة العربية فقط
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'), // العربية فقط
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          // التنقل
          navigatorKey: AppRouter.navigatorKey,
          initialRoute: widget.initialRoute,
          
          // المسارات
          routes: {
            AppRouter.home: (context) => const HomeScreen(),
            '/onboarding': (context) => _OnboardingWrapper(
              onComplete: _enableMonitorAfterOnboarding,
            ),
          },
          
          // توليد المسارات الديناميكية
          onGenerateRoute: AppRouter.onGenerateRoute,
          
          // Builder لتطبيق المراقب الخفيف على جميع الشاشات
          builder: (context, child) {
            if (child == null) return const SizedBox();
            
            // لا نطبق المراقب على شاشة Onboarding
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute == '/onboarding') {
              return child;
            }
            
            // تطبيق مراقب الأذونات الخفيف (فقط إذا كان مفعلاً)
            if (_enableMonitor) {
              return PermissionMonitor(
                showNotifications: true,
                child: child,
              );
            }
            
            // إرجاع الشاشة بدون مراقب
            return child;
          },
        );
      },
    );
  }
}

/// Wrapper لشاشة Onboarding
class _OnboardingWrapper extends StatelessWidget {
  final VoidCallback? onComplete;
  
  const _OnboardingWrapper({this.onComplete});
  
  @override
  Widget build(BuildContext context) {
    final permissionService = getIt<PermissionService>();
    final permissionManager = getIt<UnifiedPermissionManager>();
    
    return PermissionOnboardingScreen(
      permissionService: permissionService,
      onComplete: (result) async {
        // حفظ حالة Onboarding
        await permissionManager.completeOnboarding(
          skipped: result.skipped,
          grantedPermissions: result.selectedPermissions,
        );
        
        // استدعاء callback لتفعيل المراقب لاحقاً
        onComplete?.call();
        
        // الانتقال للشاشة الرئيسية
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            (route) => false,
          );
        }
      },
    );
  }
}

/// شاشة الخطأ - باللغة العربية فقط
class _ErrorApp extends StatelessWidget {
  final String error;
  
  const _ErrorApp({required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: AppTheme.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الخطأ مع تأثير حركي
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red.shade700,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // العنوان
                    const Text(
                      'عذراً، حدث خطأ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // الوصف
                    const Text(
                      'حدث خطأ أثناء تهيئة التطبيق\nيرجى إعادة المحاولة',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        height: 1.5,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // تفاصيل الخطأ
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'تفاصيل تقنية',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // زر إعادة المحاولة
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // إعادة تشغيل التطبيق
                          main();
                        },
                        icon: const Icon(
                          Icons.refresh,
                          size: 24,
                        ),
                        label: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // معلومات الدعم
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'إذا استمرت المشكلة، يرجى التواصل مع الدعم الفني',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}