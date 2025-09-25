// lib/features/prayer_times/screens/prayer_notifications_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/prayer_times_service.dart';
import '../models/prayer_time_model.dart';

class PrayerNotificationsSettingsScreen extends StatefulWidget {
  const PrayerNotificationsSettingsScreen({super.key});

  @override
  State<PrayerNotificationsSettingsScreen> createState() => _PrayerNotificationsSettingsScreenState();
}

class _PrayerNotificationsSettingsScreenState extends State<PrayerNotificationsSettingsScreen> {
  late final PrayerTimesService _prayerService;
  
  late PrayerNotificationSettings _notificationSettings;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  // استخدام اللون الأخضر الموحد
  final Color _primaryGreenColor = ThemeConstants.success;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadSettings();
  }

  void _initializeServices() {
    _prayerService = getIt<PrayerTimesService>();
  }

  void _loadSettings() {
    setState(() {
      _notificationSettings = _prayerService.notificationSettings;
      _isLoading = false;
    });
  }

  void _markAsChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    try {
      await _prayerService.updateNotificationSettings(_notificationSettings);
      
      debugPrint('Prayer notification settings updated - '
          'enabled: ${_notificationSettings.enabled}, '
          'enabled_prayers_count: ${_notificationSettings.enabledPrayers.values.where((v) => v).length}');
      
      if (!mounted) return;
      
      context.showSuccessSnackBar('تم حفظ إعدادات الإشعارات بنجاح');
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      debugPrint('خطأ في حفظ إعدادات الإشعارات: $e');
      
      if (!mounted) return;
      
      context.showErrorSnackBar('فشل حفظ إعدادات الإشعارات');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
            // Custom AppBar محسن
            _buildCustomAppBar(context),
            
            // المحتوى
            Expanded(
              child: _isLoading
                  ? Center(child: AppLoading.circular())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    // استخدام نفس التدرج المستخدم في CategoryGrid لفئة prayer_times
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
            onPressed: () {
              if (_hasChanges) {
                _showUnsavedChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          
          ThemeConstants.space3.w,
          
          // الأيقونة الجانبية مع نفس التدرج المستخدم في CategoryGrid
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
              Icons.notifications_active,
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
                  'إعدادات إشعارات الصلوات',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'تخصيص تنبيهات أوقات الصلاة',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // زر الحفظ
          if (_hasChanges && !_isSaving)
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _saveSettings();
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
                    child: const Icon(
                      Icons.save,
                      color: ThemeConstants.primary,
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

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // القسم الرئيسي للإعدادات
        SliverToBoxAdapter(
          child: _buildMainSettingsSection(),
        ),
        
        // قسم الإشعارات لكل صلاة
        SliverToBoxAdapter(
          child: _buildPrayerNotificationsSection(),
        ),
        
        // زر الحفظ
        SliverToBoxAdapter(
          child: _buildSaveButton(),
        ),
        
        // مساحة في الأسفل
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildMainSettingsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryGreenColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: _primaryGreenColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات الإشعارات العامة',
                        style: context.titleMedium?.semiBold,
                      ),
                      Text(
                        'تفعيل أو تعطيل الإشعارات لجميع الصلوات',
                        style: context.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // تفعيل/تعطيل الإشعارات
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('تلقي تنبيهات أوقات الصلاة'),
            value: _notificationSettings.enabled,
            onChanged: (value) {
              setState(() {
                _notificationSettings = _notificationSettings.copyWith(
                  enabled: value,
                );
                _markAsChanged();
              });
            },
            activeColor: _primaryGreenColor,
          ),
          
          // الاهتزاز
          SwitchListTile(
            title: const Text('الاهتزاز'),
            subtitle: const Text('اهتزاز الجهاز عند التنبيه'),
            value: _notificationSettings.vibrate,
            onChanged: _notificationSettings.enabled
                ? (value) {
                    setState(() {
                      _notificationSettings = _notificationSettings.copyWith(
                        vibrate: value,
                      );
                      _markAsChanged();
                    });
                  }
                : null,
            activeColor: _primaryGreenColor,
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPrayerNotificationsSection() {
    final prayers = [
      (PrayerType.fajr, 'الفجر', Icons.dark_mode),
      (PrayerType.dhuhr, 'الظهر', Icons.light_mode),
      (PrayerType.asr, 'العصر', Icons.wb_cloudy),
      (PrayerType.maghrib, 'المغرب', Icons.wb_twilight),
      (PrayerType.isha, 'العشاء', Icons.bedtime),
    ];
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryGreenColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.mosque,
                    color: _primaryGreenColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات إشعارات الصلوات',
                        style: context.titleMedium?.semiBold,
                      ),
                      Text(
                        'تخصيص الإشعارات لكل صلاة على حدة',
                        style: context.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // قائمة الصلوات
          ...prayers.map((prayer) => _buildPrayerNotificationTile(
            prayer.$1,
            prayer.$2,
            prayer.$3,
          )),
        ],
      ),
    );
  }

  Widget _buildPrayerNotificationTile(
    PrayerType type,
    String name,
    IconData icon,
  ) {
    final isEnabled = _notificationSettings.enabledPrayers[type] ?? false;
    final minutesBefore = _notificationSettings.minutesBefore[type] ?? 0;
    
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _primaryGreenColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: _primaryGreenColor,
          size: 20,
        ),
      ),
      title: Text(name),
      subtitle: Text(
        isEnabled && _notificationSettings.enabled
            ? 'تنبيه قبل $minutesBefore دقيقة'
            : 'التنبيه معطل',
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: _notificationSettings.enabled
            ? (value) {
                setState(() {
                  final updatedPrayers = Map<PrayerType, bool>.from(
                    _notificationSettings.enabledPrayers,
                  );
                  updatedPrayers[type] = value;
                  
                  _notificationSettings = _notificationSettings.copyWith(
                    enabledPrayers: updatedPrayers,
                  );
                  _markAsChanged();
                });
              }
            : null,
        activeColor: _primaryGreenColor,
      ),
      children: [
        if (isEnabled && _notificationSettings.enabled)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                const Text('التنبيه قبل'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
                    value: minutesBefore,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [0, 5, 10, 15, 20, 25, 30, 45, 60]
                        .map((minutes) => DropdownMenuItem(
                              value: minutes,
                              child: Text('$minutes'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          final updatedMinutes = Map<PrayerType, int>.from(
                            _notificationSettings.minutesBefore,
                          );
                          updatedMinutes[type] = value;
                          
                          _notificationSettings = _notificationSettings.copyWith(
                            minutesBefore: updatedMinutes,
                          );
                          _markAsChanged();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('دقيقة'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving || !_hasChanges ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreenColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'حفظ الإعدادات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغييرات غير محفوظة'),
        content: const Text('لديك تغييرات لم يتم حفظها. هل تريد حفظ التغييرات قبل المغادرة؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('تجاهل التغييرات'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('حفظ وخروج'),
          ),
        ],
      ),
    );
    
    if (!mounted) return;
    
    if (result == true) {
      await _saveSettings();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (result == false) {
      Navigator.pop(context);
    }
  }
}