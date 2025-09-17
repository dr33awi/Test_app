// lib/features/prayer_times/widgets/location_header_updated.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../models/prayer_time_model.dart'; // استخدام النموذج الأصلي
import '../services/prayer_times_service.dart';
import '../utils/prayer_utils.dart';
import 'shared/prayer_state_widgets.dart';

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
    with SingleTickerProviderStateMixin {
  late final PrayerTimesService _prayerService;
  late AnimationController _refreshAnimationController;
  
  PrayerLocation? _currentLocation;
  bool _isUpdating = false;
  dynamic _lastError;

  @override
  void initState() {
    super.initState();
    _prayerService = getIt<PrayerTimesService>();
    _currentLocation = widget.initialLocation ?? _prayerService.currentLocation;
    
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _prayerService.prayerTimesStream.listen((times) {
      if (mounted && times.location != _currentLocation) {
        setState(() {
          _currentLocation = times.location;
          _lastError = null;
        });
      }
    });
  }

  Future<void> _updateLocation() async {
    if (_isUpdating) return;
    
    setState(() {
      _isUpdating = true;
      _lastError = null;
    });
    
    _refreshAnimationController.repeat();
    
    try {
      HapticFeedback.lightImpact();
      
      final newLocation = await _prayerService.getCurrentLocation(forceUpdate: true);
      
      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
        });
        
        await _prayerService.updatePrayerTimes();

        if (!mounted) return;
      context.showSuccessSnackBar('تم تحديث الموقع بنجاح');
      
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = e;
        });
        context.showErrorSnackBar('فشل تحديث الموقع: ${PrayerUtils.getErrorMessage(e)}');
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
    
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _lastError != null;
    
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: hasError 
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
                          colors: hasError
                            ? [ThemeConstants.error, ThemeConstants.error.darken(0.1)]
                            : [context.primaryColor, context.primaryColor.darken(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: (hasError ? ThemeConstants.error : context.primaryColor)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        hasError ? Icons.location_off_rounded : Icons.location_on_rounded,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getLocationDisplayName(),
                                  style: context.titleLarge?.copyWith(
                                    fontWeight: ThemeConstants.bold,
                                    color: hasError 
                                      ? ThemeConstants.error 
                                      : context.textPrimaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isUpdating) ...[
                                ThemeConstants.space2.w,
                                RotationTransition(
                                  turns: _refreshAnimationController,
                                  child: Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: context.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          ThemeConstants.space1.h,
                          
                          if (hasError)
                            Text(
                              PrayerUtils.getErrorMessage(_lastError),
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
                          
                          if (_currentLocation?.timezone != null && !hasError) ...[
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
                    
                    if (widget.showRefreshButton) ...[
                      ThemeConstants.space3.w,
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.space2),
                        decoration: BoxDecoration(
                          color: (hasError ? ThemeConstants.error : context.primaryColor)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                          border: Border.all(
                            color: (hasError ? ThemeConstants.error : context.primaryColor)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          _isUpdating 
                            ? Icons.hourglass_empty 
                            : (hasError ? Icons.error_outline : Icons.refresh_rounded),
                          color: hasError ? ThemeConstants.error : context.primaryColor,
                          size: ThemeConstants.iconMd,
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (hasError) ...[
                  ThemeConstants.space3.h,
                  RetryButton(
                    onRetry: _updateLocation,
                    isLoading: _isUpdating,
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
    
    if (_lastError != null) {
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