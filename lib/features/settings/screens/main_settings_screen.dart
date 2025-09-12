// lib/features/settings/screens/main_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../app/di/service_locator.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_router.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../../../core/infrastructure/services/permissions/permission_manager.dart';
import '../../../core/infrastructure/services/permissions/models/permission_state.dart';

import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../services/settings_services_manager.dart';

class MainSettingsScreen extends StatefulWidget {
  const MainSettingsScreen({super.key});

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late final SettingsServicesManager _settingsManager;
  late final PermissionService _permissionService;
  late final UnifiedPermissionManager _permissionManager;

  // حالة الأذونات
  Map<AppPermissionType, AppPermissionStatus> _permissionStatuses = {};
  PermissionCheckResult? _permissionResult;
  bool _isLoading = false;

  // للتحكم في المراجعة داخل التطبيق
  final InAppReview _inAppReview = InAppReview.instance;
  
  // قائمة الأذونات الأساسية فقط
  final List<AppPermissionType> _criticalPermissions = [
    AppPermissionType.notification,
    AppPermissionType.location,
    AppPermissionType.batteryOptimization,
  ];

  @override
  void initState() {
    super.initState();
    _settingsManager = getIt<SettingsServicesManager>();
    _permissionService = getIt<PermissionService>();
    _permissionManager = getIt<UnifiedPermissionManager>();
    
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      // تحميل حالة الأذونات
      _permissionResult = await _permissionManager.performBackgroundCheck();
      await _loadPermissionStatuses();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading settings data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadPermissionStatuses() async {
    try {
      final statuses = await _permissionService.checkAllPermissions();
      if (mounted) {
        setState(() {
          _permissionStatuses = statuses;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('حدث خطأ في تحميل حالة الأذونات');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSettingsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // زر الرجوع
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // الأيقونة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: const Icon(
              Icons.settings,
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
                  'الإعدادات',
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'تخصيص تجربتك مع التطبيق',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // زر إعادة تعيين الإعدادات
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _resetSettings(),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ThemeConstants.error.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: ThemeConstants.error,
                      size: ThemeConstants.iconSm,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'إعادة تعيين',
                      style: TextStyle(
                        color: ThemeConstants.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    // الحصول على الإعدادات الحالية من المدير
    final settings = _settingsManager.settings;
    
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: ThemeConstants.space8),
        child: Column(
          children: [
            ThemeConstants.space4.h,
            
            // ==================== 1. بطاقة حالة الأذونات في الأعلى ====================
            _buildPermissionStatusCard(),
            
            // ==================== 2. قسم الإشعارات ====================
            SettingsSection(
              title: 'الإشعارات',
              subtitle: 'إدارة التنبيهات والتذكيرات',
              icon: Icons.notifications_active,
              children: [
                SettingsTile(
                  icon: Icons.access_time,
                  title: 'إشعارات الصلاة',
                  subtitle: 'تنبيهات أوقات الصلاة والأذان',
                  onTap: () => Navigator.pushNamed(context, AppRouter.prayerNotificationsSettings),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                SettingsTile(
                  icon: Icons.menu_book,
                  title: 'إشعارات الأذكار',
                  subtitle: 'تذكيرات الأذكار اليومية',
                  onTap: () => Navigator.pushNamed(context, AppRouter.athkarNotificationsSettings),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                SettingsTile(
                  icon: Icons.vibration,
                  title: 'الاهتزاز',
                  subtitle: 'اهتزاز عند وصول الإشعارات',
                  trailing: SettingsSwitch(
                    value: settings.vibrationEnabled,
                    onChanged: (value) async {
                      await _settingsManager.toggleVibration(value);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            
            // ==================== 3. قسم المظهر والعرض ====================
            SettingsSection(
              title: 'المظهر والعرض',
              subtitle: 'تخصيص شكل التطبيق',
              icon: Icons.palette,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.space4,
                    vertical: ThemeConstants.space3,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                        ),
                        child: Icon(
                          _settingsManager.currentTheme == ThemeMode.dark 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                          color: context.primaryColor,
                          size: ThemeConstants.iconMd,
                        ),
                      ),
                      ThemeConstants.space4.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'وضع العرض',
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _settingsManager.currentTheme == ThemeMode.dark
                                  ? 'الوضع الليلي مفعل'
                                  : 'الوضع النهاري مفعل',
                              style: context.bodySmall?.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _settingsManager.currentTheme == ThemeMode.dark,
                        onChanged: (value) {
                          _settingsManager.changeTheme(
                            value ? ThemeMode.dark : ThemeMode.light
                          );
                          setState(() {});
                        },
                        activeColor: context.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // ==================== 4. قسم الدعم والمعلومات ====================
            SettingsSection(
              title: 'الدعم والمعلومات',
              subtitle: 'معلومات التطبيق والدعم',
              icon: Icons.info_outline,
              children: [
                SettingsTile(
                  icon: Icons.share_outlined,
                  title: 'مشاركة التطبيق',
                  subtitle: 'شارك التطبيق مع الأصدقاء والعائلة',
                  onTap: () => _shareApp(),
                ),
                SettingsTile(
                  icon: Icons.star_outline,
                  title: 'تقييم التطبيق',
                  subtitle: 'قيم التطبيق على المتجر وادعمنا',
                  onTap: () => _rateApp(),
                ),
                SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'تواصل معنا',
                  subtitle: 'أرسل استفساراتك ومقترحاتك',
                  onTap: () => _contactUs(),
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'عن التطبيق',
                  subtitle: 'معلومات الإصدار والمطور',
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== بطاقة حالة الأذونات ====================
  Widget _buildPermissionStatusCard() {
    if (_permissionResult == null) {
      return const SizedBox();
    }
    
    final granted = _permissionResult!.grantedCount;
    final denied = _permissionResult!.missingCount;
    final total = granted + denied;
    final percentage = total > 0 ? granted / total : 0.0;
    
    return GestureDetector(
      onTap: () => _showPermissionsBottomSheet(),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space4,
          vertical: ThemeConstants.space2,
        ),
        padding: const EdgeInsets.all(ThemeConstants.space4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(percentage),
              _getStatusColor(percentage).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(percentage).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // الأيقونة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                ThemeConstants.space3.w,
                
                // المعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة الأذونات',
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$granted من $total أذونات مفعلة',
                        style: context.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // أيقونة السهم
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            
            // إحصائيات سريعة
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('مفعلة', granted, Colors.white),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildQuickStat('معطلة', denied, Colors.white.withValues(alpha: 0.9)),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildQuickStat('الكل', total, Colors.white),
              ],
            ),
            
            // نص توضيحي
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'اضغط لإدارة الأذونات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ==================== نافذة الأذونات المنبثقة ====================
  void _showPermissionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // العنوان
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إدارة الأذونات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'تحكم في أذونات التطبيق',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // قائمة الأذونات
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // عرض الأذونات
                    ..._criticalPermissions
                        .where((p) => _permissionStatuses.containsKey(p))
                        .map((permission) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPermissionCard(permission),
                        )),
                    
                    const SizedBox(height: 20),
                    
                    // زر إعدادات النظام
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _permissionService.openAppSettings();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.phonelink_setup,
                                    color: Theme.of(context).primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'إعدادات النظام',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'فتح إعدادات التطبيق في النظام',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ],
                            ),
                          ),
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
    ).then((_) {
      // تحديث البيانات عند إغلاق النافذة
      _loadInitialData();
    });
  }
  
  // ==================== بطاقة إذن ====================
  Widget _buildPermissionCard(AppPermissionType permission) {
    final status = _permissionStatuses[permission] ?? AppPermissionStatus.unknown;
    final isGranted = status == AppPermissionStatus.granted;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted 
              ? ThemeConstants.success.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة الإذن
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isGranted
                        ? ThemeConstants.success.withValues(alpha: 0.1)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPermissionIcon(permission),
                    color: isGranted
                        ? ThemeConstants.success
                        : Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                
                // معلومات الإذن
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPermissionTitle(permission),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getPermissionDescription(permission),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // حالة الإذن
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isGranted
                        ? ThemeConstants.success.withValues(alpha: 0.1)
                        : ThemeConstants.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGranted ? Icons.check_circle : Icons.warning,
                        size: 14,
                        color: isGranted
                            ? ThemeConstants.success
                            : ThemeConstants.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isGranted ? 'مفعل' : 'معطل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isGranted
                              ? ThemeConstants.success
                              : ThemeConstants.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // زر التفعيل إذا كان الإذن معطل
            if (!isGranted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _requestPermission(permission);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تفعيل الإذن',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // دوال مساعدة للحصول على معلومات الأذونات
  IconData _getPermissionIcon(AppPermissionType permission) {
    switch (permission) {
      case AppPermissionType.notification:
        return Icons.notifications;
      case AppPermissionType.location:
        return Icons.location_on;
      case AppPermissionType.batteryOptimization:
        return Icons.battery_charging_full;
      default:
        return Icons.security;
    }
  }
  
  String _getPermissionTitle(AppPermissionType permission) {
    switch (permission) {
      case AppPermissionType.notification:
        return 'الإشعارات';
      case AppPermissionType.location:
        return 'الموقع';
      case AppPermissionType.batteryOptimization:
        return 'تحسين البطارية';
      default:
        return 'إذن غير معروف';
    }
  }
  
  String _getPermissionDescription(AppPermissionType permission) {
    switch (permission) {
      case AppPermissionType.notification:
        return 'لإرسال تنبيهات الصلاة والأذكار';
      case AppPermissionType.location:
        return 'لحساب أوقات الصلاة حسب موقعك';
      case AppPermissionType.batteryOptimization:
        return 'لضمان عمل الإشعارات في الخلفية';
      default:
        return '';
    }
  }
  
  Future<void> _requestPermission(AppPermissionType permission) async {
    HapticFeedback.lightImpact();
    
    final status = await _permissionService.checkPermissionStatus(permission);
    
    if (status == AppPermissionStatus.permanentlyDenied) {
      await _permissionService.openAppSettings();
    } else {
      final granted = await _permissionManager.requestPermissionWithExplanation(
        context,
        permission,
      );
      
      if (granted) {
        _showSuccessMessage('تم تفعيل إذن ${_getPermissionTitle(permission)}');
      }
    }
    
    await _loadPermissionStatuses();
    _permissionResult = await _permissionManager.performBackgroundCheck();
    setState(() {});
  }

  // ==================== الدوال المساعدة ====================
  
  Future<void> _resetSettings() async {
    HapticFeedback.heavyImpact();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeConstants.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: ThemeConstants.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('إعادة تعيين الإعدادات'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من إعادة جميع الإعدادات إلى الوضع الافتراضي؟\n\nسيتم مسح جميع التخصيصات والإعدادات المحفوظة.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      await _settingsManager.resetSettings();
      await _permissionManager.reset();
      await _loadInitialData();
      _showSuccessMessage('تم إعادة تعيين الإعدادات بنجاح');
    }
  }

  void _shareApp() {
    Share.share(
      'جرب تطبيق حصن المسلم - تطبيق شامل للأذكار والأدعية\n'
      'حمل التطبيق الآن من:\n'
      'https://play.google.com/store/apps/details?id=com.yourapp.athkar',
      subject: 'تطبيق حصن المسلم',
    );
  }

  Future<void> _rateApp() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    } else {
      final url = Uri.parse('https://play.google.com/store/apps/details?id=com.yourapp.athkar');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {
        'subject': 'استفسار من تطبيق حصن المسلم',
        'body': 'اكتب رسالتك هنا...',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorMessage('لا يمكن فتح تطبيق البريد الإلكتروني');
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeConstants.primary.withValues(alpha: 0.1),
                    ThemeConstants.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mosque,
                size: 60,
                color: ThemeConstants.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حصن المسلم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: ThemeConstants.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تطبيق شامل للأذكار والأدعية\nيساعدك على المحافظة على أذكارك اليومية',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'تطوير وتصميم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'فريق التطوير',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // ==================== رسائل التنبيه ====================
  
  void _showSuccessMessage(String message) {
    _showSnackBar(message, ThemeConstants.success, Icons.check_circle);
  }

  void _showErrorMessage(String message) {
    _showSnackBar(message, ThemeConstants.error, Icons.error);
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 1.0) return ThemeConstants.success;
    if (percentage >= 0.5) return ThemeConstants.warning;
    return ThemeConstants.error;
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}