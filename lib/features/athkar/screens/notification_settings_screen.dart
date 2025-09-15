// lib/features/athkar/screens/notification_settings_screen.dart (محسن)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/di/service_locator.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../services/athkar_service.dart';
import '../models/athkar_model.dart';
import '../../../core/infrastructure/services/notifications/notification_manager.dart';
import '../../../core/infrastructure/services/notifications/models/notification_models.dart';

class AthkarNotificationSettingsScreen extends StatefulWidget {
  const AthkarNotificationSettingsScreen({super.key});

  @override
  State<AthkarNotificationSettingsScreen> createState() => _AthkarNotificationSettingsScreenState();
}

class _AthkarNotificationSettingsScreenState extends State<AthkarNotificationSettingsScreen> {
  late final AthkarService _service;
  late final PermissionService _permissionService;
  late final StorageService _storage;
  
  List<AthkarCategory>? _categories;
  
  final Map<String, bool> _enabled = {};
  final Map<String, TimeOfDay> _customTimes = {};
  final Map<String, TimeOfDay> _originalTimes = {}; // لحفظ الأوقات الأصلية
  bool _saving = false;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  // مفاتيح التخزين المحسنة
  static const String _customTimesKey = 'athkar_custom_times_v2';
  static const String _settingsVersionKey = 'athkar_settings_version';
  static const int _currentSettingsVersion = 2;

  // أوقات افتراضية للفئات المختلفة
  static const Map<String, TimeOfDay> _defaultTimes = {
    'morning': TimeOfDay(hour: 6, minute: 0),      // أذكار الصباح
    'evening': TimeOfDay(hour: 18, minute: 0),     // أذكار المساء
    'sleep': TimeOfDay(hour: 22, minute: 0),       // أذكار النوم
    'wakeup': TimeOfDay(hour: 5, minute: 30),      // أذكار الاستيقاظ
    'prayer': TimeOfDay(hour: 12, minute: 0),      // أذكار الصلاة
    'eating': TimeOfDay(hour: 19, minute: 0),      // أذكار الطعام
    'travel': TimeOfDay(hour: 8, minute: 0),       // أذكار السفر
    'general': TimeOfDay(hour: 14, minute: 0),     // أذكار عامة
  };

