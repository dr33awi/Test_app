// lib/features/prayer_times/widgets/location_header.dart - محسن مع إعادة المحاولة

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_times_service.dart';

class LocationHeader extends StatefulWidget {
  final PrayerLocation? initialLocation;
  final VoidCallback? onTap;
  final bool showRefreshButton;

  const LocationHeader({
    super.key,
    this.initialLocation,
    this.onTap,
    this.showRefreshButton = true,
  });

  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader>
    with TickerProviderStateMixin {
  late final PrayerTimesService _prayerService;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;
  
  PrayerLocation? _currentLocation;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prayerService = getIt<PrayerTimesService>();
    _currentLocation = widget.initialLocation ?? _prayerService.currentLocation;
    
    // إعداد الأنيميشن
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // الاستماع لتحديثات المواقيت (التي تحتوي على الموقع)
    _prayerService.prayerTimesStream.listen((times) {
      if (mounted && times.location != _currentLocation) {
        setState(() {
          _currentLocation = times.location;
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _updateLocation() async {
    if (_isUpdating) return;
    
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });
    
    // تشغيل الأنيميشن
    _refreshAnimationController.repeat();
    
    try {
      HapticFeedback.lightImpact();
      
      // طلب موقع جديد
      final newLocation = await _prayerService.getCurrentLocation(forceUpdate: true);
      
      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
        });
        
        // تحديث المواقيت بالموقع الجديد
        await _prayerService.updatePrayerTimes();
        
        context.showSuccessSnackBar('تم تحديث الموقع بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
        context.showErrorSnackBar('فشل تحديث الموقع: ${_getErrorMessage(e)}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        _refreshAnimationController.stop();
        _refreshAnimationController.reset();
      }
    }
    
    // استدعاء callback إضافي إذا كان موجود
    widget.onTap?.call();
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'يرجى السماح بالوصول للموقع';
    } else if (errorStr.contains('service') || errorStr.contains('disabled')) {
      return 'يرجى تفعيل خدمة الموقع';
    } else if (errorStr.contains('network')) {
      return 'تحقق من اتصال الإنترنت';
    } else if (errorStr.contains('timeout')) {
      return 'انتهت مهلة تحديد الموقع';
    } else {
      return 'فشل تحديد الموقع';
    }
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: _errorMessage != null 
            ? ThemeConstants.error.withValues(alpha: 0.3)
            : context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: InkWell(
          onTap: widget.showRefreshButton ? _updateLocation : widget.onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: Column(
              children: [
                Row(
                  children: [
                    // أيقونة الموقع
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _errorMessage != null
                            ? [ThemeConstants.error, ThemeConstants.error.darken(0.1)]
                            : [context.primaryColor, context.primaryColor.darken(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: (_errorMessage != null ? ThemeConstants.error : context.primaryColor)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _errorMessage != null ? Icons.location_off_rounded : Icons.location_on_rounded,
                        color: Colors.white,
                        size: ThemeConstants.iconLg,
                      ),
                    ),
                    
                    ThemeConstants.space4.w,
                    
                    // معلومات الموقع
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم المدينة والدولة
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getLocationDisplayName(),
                                  style: context.titleLarge?.copyWith(
                                    fontWeight: ThemeConstants.bold,
                                    color: _errorMessage != null 
                                      ? ThemeConstants.error 
                                      : context.textPrimaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isUpdating) ...[
                                ThemeConstants.space2.w,
                                AnimatedBuilder(
                                  animation: _refreshAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _refreshAnimation.value * 2 * 3.14159,
                                      child: Icon(
                                        Icons.refresh,
                                        size: 20,
                                        color: context.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          
                          ThemeConstants.space1.h,
                          
                          // الإحداثيات أو رسالة الخطأ
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: context.bodyMedium?.copyWith(
                                color: ThemeConstants.error,
                                fontWeight: ThemeConstants.medium,
                              ),
                            )
                          else
                            Text(
                              _getCoordinatesText(),
                              style: context.bodyMedium?.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          
                          // معلومات إضافية
                          if (_currentLocation?.timezone != null && _errorMessage == null) ...[
                            ThemeConstants.space1.h,
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: context.textSecondaryColor,
                                ),
                                ThemeConstants.space1.w,
                                Text(
                                  _currentLocation!.timezone,
                                  style: context.bodySmall?.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // زر التحديث
                    if (widget.showRefreshButton) ...[
                      ThemeConstants.space3.w,
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.space2),
                        decoration: BoxDecoration(
                          color: (_errorMessage != null ? ThemeConstants.error : context.primaryColor)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                          border: Border.all(
                            color: (_errorMessage != null ? ThemeConstants.error : context.primaryColor)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          _isUpdating 
                            ? Icons.hourglass_empty 
                            : (_errorMessage != null ? Icons.error_outline : Icons.refresh_rounded),
                          color: _errorMessage != null ? ThemeConstants.error : context.primaryColor,
                          size: ThemeConstants.iconMd,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // زر إعادة المحاولة في حالة الخطأ
                if (_errorMessage != null) ...[
                  ThemeConstants.space3.h,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _updateLocation,
                      icon: _isUpdating 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.refresh, size: 18),
                      label: Text(_isUpdating ? 'جاري المحاولة...' : 'إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: ThemeConstants.space2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocationDisplayName() {
    if (_isUpdating) {
      return 'جاري تحديد الموقع...';
    }
    
    if (_errorMessage != null) {
      return 'خطأ في تحديد الموقع';
    }
    
    if (_currentLocation == null) {
      return 'جاري تحديد الموقع...';
    }
    
    final city = _currentLocation!.cityName;
    final country = _currentLocation!.countryName;
    
    if (city != null && country != null && city != 'غير معروف' && country != 'غير معروف') {
      return '$city، $country';
    } else if (city != null && city != 'غير معروف') {
      return city;
    } else if (country != null && country != 'غير معروف') {
      return country;
    } else {
      return 'موقع غير محدد';
    }
  }

  String _getCoordinatesText() {
    if (_currentLocation == null) {
      return 'جاري تحديد الإحداثيات...';
    }
    
    return 'خط العرض: ${_currentLocation!.latitude.toStringAsFixed(4)}° • '
           'خط الطول: ${_currentLocation!.longitude.toStringAsFixed(4)}°';
  }
}