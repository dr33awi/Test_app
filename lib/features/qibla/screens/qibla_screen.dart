// lib/features/qibla/screens/qibla_screen.dart - نسخة محسنة بدون Fade Animation
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // إضافة للحصول على kDebugMode
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
import '../widgets/qibla_accuracy_indicator.dart';

/// شاشة القبلة المحسنة مع إدارة أفضل للذاكرة ودورة الحياة
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  
  // الخدمات والموارد
  late final QiblaService _qiblaService;
  late final LoggerService _logger;
  
  // Controllers للرسوم المتحركة
  late final AnimationController _refreshController;
  late final Animation<double> _refreshAnimation;

  // حالة الشاشة
  bool _disposed = false;
  bool _showCalibrationDialog = false;
  Timer? _autoRefreshTimer;
  Timer? _diagnosticsTimer;

  // إحصائيات للتشخيص
  int _refreshAttempts = 0;
  DateTime? _lastUserRefresh;
  final List<String> _errorHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// تهيئة الشاشة والموارد
  Future<void> _initializeScreen() async {
    try {
      _logger = getIt<LoggerService>();
      
      _logger.info(
        message: '[QiblaScreen] بدء تهيئة شاشة القبلة',
      );

      // إنشاء QiblaService
      _qiblaService = QiblaService(
        logger: _logger,
        storage: getIt<StorageService>(),
        permissionService: getIt<PermissionService>(),
      );

      // تهيئة Controllers للرسوم المتحركة
      _initAnimationControllers();

      // إضافة مراقب دورة الحياة
      WidgetsBinding.instance.addObserver(this);

      // بدء المراقبة والتحديث
      _startMonitoring();

      // تحديث بيانات القبلة عند فتح الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          _performInitialUpdate();
        }
      });

      _logger.info(message: '[QiblaScreen] تمت تهيئة الشاشة بنجاح');
    } catch (e, stackTrace) {
      _logger.error(
        message: '[QiblaScreen] خطأ في تهيئة الشاشة',
        error: e,
      );
      
      if (!_disposed) {
        _handleInitializationError(e);
      }
    }
  }

  /// تهيئة Controllers للرسوم المتحركة
  void _initAnimationControllers() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _refreshAnimation = CurvedAnimation(
      parent: _refreshController,
      curve: Curves.elasticOut,
    );
  }

  /// بدء المراقبة والمؤقتات
  void _startMonitoring() {
    // مؤقت التحديث التلقائي (كل 10 دقائق)
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) {
        if (_disposed) {
          timer.cancel();
          return;
        }
        _performAutoRefresh();
      },
    );

    // مؤقت التشخيص (كل دقيقة في وضع التطوير)
    if (kDebugMode) {
      _diagnosticsTimer = Timer.periodic(
        const Duration(minutes: 1),
        (timer) {
          if (_disposed) {
            timer.cancel();
            return;
          }
          _logDiagnostics();
        },
      );
    }
  }

  /// تحديث أولي عند فتح الشاشة
  Future<void> _performInitialUpdate() async {
    if (_disposed) return;

    try {
      await _updateQiblaData(isInitial: true);
      _showCalibrationHintIfNeeded();
    } catch (e) {
      _logger.error(
        message: '[QiblaScreen] خطأ في التحديث الأولي',
        error: e,
      );
    }
  }

  /// تحديث تلقائي
  Future<void> _performAutoRefresh() async {
    if (_disposed || _qiblaService.isLoading) return;

    // تحقق من أن البيانات تحتاج تحديث
    if (_qiblaService.hasRecentData && _qiblaService.qiblaData!.hasHighAccuracy) {
      return; // البيانات حديثة ودقيقة
    }

    _logger.info(message: '[QiblaScreen] بدء التحديث التلقائي');
    await _updateQiblaData(isAutomatic: true);
  }

  /// تحديث بيانات القبلة مع معالجة شاملة
  Future<void> _updateQiblaData({
    bool isInitial = false,
    bool isAutomatic = false,
    bool forceUpdate = false,
  }) async {
    if (_disposed) return;

    _refreshAttempts++;
    if (!isAutomatic && !isInitial) {
      _lastUserRefresh = DateTime.now();
    }

    try {
      _logger.info(
        message: '[QiblaScreen] بدء تحديث البيانات',
        data: {
          'isInitial': isInitial,
          'isAutomatic': isAutomatic,
          'forceUpdate': forceUpdate,
          'attempt': _refreshAttempts,
        },
      );

      if (forceUpdate) {
        await _qiblaService.forceUpdate();
      } else {
        await _qiblaService.updateQiblaData();
      }

      // رسوم متحركة للتحديث الناجح
      if (!isAutomatic && !_disposed) {
        _refreshController.forward().then((_) {
          if (!_disposed) {
            _refreshController.reset();
          }
        });
      }

      _logger.info(message: '[QiblaScreen] تم التحديث بنجاح');
    } catch (e, stackTrace) {
      _handleUpdateError(e, stackTrace);
    }
  }

  /// معالجة أخطاء التحديث
  void _handleUpdateError(dynamic error, StackTrace? stackTrace) {
    if (_disposed) return;

    final errorMessage = error.toString();
    _errorHistory.add('${DateTime.now().toIso8601String()}: $errorMessage');
    
    // الاحتفاظ بآخر 10 أخطاء فقط
    if (_errorHistory.length > 10) {
      _errorHistory.removeAt(0);
    }

    _logger.error(
      message: '[QiblaScreen] خطأ في تحديث البيانات',
      error: error,
    );

    // عرض رسالة خطأ للمستخدم إذا لم يكن تحديثاً تلقائياً
    if (!_disposed && mounted) {
      _showErrorSnackbar(errorMessage);
    }
  }

  /// معالجة أخطاء التهيئة
  void _handleInitializationError(dynamic error) {
    if (_disposed) return;

    // في حالة فشل التهيئة، عرض شاشة خطأ بسيطة
    setState(() {
      // سيتم عرض حالة خطأ في build
    });
  }

  /// إظهار نصيحة المعايرة إذا لزم الأمر
  void _showCalibrationHintIfNeeded() {
    if (_disposed || 
        _showCalibrationDialog || 
        !_qiblaService.hasCompass ||
        _qiblaService.isCalibrated) {
      return;
    }

    // تأخير لضمان ظهور الشاشة أولاً
    Timer(const Duration(seconds: 3), () {
      if (!_disposed && 
          mounted && 
          _qiblaService.needsCalibration &&
          !_showCalibrationDialog) {
        _showCalibrationDialog = true;
        _showCalibrationInfo();
      }
    });
  }

  /// عرض معلومات المعايرة
  void _showCalibrationInfo() {
    if (_disposed || !mounted) return;

    AppInfoDialog.show(
      context: context,
      title: 'تحسين دقة البوصلة',
      content: 'لتحسين دقة البوصلة، قم بتحريك هاتفك على شكل الرقم 8 في الهواء عدة مرات.',
      icon: Icons.compass_calibration,
      accentColor: context.primaryColor,
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لتحسين دقة البوصلة، قم بتحريك هاتفك على شكل الرقم 8 في الهواء عدة مرات.',
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.space4),
          
          // مؤشر الدقة الحالية
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: ThemeConstants.radiusMd.circular,
              border: Border.all(color: context.dividerColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  color: context.primaryColor,
                  size: ThemeConstants.iconMd,
                ),
                ThemeConstants.space2.w,
                Text(
                  'الدقة الحالية: ${_qiblaService.accuracyPercentage.toStringAsFixed(0)}%',
                  style: context.bodyMedium?.medium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space3),
          
          // أيقونة توضيحية للحركة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rotate_right,
              size: 60,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        DialogAction(
          label: 'بدء المعايرة',
          onPressed: () {
            Navigator.of(context).pop();
            _startCalibration();
          },
          isPrimary: true,
        ),
        DialogAction(
          label: 'تذكيري لاحقاً',
          onPressed: () {
            Navigator.of(context).pop();
            _showCalibrationDialog = false;
          },
        ),
        DialogAction(
          label: 'عدم الإظهار مرة أخرى',
          onPressed: () {
            Navigator.of(context).pop();
            _dismissCalibrationPermanently();
          },
        ),
      ],
    );
  }

  /// بدء عملية المعايرة
  Future<void> _startCalibration() async {
    if (_disposed) return;

    HapticFeedback.lightImpact();
    
    try {
      await _qiblaService.startCalibration();
      
      if (!_disposed && mounted) {
        _showCalibrationProgress();
      }
    } catch (e) {
      _logger.error(
        message: '[QiblaScreen] خطأ في المعايرة',
      );
    }
  }

  /// عرض تقدم المعايرة
  void _showCalibrationProgress() {
    if (_disposed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.compass_calibration,
              color: context.primaryColor,
            ),
            ThemeConstants.space2.w,
            const Text('جاري المعايرة...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            ThemeConstants.space4.h,
            const Text(
              'حرك هاتفك على شكل الرقم 8 في الهواء',
              textAlign: TextAlign.center,
            ),
            ThemeConstants.space2.h,
            StreamBuilder<bool>(
              stream: Stream.periodic(
                const Duration(milliseconds: 500),
                (_) => _qiblaService.isCalibrating,
              ),
              builder: (context, snapshot) {
                if (snapshot.data == false) {
                  // المعايرة اكتملت
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      _showCalibrationResult();
                    }
                  });
                }
                return const SizedBox.shrink();
              },
            ),
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
    );
  }

  /// عرض نتيجة المعايرة
  void _showCalibrationResult() {
    if (_disposed || !mounted) return;

    final isSuccess = _qiblaService.isCalibrated;
    final accuracy = _qiblaService.accuracyPercentage;

    AppSnackBar.show(
      context: context,
      message: isSuccess 
          ? 'تمت المعايرة بنجاح! الدقة: ${accuracy.toStringAsFixed(0)}%'
          : 'فشلت المعايرة. يرجى المحاولة مرة أخرى.',
    );
  }

  /// إخفاء تذكير المعايرة نهائياً
  void _dismissCalibrationPermanently() {
    _showCalibrationDialog = false;
    // يمكن حفظ تفضيل المستخدم في SharedPreferences
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String errorMessage) {
    if (_disposed || !mounted) return;

    AppSnackBar.showError(
      context: context,
      message: 'فشل تحديث البيانات: $errorMessage',
      action: SnackBarAction(
        label: 'إعادة المحاولة',
        onPressed: () => _updateQiblaData(forceUpdate: true),
      ),
    );
  }

  /// تسجيل التشخيصات (في وضع التطوير)
  void _logDiagnostics() {
    if (_disposed || !kDebugMode) return;

    final diagnostics = _qiblaService.getDiagnostics();
    
    _logger.debug(
      message: '[QiblaScreen] تشخيصات الشاشة',
      data: diagnostics,
    );
  }

  // ==================== دورة الحياة ====================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (_disposed) return;

    _logger.info(
      message: '[QiblaScreen] تغيير حالة التطبيق',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        // العودة إلى التطبيق - تحديث البيانات إذا كانت قديمة
        if (!_qiblaService.hasRecentData) {
          _updateQiblaData(isAutomatic: true);
        }
        break;
      case AppLifecycleState.paused:
        // التطبيق في الخلفية - توقيف المؤقتات غير الضرورية
        _autoRefreshTimer?.cancel();
        break;
      case AppLifecycleState.detached:
        // التطبيق سيتم إغلاقه
        dispose();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _logger.info(
      message: '[QiblaScreen] بدء تنظيف موارد الشاشة',
    );

    // إزالة مراقب دورة الحياة
    WidgetsBinding.instance.removeObserver(this);

    // إلغاء المؤقتات
    _autoRefreshTimer?.cancel();
    _diagnosticsTimer?.cancel();

    // تنظيف Controllers
    _refreshController.dispose();

    // تنظيف الخدمة (لا نستدعي dispose مباشرة لأنها قد تُستخدم في مكان آخر)
    // بدلاً من ذلك، نتركها لـ ServiceLocator أو نظام إدارة التبعية

    _logger.info(message: '[QiblaScreen] تم تنظيف الموارد بنجاح');

    super.dispose();
  }

  // ==================== واجهة المستخدم ====================

  @override
  Widget build(BuildContext context) {
    if (_disposed) {
      return const Scaffold(
        body: Center(
          child: Text('تم إغلاق الشاشة'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: ChangeNotifierProvider.value(
        value: _qiblaService,
        child: Consumer<QiblaService>(
          builder: (context, service, _) {
            // التحقق من حالة التخلص
            if (service.isDisposed) {
              return _buildDisposedState();
            }

            return SafeArea(
              child: Column(
                children: [
                  // Custom AppBar محسن
                  _buildCustomAppBar(context, service),
                  
                  // المحتوى الرئيسي
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

                              // المحتوى الأساسي
                              AnimatedSwitcher(
                                duration: ThemeConstants.durationNormal,
                                child: _buildMainContent(service),
                              ),

                              ThemeConstants.space6.h,

                              // معلومات إضافية
                              if (service.qiblaData != null) ...[
                                QiblaInfoCard(qiblaData: service.qiblaData!),
                                ThemeConstants.space4.h,
                              ],

                              // مؤشر دقة البوصلة
                              if (service.hasCompass) ...[
                                QiblaAccuracyIndicator(
                                  accuracy: service.accuracyPercentage,
                                  isCalibrated: service.isCalibrated,
                                  onCalibrate: _startCalibration,
                                ),
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

  /// بناء حالة التخلص
  Widget _buildDisposedState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: ThemeConstants.warning,
            ),
            const SizedBox(height: ThemeConstants.space4),
            const Text(
              'الخدمة غير متاحة',
              style: TextStyle(
                fontSize: ThemeConstants.textSizeLg,
                fontWeight: ThemeConstants.semiBold,
              ),
            ),
            const SizedBox(height: ThemeConstants.space2),
            Text(
              'يرجى إعادة فتح الشاشة',
              style: TextStyle(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شريط التطبيق المخصص
  Widget _buildCustomAppBar(BuildContext context, QiblaService service) {
    const gradient = LinearGradient(
      colors: [ThemeConstants.primaryDark, ThemeConstants.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع
          AppBackButton(
            onPressed: () {
              if (!_disposed) {
                Navigator.of(context).pop();
              }
            },
          ),
          
          ThemeConstants.space3.w,
          
          // الأيقونة الجانبية
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primaryDark.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // العنوان والوصف
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اتجاه القبلة',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
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
          
          // زر معلومات المعايرة
          _buildActionButton(
            icon: Icons.info_outline,
            onPressed: () {
              HapticFeedback.lightImpact();
              _showCalibrationInfo();
            },
            tooltip: 'معلومات المعايرة',
          ),
          
          // زر التحديث أو مؤشر التحميل
          _buildRefreshButton(service),
          
          // زر القائمة (إعدادات إضافية)
          _buildActionButton(
            icon: Icons.more_vert,
            onPressed: () => _showOptionsMenu(context, service),
            tooltip: 'خيارات إضافية',
          ),
        ],
      ),
    );
  }

  /// بناء زر الإجراء
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: ThemeConstants.space2),
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: InkWell(
            onTap: _disposed ? null : onPressed,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(ThemeConstants.space2),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                border: Border.all(
                  color: context.dividerColor.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color ?? context.textSecondaryColor,
                size: ThemeConstants.iconMd,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء زر التحديث
  Widget _buildRefreshButton(QiblaService service) {
    return AnimatedBuilder(
      animation: _refreshAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_refreshAnimation.value * 0.1),
          child: _buildActionButton(
            icon: service.isLoading ? Icons.hourglass_empty : Icons.refresh_rounded,
            onPressed: service.isLoading 
                ? () {} // لا شيء عند التحميل
                : () {
                    HapticFeedback.lightImpact();
                    _updateQiblaData(forceUpdate: true);
                  },
            tooltip: service.isLoading ? 'جاري التحديث...' : 'تحديث البيانات',
            color: service.isLoading 
                ? ThemeConstants.warning 
                : ThemeConstants.primaryDark,
          ),
        );
      },
    );
  }

  /// الحصول على نص الحالة
  String _getStatusText(QiblaService service) {
    if (service.isLoading) {
      return 'جاري التحديث...';
    } else if (service.errorMessage != null) {
      return 'خطأ في التحديث';
    } else if (service.qiblaData != null) {
      return 'الاتجاه: ${service.qiblaData!.qiblaDirection.toStringAsFixed(1)}°';
    } else {
      return 'البوصلة الذكية';
    }
  }

  /// الحصول على لون الحالة
  Color _getStatusColor(QiblaService service) {
    if (service.isLoading) {
      return ThemeConstants.warning;
    } else if (service.errorMessage != null) {
      return ThemeConstants.error;
    } else if (service.qiblaData != null) {
      return context.primaryColor;
    } else {
      return context.textSecondaryColor;
    }
  }

  /// عرض قائمة الخيارات
  void _showOptionsMenu(BuildContext context, QiblaService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ThemeConstants.radius2xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: ThemeConstants.space3),
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // العنوان
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space4,
                vertical: ThemeConstants.space2,
              ),
              child: Text(
                'خيارات إضافية',
                style: context.titleMedium?.bold,
              ),
            ),
            
            const Divider(),
            
            // الخيارات
            _buildMenuItem(
              context: context,
              icon: Icons.compass_calibration,
              title: 'معايرة البوصلة',
              subtitle: service.isCalibrated ? 'مكتملة' : 'مطلوبة',
              onTap: () {
                Navigator.pop(context);
                _startCalibration();
              },
              trailing: service.isCalibrated
                  ? const Icon(Icons.check_circle, color: ThemeConstants.success)
                  : const Icon(Icons.warning, color: ThemeConstants.warning),
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.refresh,
              title: 'فرض التحديث',
              subtitle: 'تحديث البيانات حتى لو كانت حديثة',
              onTap: () {
                Navigator.pop(context);
                _updateQiblaData(forceUpdate: true);
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.location_off,
              title: 'إعادة تعيين البيانات',
              subtitle: 'حذف البيانات المحفوظة',
              onTap: () {
                Navigator.pop(context);
                _resetData(service);
              },
              isDestructive: true,
            ),
            
            ThemeConstants.space4.h,
          ],
        ),
      ),
    );
  }

  /// بناء عنصر القائمة
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? ThemeConstants.error : context.primaryColor,
      ),
      title: Text(
        title,
        style: context.bodyLarge?.copyWith(
          color: isDestructive ? ThemeConstants.error : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: _disposed ? null : onTap,
    );
  }

  /// إعادة تعيين البيانات
  Future<void> _resetData(QiblaService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text(
          'هل أنت متأكد من حذف جميع البيانات المحفوظة؟ سيتم طلب موقعك مرة أخرى.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: ThemeConstants.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && !_disposed) {
      try {
        // إعادة تعيين المعايرة والبيانات
        service.resetCalibration();
        // يمكن إضافة حذف البيانات المحفوظة هنا
        
        AppSnackBar.showSuccess(
          context: context,
          message: 'تم حذف البيانات بنجاح',
        );
        
        // تحديث البيانات مرة أخرى
        _updateQiblaData(forceUpdate: true);
      } catch (e) {
        AppSnackBar.showError(
          context: context,
          message: 'خطأ في حذف البيانات',
        );
      }
    }
  }

  /// عرض تشخيصات المطور
  void _showDeveloperDiagnostics(QiblaService service) {
    // تم إزالة هذه الوظيفة
  }

  /// بناء المحتوى الرئيسي
  Widget _buildMainContent(QiblaService service) {
    // 🚀 أولوية العرض: إظهار أي محتوى متاح فوراً
    
    // إذا كانت هناك بيانات (حتى لو قديمة)، اعرضها
    if (service.qiblaData != null) {
      return _buildCompassView(service);
    }
    
    // إذا كان هناك تحميل وبيانات قديمة، اعرض البيانات مع مؤشر تحديث
    if (service.isLoading && service.qiblaData != null) {
      return Stack(
        children: [
          _buildCompassView(service),
          _buildOverlayLoadingIndicator(),
        ],
      );
    }
    
    // إذا كان هناك خطأ ولكن توجد بيانات قديمة
    if (service.errorMessage != null && service.qiblaData != null) {
      return Stack(
        children: [
          _buildCompassView(service),
          _buildOverlayErrorIndicator(service.errorMessage!),
        ],
      );
    }
    
    // حالات خاصة
    if (service.isLoading) {
      return _buildLoadingState();
    } else if (service.errorMessage != null) {
      return _buildErrorState(service);
    } else if (!service.hasCompass) {
      return _buildNoCompassState(service);
    } else {
      return _buildInitialState();
    }
  }

  /// مؤشر تحميل علوي (لا يخفي المحتوى)
  Widget _buildOverlayLoadingIndicator() {
    return Positioned(
      top: ThemeConstants.space2,
      right: ThemeConstants.space2,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space3,
          vertical: ThemeConstants.space2,
        ),
        decoration: BoxDecoration(
          color: context.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
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
            Text(
              'تحديث...',
              style: context.bodySmall?.copyWith(
                color: context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// مؤشر خطأ علوي (لا يخفي المحتوى)
  Widget _buildOverlayErrorIndicator(String errorMessage) {
    return Positioned(
      top: ThemeConstants.space2,
      left: ThemeConstants.space2,
      right: ThemeConstants.space2,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space3),
        decoration: BoxDecoration(
          color: ThemeConstants.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          border: Border.all(
            color: ThemeConstants.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: ThemeConstants.error,
              size: ThemeConstants.iconSm,
            ),
            ThemeConstants.space2.w,
            Expanded(
              child: Text(
                'خطأ في التحديث: $errorMessage',
                style: context.bodySmall?.copyWith(
                  color: ThemeConstants.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => _updateQiblaData(forceUpdate: true),
              icon: Icon(
                Icons.refresh,
                color: ThemeConstants.error,
                size: ThemeConstants.iconSm,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عرض البوصلة
  Widget _buildCompassView(QiblaService service) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          // البوصلة الرئيسية
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
          
          // مؤشر التحميل إذا كان هناك تحديث جاري
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
                    Text(
                      'تحديث...',
                      style: context.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// بناء حالة التحميل المحسنة
  Widget _buildLoadingState() {
    return SizedBox(
      height: 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // بوصلة skeleton أنيقة
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.cardColor,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // دوائر skeleton
                for (int i = 1; i <= 3; i++)
                  Container(
                    width: 200 * (i / 3),
                    height: 200 * (i / 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.dividerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                
                // مؤشر تحميل في المنتصف
                const CircularProgressIndicator(),
              ],
            ),
          ),
          
          ThemeConstants.space6.h,
          
          // رسائل تحميل متدرجة
          _buildLoadingMessages(),
        ],
      ),
    );
  }

  /// رسائل التحميل المتحركة
  Widget _buildLoadingMessages() {
    return TweenAnimationBuilder<int>(
      duration: const Duration(seconds: 2),
      tween: IntTween(begin: 0, end: 3),
      builder: (context, value, child) {
        final messages = [
          'جاري تحديد موقعك...',
          'تأكد من تفعيل GPS',
          'جاري حساب اتجاه القبلة...',
          'تحميل بيانات الخريطة...',
        ];
        
        return Column(
          children: [
            Text(
              messages[value % messages.length],
              style: context.bodyLarge?.medium,
              textAlign: TextAlign.center,
            ),
            ThemeConstants.space2.h,
            
            // شريط تقدم تقديري
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value + 1) / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// بناء حالة الخطأ
  Widget _buildErrorState(QiblaService service) {
    return SizedBox(
      height: 350,
      child: AppEmptyState.error(
        message: service.errorMessage ?? 'فشل تحميل البيانات',
        onRetry: () => _updateQiblaData(forceUpdate: true),
      ),
    );
  }

  /// بناء حالة عدم وجود بوصلة
  Widget _buildNoCompassState(QiblaService service) {
    return AppCard(
      backgroundColor: Colors.amber.withOpacity(0.1),
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
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
          Text(
            'جهازك لا يدعم البوصلة أو أنها معطلة حالياً. يمكنك استخدام اتجاه القبلة من موقعك.',
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          if (service.qiblaData != null) ...[
            ThemeConstants.space5.h,
            _buildStaticQiblaInfo(service),
          ],
        ],
      ),
    );
  }

  /// بناء معلومات القبلة الثابتة (بدون بوصلة)
  Widget _buildStaticQiblaInfo(QiblaService service) {
    return AppCard(
      backgroundColor: context.cardColor,
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        children: [
          Text(
            'اتجاه القبلة من موقعك',
            style: context.titleMedium?.semiBold,
          ),
          ThemeConstants.space3.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.navigation,
                size: ThemeConstants.iconXl,
                color: context.primaryColor,
              ),
              ThemeConstants.space2.w,
              Text(
                '${service.qiblaData!.qiblaDirection.toStringAsFixed(1)}°',
                style: context.headlineMedium?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          ThemeConstants.space2.h,
          Text(
            service.qiblaData!.directionDescription,
            style: context.bodyLarge?.medium,
          ),
          ThemeConstants.space3.h,
          Text(
            'استخدم بوصلة خارجية للتوجه إلى هذا الاتجاه',
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بناء الحالة الأولية
  Widget _buildInitialState() {
    return SizedBox(
      height: 350,
      child: AppEmptyState.custom(
        title: 'حدد موقعك',
        message: 'اضغط على زر التحديث لتحديد موقعك وعرض اتجاه القبلة',
        icon: Icons.location_searching,
        iconColor: context.primaryColor.withOpacity(0.5),
        onAction: () => _updateQiblaData(forceUpdate: true),
        actionText: 'تحديد الموقع',
      ),
    );
  }
}