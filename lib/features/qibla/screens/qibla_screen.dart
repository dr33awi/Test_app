// lib/features/qibla/screens/qibla_screen.dart - نسخة محسنة ومبسطة
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../services/qibla_service.dart';
import '../widgets/qibla_compass.dart';
import '../widgets/qibla_info_card.dart';
import '../widgets/qibla_accuracy_helper.dart';

/// شاشة القبلة المبسطة
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late final QiblaService _qiblaService;
  late final LoggerService _logger;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// تهيئة الشاشة
  Future<void> _initializeScreen() async {
    _logger = getIt<LoggerService>();
    
    // إنشاء الخدمة
    _qiblaService = QiblaService(
      logger: _logger,
      storage: getIt<StorageService>(),
      permissionService: getIt<PermissionService>(),
    );

    // التحديث التلقائي كل 10 دقائق
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _qiblaService.updateQiblaData(),
    );

    // التحديث الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _qiblaService.updateQiblaData();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _qiblaService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: ChangeNotifierProvider.value(
        value: _qiblaService,
        child: Consumer<QiblaService>(
          builder: (context, service, _) {
            return SafeArea(
              child: Column(
                children: [
                  // شريط العنوان
                  _buildAppBar(context, service),
                  
                  // المحتوى الرئيسي
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: service.forceUpdate,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(ThemeConstants.space4),
                        child: Column(
                          children: [
                            // البوصلة أو رسالة الحالة
                            _buildMainContent(context, service),
                            
                            ThemeConstants.space4.h,
                            
                            // معلومات القبلة
                            if (service.qiblaData != null)
                              QiblaInfoCard(qiblaData: service.qiblaData!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// بناء شريط العنوان
  Widget _buildAppBar(BuildContext context, QiblaService service) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          
          // العنوان
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اتجاه القبلة',
                  style: context.titleLarge?.bold,
                ),
                if (service.qiblaData != null)
                  Text(
                    'الاتجاه: ${service.qiblaData!.qiblaDirection.toStringAsFixed(1)}°',
                    style: context.bodySmall?.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // زر التحديث
          if (service.isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: service.forceUpdate,
              icon: Icon(
                Icons.refresh,
                color: context.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  /// بناء المحتوى الرئيسي
  Widget _buildMainContent(BuildContext context, QiblaService service) {
    // حالة التحميل
    if (service.isLoading && service.qiblaData == null) {
      return _buildLoadingState(context);
    }

    // حالة الخطأ
    if (service.errorMessage != null && service.qiblaData == null) {
      return _buildErrorState(context, service);
    }

    // البوصلة
    if (service.qiblaData != null) {
      return _buildCompassView(context, service);
    }

    // الحالة الأولية
    return _buildInitialState(context, service);
  }

  /// بناء حالة التحميل
  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          ThemeConstants.space4.h,
          Text(
            'جاري تحديد موقعك...',
            style: context.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// بناء حالة الخطأ
  Widget _buildErrorState(BuildContext context, QiblaService service) {
    return SizedBox(
      height: 350,
      child: AppEmptyState.error(
        message: service.errorMessage ?? 'حدث خطأ',
        onRetry: service.forceUpdate,
      ),
    );
  }

  /// بناء الحالة الأولية
  Widget _buildInitialState(BuildContext context, QiblaService service) {
    return SizedBox(
      height: 350,
      child: AppEmptyState.custom(
        title: 'حدد موقعك',
        message: 'اضغط على زر التحديث لتحديد موقعك',
        icon: Icons.location_searching,
        onAction: service.forceUpdate,
        actionText: 'تحديد الموقع',
      ),
    );
  }

  /// بناء عرض البوصلة
  Widget _buildCompassView(BuildContext context, QiblaService service) {
    return Column(
      children: [
        // البوصلة
        SizedBox(
          height: 300,
          child: QiblaCompass(
            qiblaDirection: service.qiblaData!.qiblaDirection,
            currentDirection: service.currentDirection,
            accuracy: service.compassAccuracy,
          ),
        ),
        
        ThemeConstants.space4.h,
        
        // مؤشر الدقة
        if (service.hasCompass)
          _buildAccuracyIndicator(context, service),
      ],
    );
  }

  /// بناء مؤشر الدقة
  Widget _buildAccuracyIndicator(BuildContext context, QiblaService service) {
    final accuracyHelper = QiblaAccuracyHelper(service.compassAccuracy);
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: accuracyHelper.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            accuracyHelper.icon,
            color: accuracyHelper.color,
          ),
          ThemeConstants.space3.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دقة البوصلة',
                  style: context.bodyMedium?.semiBold,
                ),
                Text(
                  accuracyHelper.text,
                  style: context.bodySmall?.copyWith(
                    color: accuracyHelper.color,
                  ),
                ),
              ],
            ),
          ),
          
          // زر المعايرة
          if (service.needsCalibration)
            TextButton(
              onPressed: () => _showCalibrationDialog(context, service),
              child: const Text('معايرة'),
            ),
        ],
      ),
    );
  }

  /// عرض حوار المعايرة
  void _showCalibrationDialog(BuildContext context, QiblaService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معايرة البوصلة'),
        content: const Text(
          'حرك هاتفك على شكل الرقم 8 في الهواء لتحسين دقة البوصلة',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              service.startCalibration();
              
              // إظهار مؤشر المعايرة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري المعايرة...'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('بدء المعايرة'),
          ),
        ],
      ),
    );
  }
}