  // الفئات التي يجب تفعيلها تلقائياً
  static const Set<String> _autoEnabledCategories = {
    'morning',
    'evening', 
    'sleep',
  };

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _permissionService = getIt<PermissionService>();
    _storage = getIt<StorageService>();
    _loadData();
  }

  TimeOfDay _getDefaultTimeForCategory(String categoryId) {
    for (final key in _defaultTimes.keys) {
      if (categoryId.toLowerCase().contains(key)) {
        return _defaultTimes[key]!;
      }
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  bool _shouldAutoEnable(String categoryId) {
    for (final key in _autoEnabledCategories) {
      if (categoryId.toLowerCase().contains(key)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // التحقق من إصدار الإعدادات
      await _checkSettingsVersion();
      
      // التحقق من الإذن
      _hasPermission = await _permissionService.checkNotificationPermission();
      
      // تحميل جميع الفئات
      final allCategories = await _service.loadCategories();
      
      // تحميل الفئات المفعلة
      final enabledIds = _service.getEnabledReminderCategories();
      
      // تحميل الأوقات المخصصة
      await _loadCustomTimes();
      
      // التحقق من أول تشغيل
      final isFirstLaunch = enabledIds.isEmpty && _customTimes.isEmpty;
      
      // تهيئة البيانات
      _enabled.clear();
      final autoEnabledIds = <String>[];
      
      for (final category in allCategories) {
        bool shouldEnable = enabledIds.contains(category.id);
        
        // في أول تشغيل، تفعيل الفئات الأساسية
        if (isFirstLaunch && _shouldAutoEnable(category.id)) {
          shouldEnable = true;
          autoEnabledIds.add(category.id);
        }
        
        _enabled[category.id] = shouldEnable;
        
        // تعيين الوقت إذا لم يكن محفوظاً
        if (!_customTimes.containsKey(category.id)) {
          _customTimes[category.id] = category.notifyTime ?? 
              _getDefaultTimeForCategory(category.id);
        }
        
        // حفظ الوقت الأصلي
        _originalTimes[category.id] = _customTimes[category.id]!;
      }
      
      setState(() {
        _categories = allCategories;
        _isLoading = false;
      });
      
      // حفظ البيانات في أول تشغيل
      if (isFirstLaunch && autoEnabledIds.isNotEmpty) {
        await _service.setEnabledReminderCategories(autoEnabledIds);
        await _saveCustomTimes();
        
        if (_hasPermission) {
          await _scheduleNotificationsOptimized(autoEnabledIds);
        }
        
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.showSuccessSnackBar(
                'تم تفعيل الأذكار الأساسية تلقائياً (${autoEnabledIds.length} فئات)'
              );
            }
          });
        }
      }
      
      // التحقق من صحة الإشعارات المجدولة
      if (_hasPermission) {
        await _validateNotifications();
      }
      
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل البيانات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  /// التحقق من إصدار الإعدادات وترقيتها عند الحاجة
  Future<void> _checkSettingsVersion() async {
    final currentVersion = _storage.getInt(_settingsVersionKey) ?? 1;
    
    if (currentVersion < _currentSettingsVersion) {
      // ترقية الإعدادات
      await _migrateSettings(currentVersion);
      await _storage.setInt(_settingsVersionKey, _currentSettingsVersion);
    }
  }

  /// ترقية الإعدادات من إصدار قديم
  Future<void> _migrateSettings(int fromVersion) async {
    if (fromVersion < 2) {
      // ترقية من الإصدار 1 إلى 2
      // نقل الأوقات من مفتاح قديم إلى جديد إذا لزم الأمر
      debugPrint('ترقية إعدادات الأذكار من الإصدار $fromVersion إلى $_currentSettingsVersion');
    }
  }

  /// تحميل الأوقات المخصصة
  Future<void> _loadCustomTimes() async {
    final savedTimes = _storage.getMap(_customTimesKey);
    
    if (savedTimes != null) {
      savedTimes.forEach((categoryId, timeString) {
        final time = _parseTimeOfDay(timeString);
        if (time != null) {
          _customTimes[categoryId] = time;
        }
      });
    }
  }

  /// حفظ الأوقات المخصصة
  Future<void> _saveCustomTimes() async {
    final timesMap = <String, String>{};
    
    _customTimes.forEach((categoryId, time) {
      timesMap[categoryId] = '${time.hour}:${time.minute}';
    });
    
    await _storage.setMap(_customTimesKey, timesMap);
  }

  /// تحويل نص إلى TimeOfDay
  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;
    
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('خطأ في تحويل الوقت: $timeString');
    }
    return null;
  }

  Future<void> _requestPermission() async {
    try {
      final granted = await _permissionService.requestNotificationPermission();
      setState(() => _hasPermission = granted);
      
      if (granted) {
        context.showSuccessSnackBar('تم منح إذن الإشعارات');
        // جدولة الإشعارات للفئات المفعلة
        final enabledIds = _enabled.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
        if (enabledIds.isNotEmpty) {
          await _scheduleNotificationsOptimized(enabledIds);
        }
      } else {
        context.showErrorSnackBar('تم رفض إذن الإشعارات');
      }
    } catch (e) {
      context.showErrorSnackBar('حدث خطأ أثناء طلب الإذن');
    }
  }

  Future<void> _toggleCategory(String categoryId, bool value) async {
    final oldValue = _enabled[categoryId];
    
    setState(() {
      _enabled[categoryId] = value;
    });
    
    try {
      await _saveChanges();
    } catch (e) {
      // إعادة القيمة السابقة في حالة الخطأ
      setState(() {
        _enabled[categoryId] = oldValue ?? false;
      });
      rethrow;
    }
  }

  Future<void> _updateTime(String categoryId, TimeOfDay time) async {
    final oldTime = _customTimes[categoryId];
    
    setState(() {
      _customTimes[categoryId] = time;
    });
    
    try {
      await _saveCustomTimes();
      
      // إعادة جدولة فقط إذا كانت الفئة مفعلة
      if (_enabled[categoryId] == true && _hasPermission) {
        final category = (_categories ?? [])
            .firstWhere((c) => c.id == categoryId);
        
        await NotificationManager.instance.cancelAthkarReminder(categoryId);
        await NotificationManager.instance.scheduleAthkarReminder(
          categoryId: categoryId,
          categoryName: category.title,
          time: time,
        );
      }
      
      // تفعيل الفئة تلقائياً عند تغيير الوقت
      if (!(_enabled[categoryId] ?? false)) {
        await _toggleCategory(categoryId, true);
      }
      
      if (mounted) {
        context.showSuccessSnackBar('تم تحديث الوقت بنجاح');
      }
    } catch (e) {
      // إعادة الوقت السابق في حالة الخطأ
      setState(() {
        _customTimes[categoryId] = oldTime ?? _getDefaultTimeForCategory(categoryId);
      });
      
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحديث الوقت');
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    
    setState(() => _saving = true);
    
    try {
      // التحقق من الأذونات
      if (!_hasPermission) {
        final enabledCount = _enabled.values.where((e) => e).length;
        if (enabledCount > 0) {
          if (mounted) {
            SnackBarExtension(context).showWarningSnackBar('يجب تفعيل أذونات الإشعارات أولاً');
          }
          return;
        }
      }

      // حفظ الفئات المفعلة
      final enabledIds = _enabled.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      
      await _service.setEnabledReminderCategories(enabledIds);
      
      // حفظ الأوقات المخصصة
      await _saveCustomTimes();
      
      // جدولة الإشعارات بكفاءة
      if (_hasPermission) {
        await _scheduleNotificationsOptimized(enabledIds);
      }
      
      if (mounted) {
        context.showSuccessSnackBar('تم حفظ الإعدادات بنجاح');
      }
    } catch (e) {
      debugPrint('خطأ في حفظ الإعدادات: $e');
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في حفظ الإعدادات');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// جدولة الإشعارات بكفاءة أكبر
  Future<void> _scheduleNotificationsOptimized(List<String> enabledIds) async {
    final notificationManager = NotificationManager.instance;
    final categories = _categories ?? [];
    
    try {
      // الحصول على الإشعارات المجدولة حالياً
      final currentNotifications = await notificationManager.getScheduledNotifications();
      final currentAthkarIds = currentNotifications
          .where((n) => n.category == NotificationCategory.athkar)
          .map((n) => n.payload?['categoryId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();
      
      final enabledSet = enabledIds.toSet();
      
      // إلغاء الإشعارات غير المطلوبة
      final toCancel = currentAthkarIds.difference(enabledSet);
      for (final categoryId in toCancel) {
        await notificationManager.cancelAthkarReminder(categoryId);
      }
      
      // جدولة الإشعارات الجديدة أو المحدثة
      for (final categoryId in enabledIds) {
        final category = categories.firstWhere((c) => c.id == categoryId);
        final time = _customTimes[categoryId];
        
        if (time != null) {
          // التحقق من أن الوقت تغير أو أن الإشعار غير موجود
          final needsReschedule = !currentAthkarIds.contains(categoryId) ||
                                  time != _originalTimes[categoryId];
          
          if (needsReschedule) {
            await notificationManager.cancelAthkarReminder(categoryId);
            await notificationManager.scheduleAthkarReminder(
              categoryId: categoryId,
              categoryName: category.title,
              time: time,
            );
          }
        }
      }
      
      // تحديث الأوقات الأصلية
      enabledIds.forEach((id) {
        if (_customTimes.containsKey(id)) {
          _originalTimes[id] = _customTimes[id]!;
        }
      });
      
    } catch (e) {
      debugPrint('خطأ في جدولة الإشعارات: $e');
      rethrow;
    }
  }

  /// التحقق من صحة الإشعارات المجدولة
  Future<void> _validateNotifications() async {
    if (!_hasPermission) return;
    
    try {
      final enabledIds = _service.getEnabledReminderCategories();
      final scheduledNotifications = await NotificationManager.instance
          .getScheduledNotifications();
      
      final scheduledAthkarIds = scheduledNotifications
          .where((n) => n.category == NotificationCategory.athkar)
          .map((n) => n.payload?['categoryId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();
      
      final enabledSet = enabledIds.toSet();
      final missingNotifications = enabledSet.difference(scheduledAthkarIds);
      final extraNotifications = scheduledAthkarIds.difference(enabledSet);
      
      if (missingNotifications.isNotEmpty || extraNotifications.isNotEmpty) {
        debugPrint('إعادة مزامنة الإشعارات... مفقود: $missingNotifications، زائد: $extraNotifications');
        await _scheduleNotificationsOptimized(enabledIds);
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من الإشعارات: $e');
    }
  }

  Future<void> _selectTime(String categoryId, TimeOfDay currentTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'اختر وقت التذكير',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: context.surfaceColor,
              hourMinuteTextColor: context.textPrimaryColor,
              dialHandColor: ThemeConstants.primary,
              dialBackgroundColor: context.cardColor,
              helpTextStyle: context.titleMedium?.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await _updateTime(categoryId, selectedTime);
    }
  }

  Future<void> _enableAllReminders() async {
    HapticFeedback.mediumImpact();
    
    final shouldEnable = await AppInfoDialog.showConfirmation(
      context: context,
      title: 'تفعيل جميع التذكيرات',
      content: 'هل تريد تفعيل تذكيرات جميع فئات الأذكار بالأوقات الافتراضية؟',
      confirmText: 'تفعيل الكل',
      cancelText: 'إلغاء',
      icon: Icons.notifications_active,
    );
    
    if (shouldEnable == true) {
      setState(() {
        for (final category in _categories ?? <AthkarCategory>[]) {
          _enabled[category.id] = true;
        }
      });
      await _saveChanges();
      context.showSuccessSnackBar('تم تفعيل جميع التذكيرات');
    }
  }

  Future<void> _disableAllReminders() async {
    HapticFeedback.mediumImpact();
    
    final shouldDisable = await AppInfoDialog.showConfirmation(
      context: context,
      title: 'إيقاف جميع التذكيرات',
      content: 'هل تريد إيقاف جميع تذكيرات الأذكار؟',
      confirmText: 'إيقاف الكل',
      cancelText: 'إلغاء',
      icon: Icons.notifications_off,
      destructive: true,
    );
    
    if (shouldDisable == true) {
      setState(() {
        for (final category in _categories ?? <AthkarCategory>[]) {
          _enabled[category.id] = false;
        }
      });
      await _saveChanges();
      context.showSuccessSnackBar('تم إيقاف جميع التذكيرات');
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
              child: _buildBody(),
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
                  'إشعارات الأذكار',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'تخصيص تذكيرات الأذكار اليومية',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // قائمة الإجراءات
          if (_hasPermission && (_categories?.isNotEmpty ?? false))
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: PopupMenuButton<String>(
                  icon: Container(
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
                      Icons.more_vert,
                      color: context.textPrimaryColor,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'enable_all':
                        _enableAllReminders();
                        break;
                      case 'disable_all':
                        _disableAllReminders();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'enable_all',
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active),
                          SizedBox(width: 8),
                          Text('تفعيل الكل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'disable_all',
                      child: Row(
                        children: [
                          Icon(Icons.notifications_off),
                          SizedBox(width: 8),
                          Text('إيقاف الكل'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // مؤشر الحفظ
          if (_saving)
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: const SizedBox(
                width: ThemeConstants.iconMd,
                height: ThemeConstants.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: AppLoading.page(
          message: 'جاري تحميل الإعدادات...',
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: AppEmptyState.error(
          message: _errorMessage!,
          onRetry: _loadData,
        ),
      );
    }

    final categories = _categories ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الإذن
            _buildPermissionSection(),
            
            const SizedBox(height: ThemeConstants.space6),
            
            // قائمة الفئات
            if (_hasPermission) ...[
              if (categories.isEmpty)
                _buildNoCategoriesMessage()
              else ...[
                // إحصائيات سريعة
                _buildQuickStats(categories),
                
                const SizedBox(height: ThemeConstants.space4),
                
                Text(
                  'جميع فئات الأذكار (${categories.length})',
                  style: context.titleMedium?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                
                const SizedBox(height: ThemeConstants.space2),
                
                Text(
                  'يمكنك تفعيل التذكيرات لأي فئة وتخصيص أوقاتها',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                
                const SizedBox(height: ThemeConstants.space4),
                
                ...categories.map((category) => 
                  _buildCategoryTile(category)
                ),
              ],
            ] else
              _buildPermissionRequiredMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<AthkarCategory> categories) {
    final enabledCount = _enabled.values.where((e) => e).length;
    final disabledCount = categories.length - enabledCount;
    
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_active,
              count: enabledCount,
              label: 'مفعلة',
              color: ThemeConstants.success,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_off,
              count: disabledCount,
              label: 'معطلة',
              color: context.textSecondaryColor,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          Expanded(
            child: _StatItem(
              icon: Icons.format_list_numbered,
              count: categories.length,
              label: 'الكل',
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _hasPermission ? Icons.notifications_active : Icons.notifications_off,
                color: _hasPermission ? ThemeConstants.success : ThemeConstants.warning,
                size: 24,
              ),
              const SizedBox(width: ThemeConstants.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasPermission ? 'الإشعارات مفعلة' : 'الإشعارات معطلة',
                      style: context.titleSmall?.copyWith(
                        fontWeight: ThemeConstants.semiBold,
                        color: _hasPermission ? ThemeConstants.success : ThemeConstants.warning,
                      ),
                    ),
                    Text(
                      _hasPermission 
                          ? 'يمكنك الآن تخصيص تذكيرات الأذكار'
                          : 'قم بتفعيل الإشعارات لتلقي التذكيرات',
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasPermission) ...[
            const SizedBox(height: ThemeConstants.space3),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                text: 'تفعيل الإشعارات',
                onPressed: _requestPermission,
                icon: Icons.notifications,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoCategoriesMessage() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ThemeConstants.space3),
          Text(
            'لا توجد فئات أذكار',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeConstants.space2),
          Text(
            'لم يتم العثور على أي فئات للأذكار',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredMessage() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: ThemeConstants.warning,
          ),
          const SizedBox(height: ThemeConstants.space3),
          Text(
            'الإشعارات مطلوبة',
            style: context.titleMedium?.copyWith(
              color: ThemeConstants.warning,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          const SizedBox(height: ThemeConstants.space2),
          Text(
            'يجب تفعيل الإشعارات أولاً لتتمكن من إعداد تذكيرات الأذكار لجميع الفئات',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.space4),
          AppButton.primary(
            text: 'تفعيل الإشعارات الآن',
            onPressed: _requestPermission,
            icon: Icons.notifications_active,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(AthkarCategory category) {
    final isEnabled = _enabled[category.id] ?? false;
    final currentTime = _customTimes[category.id] ?? 
        _getDefaultTimeForCategory(category.id);
    final hasOriginalTime = category.notifyTime != null;
    final isAutoEnabled = _shouldAutoEnable(category.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
      child: AppCard(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة الفئة
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: ThemeConstants.iconMd,
                  ),
                ),
                
                const SizedBox(width: ThemeConstants.space3),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.title,
                              style: context.titleSmall?.copyWith(
                                fontWeight: ThemeConstants.semiBold,
                              ),
                            ),
                          ),
                          if (isAutoEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeConstants.space2,
                                vertical: ThemeConstants.space1,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  ThemeConstants.radiusXs,
                                ),
                              ),
                              child: Text(
                                'أساسي',
                                style: context.labelSmall?.copyWith(
                                  color: ThemeConstants.success,
                                  fontSize: 10,
                                  fontWeight: ThemeConstants.bold,
                                ),
                              ),
                            )
                          else if (!hasOriginalTime)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeConstants.space2,
                                vertical: ThemeConstants.space1,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  ThemeConstants.radiusXs,
                                ),
                              ),
                              child: Text(
                                'مخصص',
                                style: context.labelSmall?.copyWith(
                                  color: ThemeConstants.info,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (category.description?.isNotEmpty == true)
                        Text(
                          category.description!,
                          style: context.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // عدد الأذكار
                      Row(
                        children: [
                          Text(
                            '${category.athkar.length} ذكر',
                            style: context.labelSmall?.copyWith(
                              color: context.textSecondaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                          if (isAutoEnabled) ...[
                            Text(
                              ' • ',
                              style: context.labelSmall?.copyWith(
                                color: context.textSecondaryColor.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              'مفعل تلقائياً',
                              style: context.labelSmall?.copyWith(
                                color: ThemeConstants.success,
                                fontWeight: ThemeConstants.medium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                Switch(
                  value: isEnabled,
                  onChanged: _hasPermission 
                      ? (value) => _toggleCategory(category.id, value)
                      : null,
                  activeColor: isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary,
                ),
              ],
            ),
            
            if (isEnabled) ...[
              const SizedBox(height: ThemeConstants.space3),
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space3),
                decoration: BoxDecoration(
                  color: (isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  border: Border.all(
                    color: (isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: ThemeConstants.iconSm,
                      color: isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary,
                    ),
                    const SizedBox(width: ThemeConstants.space2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'وقت التذكير: ${currentTime.format(context)}',
                            style: context.bodyMedium?.copyWith(
                              color: isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary,
                              fontWeight: ThemeConstants.medium,
                            ),
                          ),
                          if (!hasOriginalTime)
                            Text(
                              isAutoEnabled 
                                  ? 'وقت افتراضي للفئة الأساسية'
                                  : 'وقت افتراضي - يمكنك تغييره',
                              style: context.labelSmall?.copyWith(
                                color: (isAutoEnabled ? ThemeConstants.success : ThemeConstants.primary)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectTime(category.id, currentTime),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.space3,
                        ),
                      ),
                      child: const Text('تغيير'),
                    ),
                  ],
                ),
              ),
            ] else if (!hasOriginalTime) ...[
              const SizedBox(height: ThemeConstants.space2),
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: ThemeConstants.iconXs,
                    color: context.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: ThemeConstants.space1),
                  Text(
                    'الوقت الافتراضي: ${currentTime.format(context)}',
                    style: context.labelSmall?.copyWith(
                      color: context.textSecondaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  if (isAutoEnabled) ...[
                    Text(
                      ' (أساسي)',
                      style: context.labelSmall?.copyWith(
                        color: ThemeConstants.success.withValues(alpha: 0.7),
                        fontWeight: ThemeConstants.medium,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ThemeConstants.iconSm,
        ),
        const SizedBox(height: ThemeConstants.space1),
        Text(
          '$count',
          style: context.titleMedium?.copyWith(
            color: color,
            fontWeight: ThemeConstants.bold,
          ),
        ),
        Text(
          label,
          style: context.labelSmall?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}