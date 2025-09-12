// lib/features/prayer_times/screens/prayer_time_screen.dart - محسن مع إعادة المحاولة

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../services/prayer_times_service.dart';
import '../models/prayer_time_model.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/location_header.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late final LoggerService _logger;
  late final PrayerTimesService _prayerService;
  
  // Controllers
  final _scrollController = ScrollController();
  
  // State
  DailyPrayerTimes? _dailyTimes;
  PrayerTime? _nextPrayer;
  bool _isLoading = true;
  bool _isRetryingLocation = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  
  // Subscriptions
  StreamSubscription<DailyPrayerTimes>? _timesSubscription;
  StreamSubscription<PrayerTime?>? _nextPrayerSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadPrayerTimes();
  }

  void _initializeServices() {
    _logger = getIt<LoggerService>();
    _prayerService = getIt<PrayerTimesService>();
    
    // الاستماع للتحديثات
    _timesSubscription = _prayerService.prayerTimesStream.listen(
      (times) {
        if (mounted) {
          setState(() {
            _dailyTimes = times;
            _isLoading = false;
            _isRefreshing = false;
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = _getErrorMessage(error);
            _isLoading = false;
            _isRefreshing = false;
          });
        }
      },
    );
    
    _nextPrayerSubscription = _prayerService.nextPrayerStream.listen(
      (prayer) {
        if (mounted) {
          setState(() {
            _nextPrayer = prayer;
          });
        }
      },
    );
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // تحقق من وجود مواقيت مخزنة مسبقاً
      final cachedTimes = await _prayerService.getCachedPrayerTimes(DateTime.now());
      if (cachedTimes != null && mounted) {
        setState(() {
          _dailyTimes = cachedTimes;
          _nextPrayer = cachedTimes.nextPrayer;
          _isLoading = false;
        });
      }
      
      // التحقق من وجود موقع محفوظ
      if (_prayerService.currentLocation == null) {
        await _requestLocation();
      } else {
        await _prayerService.updatePrayerTimes();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
      
      _logger.error(
        message: 'خطأ في تحميل مواقيت الصلاة',
        error: e,
      );
    }
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isRetryingLocation = true;
    });
    
    try {
      final location = await _prayerService.getCurrentLocation(forceUpdate: true);
      
      _logger.info(
        message: 'تم تحديد الموقع بنجاح',
        data: {
          'city': location.cityName,
          'country': location.countryName,
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      );
      
      // تحديث مواقيت الصلاة بعد تحديد الموقع
      await _prayerService.updatePrayerTimes();
      
      if (mounted) {
        setState(() {
          _isRetryingLocation = false;
        });
        context.showSuccessSnackBar('تم تحديد الموقع وتحميل المواقيت بنجاح');
      }
    } catch (e) {
      _logger.error(
        message: 'فشل الحصول على الموقع',
        error: e,
      );
      
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
          _isRetryingLocation = false;
        });
        
        context.showErrorSnackBar(
          _getErrorMessage(e),
          action: SnackBarAction(
            label: 'حاول مجدداً',
            onPressed: _requestLocation,
          ),
        );
      }
    }
  }

  Future<void> _refreshPrayerTimes() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });
    
    HapticFeedback.lightImpact();
    
    try {
      // تحديث الموقع أولاً
      await _prayerService.getCurrentLocation(forceUpdate: true);
      
      // ثم تحديث المواقيت
      await _prayerService.updatePrayerTimes();
      
      if (mounted) {
        context.showSuccessSnackBar('تم تحديث مواقيت الصلاة بنجاح');
      }
      
    } catch (e) {
      _logger.error(
        message: 'فشل تحديث مواقيت الصلاة',
        error: e,
      );
      
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
        context.showErrorSnackBar('فشل التحديث: ${_getErrorMessage(e)}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'يرجى السماح بالوصول للموقع من إعدادات التطبيق';
    } else if (errorStr.contains('service') || errorStr.contains('disabled')) {
      return 'يرجى تفعيل خدمة الموقع من إعدادات الجهاز';
    } else if (errorStr.contains('network') || errorStr.contains('internet')) {
      return 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
    } else if (errorStr.contains('timeout')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    } else if (errorStr.contains('location')) {
      return 'لم نتمكن من تحديد موقعك، تحقق من إعدادات الموقع';
    } else {
      return 'حدث خطأ أثناء تحميل مواقيت الصلاة';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timesSubscription?.cancel();
    _nextPrayerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar محسن
            _buildCustomAppBar(context),
            
            // المحتوى
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPrayerTimes,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // المحتوى
                    if (_isLoading && _dailyTimes == null)
                      _buildLoadingState()
                    else if (_errorMessage != null && _dailyTimes == null)
                      _buildErrorState()
                    else if (_dailyTimes != null)
                      ..._buildContent()
                    else
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    const gradient = LinearGradient(
      colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
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
                  color: ThemeConstants.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.schedule_rounded,
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
                  'مواقيت الصلاة',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  _nextPrayer != null 
                      ? 'الصلاة التالية: ${_nextPrayer!.nameAr}'
                      : 'وَأَقِمِ الصَّلَاةَ لِذِكْرِي',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // زر تحديث الموقع
          Container(
            margin: const EdgeInsets.only(left: ThemeConstants.space2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: InkWell(
                onTap: (_isRetryingLocation || _isRefreshing) ? null : _requestLocation,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    border: Border.all(
                      color: context.dividerColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: (_isRetryingLocation || _isRefreshing)
                      ? const SizedBox(
                          width: ThemeConstants.iconMd, 
                          height: ThemeConstants.iconMd, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primary),
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: ThemeConstants.primary,
                          size: ThemeConstants.iconMd,
                        ),
                ),
              ),
            ),
          ),
          
          // زر إعدادات الإشعارات
          Container(
            margin: const EdgeInsets.only(left: ThemeConstants.space2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/prayer-notifications-settings');
                },
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    border: Border.all(
                      color: context.dividerColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: context.textPrimaryColor,
                    size: ThemeConstants.iconMd,
                  ),
                ),
              ),
            ),
          ),
          
          // زر الإعدادات
          Container(
            margin: const EdgeInsets.only(left: ThemeConstants.space2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/prayer-settings');
                },
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    border: Border.all(
                      color: context.dividerColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: context.textSecondaryColor,
                    size: ThemeConstants.iconMd,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      // Header مع الموقع - محسن
      SliverToBoxAdapter(
        child: LocationHeader(
          initialLocation: _dailyTimes?.location,
          showRefreshButton: true,
          onTap: _refreshPrayerTimes,
        ),
      ),
      
      // العد التنازلي للصلاة التالية
      if (_nextPrayer != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: NextPrayerCountdown(
              nextPrayer: _nextPrayer!,
              currentPrayer: _dailyTimes!.currentPrayer,
            ),
          ),
        ),
      
      // قائمة الصلوات
      SliverPadding(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final prayer = _dailyTimes!.prayers[index];
              
              // تخطي الشروق لأنه ليس صلاة
              if (prayer.type == PrayerType.sunrise) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
                child: PrayerTimeCard(
                  prayer: prayer,
                  forceColored: true,
                ),
              );
            },
            childCount: _dailyTimes!.prayers.length,
          ),
        ),
      ),
      
      // مساحة في الأسفل
      const SliverToBoxAdapter(
        child: SizedBox(height: ThemeConstants.space8),
      ),
    ];
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoading.circular(size: LoadingSize.large),
            const SizedBox(height: ThemeConstants.space4),
            const Text(
              'جاري تحميل مواقيت الصلاة...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_isRetryingLocation) ...[
              const SizedBox(height: ThemeConstants.space2),
              Text(
                'جاري تحديد الموقع...',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: ThemeConstants.error,
              ),
              const SizedBox(height: ThemeConstants.space4),
              Text(
                'خطأ في تحميل مواقيت الصلاة',
                style: context.titleLarge?.copyWith(
                  color: ThemeConstants.error,
                  fontWeight: ThemeConstants.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.space2),
              Text(
                _errorMessage ?? 'حدث خطأ غير متوقع',
                style: context.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.space4),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isRefreshing || _isRetryingLocation) ? null : _refreshPrayerTimes,
                      icon: (_isRefreshing || _isRetryingLocation)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh, size: 20),
                      label: Text(
                        (_isRefreshing || _isRetryingLocation) 
                            ? 'جاري المحاولة...' 
                            : 'إعادة المحاولة',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeConstants.space3,
                          horizontal: ThemeConstants.space4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage?.contains('موقع') == true) ...[
                const SizedBox(height: ThemeConstants.space3),
                OutlinedButton.icon(
                  onPressed: () {
                    // فتح إعدادات التطبيق
                    HapticFeedback.lightImpact();
                    context.showInfoSnackBar('يرجى الذهاب لإعدادات التطبيق يدوياً');
                  },
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('إعدادات الموقع'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeConstants.primary,
                    side: const BorderSide(color: ThemeConstants.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeConstants.space2,
                      horizontal: ThemeConstants.space3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: context.textSecondaryColor,
              ),
              const SizedBox(height: ThemeConstants.space4),
              Text(
                'لم يتم تحديد الموقع',
                style: context.titleLarge?.copyWith(
                  fontWeight: ThemeConstants.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.space2),
              Text(
                'نحتاج لتحديد موقعك لعرض مواقيت الصلاة الصحيحة',
                style: context.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.space4),
              ElevatedButton.icon(
                onPressed: (_isRetryingLocation || _isRefreshing) ? null : _requestLocation,
                icon: (_isRetryingLocation || _isRefreshing)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location, size: 20),
                label: Text(
                  (_isRetryingLocation || _isRefreshing) 
                      ? 'جاري تحديد الموقع...' 
                      : 'تحديد الموقع',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeConstants.space3,
                    horizontal: ThemeConstants.space4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}