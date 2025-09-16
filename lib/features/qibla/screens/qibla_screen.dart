// lib/features/qibla/screens/qibla_screen.dart - نسخة منظفة
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

/// شاشة القبلة
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  
  late final QiblaService _qiblaService;
  late final LoggerService _logger;
  late final AnimationController _refreshController;
  
  bool _disposed = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      _logger = getIt<LoggerService>();
      
      _qiblaService = QiblaService(
        logger: _logger,
        storage: getIt<StorageService>(),
        permissionService: getIt<PermissionService>(),
      );

      _refreshController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      WidgetsBinding.instance.addObserver(this);
      _startAutoRefreshTimer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          _updateQiblaData();
        }
      });
    } catch (e) {
      _logger.error(message: '[QiblaScreen] خطأ في تهيئة الشاشة', error: e);
    }
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) {
        if (!_disposed && !_qiblaService.isLoading && !_qiblaService.hasRecentData) {
          _updateQiblaData();
        }
      },
    );
  }

  Future<void> _updateQiblaData({bool forceUpdate = false}) async {
    if (_disposed || _qiblaService.isLoading) return;

    try {
      await _qiblaService.updateQiblaData(forceUpdate: forceUpdate);
      
      if (!_disposed) {
        _refreshController.forward().then((_) {
          if (!_disposed) {
            _refreshController.reset();
          }
        });
      }
    } catch (e) {
      _logger.error(message: '[QiblaScreen] خطأ في تحديث البيانات', error: e);
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _startCalibration() async {
    if (_disposed) return;
    
    HapticFeedback.lightImpact();
    await _qiblaService.startCalibration();
    
    if (mounted) {
      _showCalibrationDialog();
    }
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('جاري المعايرة...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            ThemeConstants.space4.h,
            const Text('حرك هاتفك على شكل الرقم 8 في الهواء'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _qiblaService.resetCalibration();
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    ).then((_) {
      if (_qiblaService.isCalibrated) {
        _showSuccessSnackbar('تمت المعايرة بنجاح');
      }
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.error,
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          onPressed: () => _updateQiblaData(forceUpdate: true),
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.success,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (_disposed) return;

    if (state == AppLifecycleState.resumed && !_qiblaService.hasRecentData) {
      _updateQiblaData();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _refreshController.dispose();
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
                  _buildAppBar(context, service),
                  
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _updateQiblaData(forceUpdate: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space4,
                          ),
                          child: Column(
                            children: [
                              ThemeConstants.space4.h,
                              _buildMainContent(service),
                              ThemeConstants.space6.h,
                              
                              if (service.qiblaData != null) ...[
                                QiblaInfoCard(qiblaData: service.qiblaData!),
                                ThemeConstants.space4.h,
                              ],
                              
                              ThemeConstants.space12.h,
                            ],
                          ),
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

  Widget _buildAppBar(BuildContext context, QiblaService service) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.primaryDark, ThemeConstants.primary],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اتجاه القبلة',
                  style: context.titleLarge?.bold,
                ),
                Text(
                  _getStatusText(service),
                  style: context.bodySmall?.copyWith(
                    color: _getStatusColor(service),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: service.isLoading 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: service.isLoading 
                ? null 
                : () {
                    HapticFeedback.lightImpact();
                    _updateQiblaData(forceUpdate: true);
                  },
          ),
        ],
      ),
    );
  }

  String _getStatusText(QiblaService service) {
    if (service.isLoading) {
      return 'جاري التحديث...';
    } else if (service.errorMessage != null) {
      return 'خطأ في التحديث';
    } else if (service.qiblaData != null) {
      return 'الاتجاه: ${service.qiblaData!.qiblaDirection.toStringAsFixed(1)}°';
    }
    return 'البوصلة الذكية';
  }

  Color _getStatusColor(QiblaService service) {
    if (service.isLoading) return ThemeConstants.warning;
    if (service.errorMessage != null) return ThemeConstants.error;
    if (service.qiblaData != null) return context.primaryColor;
    return context.textSecondaryColor;
  }

  Widget _buildMainContent(QiblaService service) {
    if (service.qiblaData != null) {
      return _buildCompassView(service);
    }
    
    if (service.isLoading) {
      return _buildLoadingState();
    }
    
    if (service.errorMessage != null) {
      return _buildErrorState(service);
    }
    
    if (!service.hasCompass) {
      return _buildNoCompassState(service);
    }
    
    return _buildInitialState();
  }

  Widget _buildCompassView(QiblaService service) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: QiblaCompass(
              qiblaDirection: service.qiblaData!.qiblaDirection,
              currentDirection: service.currentDirection,
              accuracy: service.compassAccuracy,
              isCalibrated: service.isCalibrated,
              onCalibrate: _startCalibration,
            ),
          ),
          
          if (service.isLoading)
            Positioned(
              top: ThemeConstants.space2,
              right: ThemeConstants.space2,
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: context.cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    ThemeConstants.space2.w,
                    const Text('تحديث...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.cardColor,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          ThemeConstants.space6.h,
          Text(
            'جاري تحديد موقعك...',
            style: context.bodyLarge?.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(QiblaService service) {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: ThemeConstants.error,
            ),
            ThemeConstants.space4.h,
            Text(
              service.errorMessage ?? 'فشل تحميل البيانات',
              style: context.bodyLarge,
              textAlign: TextAlign.center,
            ),
            ThemeConstants.space4.h,
            ElevatedButton.icon(
              onPressed: () => _updateQiblaData(forceUpdate: true),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCompassState(QiblaService service) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compass_calibration_outlined,
            size: ThemeConstants.icon2xl,
            color: Colors.amber[700],
          ),
          ThemeConstants.space4.h,
          Text(
            'البوصلة غير متوفرة',
            style: context.titleLarge?.bold,
          ),
          ThemeConstants.space2.h,
          const Text(
            'جهازك لا يدعم البوصلة. يمكنك استخدام اتجاه القبلة من موقعك.',
            textAlign: TextAlign.center,
          ),
          if (service.qiblaData != null) ...[
            ThemeConstants.space5.h,
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: Column(
                children: [
                  Text(
                    'اتجاه القبلة: ${service.qiblaData!.qiblaDirection.toStringAsFixed(1)}°',
                    style: context.headlineMedium?.bold.textColor(context.primaryColor),
                  ),
                  Text(
                    service.qiblaData!.directionDescription,
                    style: context.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_searching,
              size: 64,
              color: ThemeConstants.primary,
            ),
            ThemeConstants.space4.h,
            const Text(
              'حدد موقعك',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ThemeConstants.space2.h,
            const Text(
              'اضغط على زر التحديث لتحديد موقعك',
              textAlign: TextAlign.center,
            ),
            ThemeConstants.space4.h,
            ElevatedButton.icon(
              onPressed: () => _updateQiblaData(forceUpdate: true),
              icon: const Icon(Icons.my_location),
              label: const Text('تحديد الموقع'),
            ),
          ],
        ),
      ),
    );
  }
}